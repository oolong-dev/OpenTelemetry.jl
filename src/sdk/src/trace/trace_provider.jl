"""
    TracerProvider(;kw...)

# Keyword Arguments

- `sampler`::[`AbstractSampler`](@ref), the default value is [`DEFAULT_ON`](@ref).
- `resource`::[`Resource`](@ref), the default value is `Resource()`.
- `span_processor`, the default value is [`CompositSpanProcessor()`](@ref CompositSpanProcessor).
- `id_generator`. The default generator is `Random.GLOBAL_RNG`, which needs to implement `rand(id_generator, TraceIdType)` and `rand(id_generator, SpanIdType)`.
- `limit_info`. The default value is [`LimitInfo`](@ref).
"""
Base.@kwdef struct TracerProvider{S<:AbstractSampler, R<:Resource, SP<:AbstractSpanProcessor, RNG}
    sampler::S=DEFAULT_ON
    resource::R=Resource()
    span_processor::SP=CompositSpanProcessor()
    id_generator::RNG=Random.GLOBAL_RNG
    limit_info::LimitInfo=LimitInfo()
end


"""
    Span(name::String, tracer::Tracer;kw...)

# Keyword Arguments

- `context=current_context()`,
- `kind=SPAN_KIND_INTERNAL`,
- `attributes=Dict{String, TAttrVal}()`,
- `links=Link[]`,
- `events=Event[]`,
- `start_time::UInt=time()*10^9`, the nanoseconds.
"""
function Span(
    name::String,
    tracer::Tracer{TracerProvider}
    ;context=current_context(),
    kind=SPAN_KIND_INTERNAL,
    attributes=Dict{String, TAttrVal}(),
    links=Link[],
    events=Event[],
    start_time=UInt(time() * 10^9)
)
    provider = tracer.provider
    parent_span_ctx = context |> current_span |> span_context
    if isnothing(parent_span_ctx)
        trace_id = rand(id_generator(provider), TraceIdType)
    else
        trace_id = parent_span_ctx.trace_id
    end

    attributes = DynamicAttrs(
        attributes;
        count_limit=provider.limit_info.span_attribute_count_limit,
        value_length_limit=provider.limit_info.span_attribute_value_length_limit,
    )

    links = Limited(links; limit = provider.limit_info.span_link_count_limit)
    events = Limited(events, limit = provider.limit_info.span_event_count_limit)

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
        span_id = rand(provider.id_generator, SpanIdType),
        is_remote=false,
        trace_flag = TraceFlag(sampled=is_sampled(sampling_result)),
        trace_state=sampling_result.trace_state
    )

    Span(
        Ref(name),
        span_ctx,
        parent_span_ctx,
        kind,
        start_time,
        Ref(nothing),
        attributes,
        links,
        events,
        Ref(SpanStatus(SPAN_STATUS_UNSET)),
        tracer
    )
end
