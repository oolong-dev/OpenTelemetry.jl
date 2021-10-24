export TracerProvider

"""
    TracerProvider(;kw...)

# Keyword Arguments

- `sampler`=[`DEFAULT_ON`](@ref)
- `resource`=[`Resource`](@ref)()
- `span_processor`=[`CompositSpanProcessor`](@ref)()
- `id_generator`=[`RandomIdGenerator`](@ref)()
- `limit_info`=[`LimitInfo`](@ref)()
"""
Base.@kwdef struct TracerProvider{S<:AbstractSampler, R<:Resource, SP<:AbstractSpanProcessor, RNG} <: AbstractTracerProvider
    sampler::S=DEFAULT_ON
    resource::R=Resource()
    span_processor::SP=CompositSpanProcessor()
    id_generator::RNG=RandomIdGenerator()
    limit_info::LimitInfo=LimitInfo()
    is_shut_down::Ref{Bool} = Ref(false)
end

force_flush!(p::TracerProvider) = force_flush!(p.span_processor)

function shut_down!(p::TracerProvider)
    shut_down!(p.span_processor)
    p.is_shut_down[] = true
end

Base.push!(p::TracerProvider, sp::AbstractSpanProcessor) = push!(p.span_processor, sp)
"""
    Span(name::String, tracer::Tracer{TracerProvider};kw...)

# Keyword Arguments

- `context=current_context()`,
- `kind=SPAN_KIND_INTERNAL`,
- `attributes=Dict{String, TAttrVal}()`,
- `links=Link[]`,
- `events=Event[]`,
- `start_time::UInt=time()*10^9`, the nanoseconds.
- `is_remote=false`
"""
function OpenTelemetryAPI.Span(
    name::String,
    tracer::Tracer{<:TracerProvider}
    ;context=current_context(),
    kind=SPAN_KIND_INTERNAL,
    attributes=Dict{String, TAttrVal}(),
    links=Link[],
    events=Event[],
    start_time=UInt(time() * 10^9),
    is_remote=false
)
    provider = tracer.provider
    parent_span_ctx = context |> current_span |> span_context
    if isnothing(parent_span_ctx)
        trace_id = generate_trace_id(provider.id_generator)
    else
        trace_id = parent_span_ctx.trace_id
    end

    attributes = DynamicAttrs(
        attributes;
        count_limit=provider.limit_info.span_attribute_count_limit,
        value_length_limit=provider.limit_info.span_attribute_value_length_limit,
    )

    links = Limited(links; limit = provider.limit_info.span_link_count_limit)
    events = Limited(events; limit = provider.limit_info.span_event_count_limit)

    sampling_result = should_sample(
        provider.sampler,
        context,
        trace_id,
        name,
        kind,
        attributes,
        links,
        isnothing(parent_span_ctx) ? TraceState() : parent_span_ctx.trace_state
    )

    span_ctx = SpanContext(
        trace_id = trace_id,
        span_id = generate_span_id(provider.id_generator),
        is_remote=is_remote,
        trace_flag = TraceFlag(sampled=is_sampled(sampling_result)),
        trace_state=sampling_result.trace_state
    )

    is_no_op_span = provider.is_shut_down[] || !is_recording(sampling_result)
    s = Span(
        Ref(name),
        tracer,
        is_no_op_span ? INVALID_SPAN_CONTEXT : span_ctx,
        parent_span_ctx,
        kind,
        start_time,
        Ref{Union{Nothing, UInt64}}( is_no_op_span ? start_time : nothing),
        attributes,
        links,
        events,
        Ref(SpanStatus(SPAN_STATUS_UNSET)),
    )
    if !is_no_op_span
        on_start(tracer.provider.span_processor, s)
    end
    s
end

function OpenTelemetryAPI.end!(s::Span{<:Tracer{<:TracerProvider}}, t=UInt(time()*10^9))
    if is_recording(s)
        s.end_time[] = t
        on_end(s.tracer.provider.span_processor, s)
    else
        @warn "the span is not recording."
    end
end
