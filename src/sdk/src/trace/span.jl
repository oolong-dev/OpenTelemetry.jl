struct Span{P<:AbstractTracerProvider} <: AbstractSpan
    name::Ref{String}
    tracer::Tracer{P}
    span_context::SpanContext
    parent_span_context::Union{Nothing,SpanContext}
    kind::SpanKind
    start_time::UInt
    end_time::Ref{Union{Nothing,UInt}}
    attributes::DynamicAttrs
    links::Limited{Vector{Link}}
    events::Limited{Vector{Event}}
    status::Ref{SpanStatus}
end

function OpenTelemetryAPI.create_span(
    name::String,
    tracer::Tracer{<:TracerProvider};
    context = current_context(),
    kind = SPAN_KIND_INTERNAL,
    attributes = Dict{String,TAttrVal}(),
    links = Link[],
    events = OpenTelemetryAPI.Event[],
    start_time = UInt(time() * 10^9),
    is_remote = false,
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
        count_limit = provider.limit_info.span_attribute_count_limit,
        value_length_limit = provider.limit_info.span_attribute_value_length_limit,
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
        isnothing(parent_span_ctx) ? TraceState() : parent_span_ctx.trace_state,
    )

    span_ctx = SpanContext(
        trace_id = trace_id,
        span_id = generate_span_id(provider.id_generator),
        is_remote = is_remote,
        trace_flag = TraceFlag(sampled = is_sampled(sampling_result)),
        trace_state = sampling_result.trace_state,
    )

    is_no_op_span = provider.is_shut_down[] || !is_recording(sampling_result)
    s = Span(
        Ref(name),
        tracer,
        is_no_op_span ? INVALID_SPAN_CONTEXT : span_ctx,
        parent_span_ctx,
        kind,
        start_time,
        Ref{Union{Nothing,UInt64}}(is_no_op_span ? start_time : nothing),
        attributes,
        links,
        events,
        Ref(SpanStatus(SPAN_STATUS_UNSET)),
    )
    if !is_no_op_span
        on_start!(tracer.provider.span_processor, s)
    end
    s
end

function OpenTelemetryAPI.end_span!(s::Span{<:TracerProvider}, t = UInt(time() * 10^9))
    if is_recording(s)
        s.end_time[] = t
        on_end!(s.tracer.provider.span_processor, s)
    else
        @warn "the span is not recording."
    end
end

OpenTelemetryAPI.is_recording(s::Span) = isnothing(s.end_time[])

function Base.setindex!(s::Span, val, key)
    if is_recording(s)
        s.attributes[key] = val
    else
        @warn "the span is not recording."
    end
end

Base.getindex(s::Span, key) = s.attributes[key]
Base.haskey(s::Span, key) = haskey(s.attributes, key)

function Base.push!(s::Span, event::Event)
    if is_recording(s)
        push!(s.events, event)
    else
        @warn "the span is not recording."
    end
end

function Base.push!(s::Span, link::Link)
    if is_recording(s)
        push!(s.links, link)
    else
        @warn "the span is not recording."
    end
end

function OpenTelemetryAPI.span_status!(s::Span, code::SpanStatusCode, description = nothing)
    if is_recording(s)
        if s.status[].code === SPAN_STATUS_OK
            # no further updates
        else
            if code === SPAN_STATUS_UNSET
                # ignore
            else
                s.status[] = SpanStatus(code, description)
            end
        end
    else
        @warn "the span is not recording."
    end
end

function OpenTelemetryAPI.end_span!(s::Span, t)
    if is_recording(s)
        s.end_time[] = t
    else
        @warn "the span is not recording."
    end
end

function Base.push!(s::Span, ex::Exception; is_rethrow_followed = false)
    if is_recording(s)
        msg_io = IOBuffer()
        showerror(msg_io, ex)
        msg = String(take!(msg_io))

        st_io = IOBuffer()
        showerror(st_io, CapturedException(ex, catch_backtrace()))
        st = String(take!(st_io))

        attrs = StaticAttrs((;
            Symbol("exception.type") => string(typeof(ex)),
            Symbol("exception.type") => string(typeof(ex)),
            Symbol("exception.message") => msg,
            Symbol("exception.stacktrace") => st,
            Symbol("exception.escaped") => is_rethrow_followed,
        ))

        push!(s, Event(name = "exception", attributes = attrs))
    else
        @warn "the span is not recording."
    end
end

Base.nameof(s::Span) = s.name[]

function OpenTelemetryAPI.span_name!(s::Span, name::String)
    if is_recording(s)
        s.name[] = name
    else
        @warn "the span is not recording."
    end
end

OpenTelemetryAPI.span_context(s::Span) = s.span_context