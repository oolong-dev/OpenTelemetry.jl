#####
"""
    Limited(container; limit=32)

Create a container wrapper with limited elements.

The following methods from `Base` are defined on `Limited` which are then forwarded to the inner `container`. Feel free to create a PR if you find any method you need is missing:

  - `Base.getindex`
  - `Base.setindex!`
  - `Base.iterate`
  - `Base.length`
  - `Base.haskey`
  - `Base.push!`. Only defined on containers of `AbstractVector`.
"""
mutable struct Limited{T}
    xs::T
    limit::Int
    n_dropped::Int # mutable
end

function Limited(xs::AbstractVector; limit = 32)
    n_dropped = zero(Int)
    if length(xs) > limit
        n_dropped = length(xs) - limit
        for _ in 1:(length(xs)-limit)
            pop!(xs)
        end
        @warn "limit $limit exceeded, $(n_dropped) elements dropped."
    end
    Limited(xs, limit, n_dropped)
end

Base.getindex(x::Limited, args...) = getindex(x.xs, args...)
Base.haskey(x::Limited, k) = haskey(x.xs, k)
Base.length(x::Limited) = length(x.xs)
Base.iterate(x::Limited, args...) = iterate(x.xs, args...)
Base.pairs(A::Limited) = pairs(A.xs)

function Base.push!(l::Limited, x)
    if length(l.xs) >= l.limit
        popfirst!(l.xs)
        l.n_dropped += 1
        @warn "limit exceeded, the oldest one is dropped"
    end
    push!(l.xs, x)
end

OpenTelemetryAPI.n_dropped(l::Limited) = l.n_dropped

#####

mutable struct Span{P<:OpenTelemetryAPI.AbstractTracerProvider} <: AbstractSpan
    name::String # mutable
    tracer::Tracer{P}
    span_context::SpanContext
    parent_span_context::Union{Nothing,SpanContext}
    kind::SpanKind
    start_time::UInt
    end_time::Union{Nothing,UInt} # mutable
    attributes::BoundedAttributes
    links::Limited{Vector{Link}}
    events::Limited{Vector{Event}}
    status::SpanStatus # mutable
end

function OpenTelemetryAPI.create_span(
    name::String,
    tracer::Tracer{<:TracerProvider};
    context::OpenTelemetryAPI.Context = current_context(),
    parent_span::Union{Nothing,AbstractSpan} = current_span(context),
    parent_span_ctx::Union{Nothing,SpanContext} = span_context(parent_span),
    trace_id::Union{Nothing, TraceIdType} = nothing,
    kind = SPAN_KIND_INTERNAL,
    attributes = Dict{String,OpenTelemetryAPI.TAttrVal}(),
    links = Link[],
    events = OpenTelemetryAPI.Event[],
    start_time = UInt(time() * 10^9),
    is_remote = false,
)
    provider = tracer.provider
    
    if trace_id === nothing
        if isnothing(parent_span_ctx)
            trace_id = generate_trace_id(provider.id_generator)
        else
            trace_id = parent_span_ctx.trace_id
        end
    end 

    attributes = BoundedAttributes(
        attributes;
        count_limit = provider.limit_info.span_attribute_count_limit,
        value_length_limit = provider.limit_info.span_attribute_value_length_limit,
    )

    links = Limited(links; limit = provider.limit_info.span_link_count_limit)
    events = Limited(events; limit = provider.limit_info.span_event_count_limit)

    sampling_result = should_sample(
        provider.sampler,
        parent_span_ctx,
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

    is_no_op_span = provider.is_closed || !is_recording(sampling_result)
    s = Span(
        name,
        tracer,
        is_no_op_span ? INVALID_SPAN_CONTEXT : span_ctx,
        parent_span_ctx,
        kind,
        start_time,
        is_no_op_span ? start_time : nothing,
        attributes,
        links,
        events,
        SpanStatus(SPAN_STATUS_UNSET),
    )
    if !is_no_op_span
        on_start!(tracer.provider.span_processor, s)
    end
    s
end

OpenTelemetryAPI.tracer(s::Span) = s.tracer
OpenTelemetryAPI.span_context(s::Span) = s.span_context
OpenTelemetryAPI.span_kind(s::Span) = s.kind
OpenTelemetryAPI.parent_span_context(s::Span) = s.parent_span_context
OpenTelemetryAPI.attributes(s::Span) = s.attributes
OpenTelemetryAPI.is_recording(s::Span) = isnothing(s.end_time)
OpenTelemetryAPI.start_time(s::Span) = s.start_time
OpenTelemetryAPI.span_links(s::Span) = s.links
OpenTelemetryAPI.span_events(s::Span) = s.events
OpenTelemetryAPI.end_time(s::Span) = s.end_time

function OpenTelemetryAPI.end_span!(s::Span{<:TracerProvider}, t = UInt(time() * 10^9))
    if is_recording(s)
        s.end_time = t
        on_end!(s.tracer.provider.span_processor, s)
    else
        @warn "the span is not recording."
    end
end

function OpenTelemetryAPI.span_status!(s::Span, code::SpanStatusCode, description = nothing)
    if is_recording(s)
        if s.status.code === SPAN_STATUS_OK
            # no further updates
        else
            if code === SPAN_STATUS_UNSET
                # ignore
            else
                s.status = SpanStatus(code, description)
            end
        end
    else
        @warn "the span is not recording."
    end
end

OpenTelemetryAPI.span_status(s::Span) = s.status

OpenTelemetryAPI.span_name(s::Span) = s.name

function OpenTelemetryAPI.span_name!(s::Span, name::String)
    if is_recording(s)
        s.name = name
    else
        @warn "the span is not recording."
    end
end

function Base.push!(s::Span, ex::Exception; is_rethrow_followed = false)
    msg_io = IOBuffer()
    showerror(msg_io, ex)
    msg = String(take!(msg_io))

    st_io = IOBuffer()
    showerror(st_io, CapturedException(ex, catch_backtrace()))
    st = String(take!(st_io))

    push!(
        s,
        Event(
            "exception";
            Symbol("exception.type") => string(typeof(ex)),
            Symbol("exception.message") => msg,
            Symbol("exception.stacktrace") => st,
            Symbol("exception.escaped") => is_rethrow_followed,
        ),
    )
end
