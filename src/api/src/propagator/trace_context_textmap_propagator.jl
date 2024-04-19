export TraceContextTextMapPropagator

"""
    TraceContextTextMapPropagator()

This propagator follows the [W3C format](https://www.w3.org/TR/trace-context/#trace-context-http-headers-format)
"""
struct TraceContextTextMapPropagator <: AbstractPropagator end

function inject_context!(
    carrier::Union{
        AbstractVector{<:Pair{<:AbstractString,<:AbstractString}},
        AbstractDict{<:AbstractString,<:AbstractString},
    },
    propagator::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
)
    sc = span_context(ctx)
    if !isnothing(sc)
        s_trace_parent = "00-$(string(sc.trace_id, base=16, pad=32))-$(string(sc.span_id, base=16,pad=16))-$(sc.trace_flag.sampled ? "01" : "00")"
        push!(carrier, "traceparent" => s_trace_parent)
        s_trace_state = string(sc.trace_state)
        if !isempty(s_trace_state)
            push!(carrier, "tracestate" => s_trace_state)
        end
    end
    carrier
end

# fallback
function inject_context!(
    carrier::T,
    ::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
) where {T}
    @warn "unknown carrier type $T"
    carrier
end

#####

TRACEPARENT_HEADER_FORMAT =
    r"^[ \t]*(?P<version>[0-9a-f]{2})-(?P<trace_id>[0-9a-f]{32})-(?P<span_id>[0-9a-f]{16})-(?P<trace_flag>[0-9a-f]{2})(?P<rest>-.*)?[ \t]*$"

function extract_context(
    carrier::AbstractDict{<:AbstractString,<:AbstractString},
    propagator::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
)
    trace_id = nothing
    span_id = nothing
    trace_flag = nothing
    trace_state = TraceState()

    carrier_keys = collect(keys(carrier))

    traceparent_idx = findfirst(k -> lowercase(k) == "traceparent", carrier_keys)

    if traceparent_idx !== nothing
        m = match(TRACEPARENT_HEADER_FORMAT, carrier[carrier_keys[traceparent_idx]])
        if m !== nothing && m["version"] == "00" && m["rest"] === nothing
            trace_id = parse(TraceIdType, m["trace_id"], base = 16)
            span_id = parse(SpanIdType, m["span_id"], base = 16)
            trace_flag = parse(TraceFlag, m["trace_flag"])

            # we only look for/parse tracestate if traceparent is ok
            tracestate_idx = findfirst(k -> lowercase(k) == "tracestate", carrier_keys)
            if tracestate_idx !== nothing
                trace_state = parse(TraceState, carrier[carrier_keys[tracestate_idx]])
            end
        end
    end

    return _extract_context(trace_id, span_id, trace_flag, trace_state, propagator, ctx)
end

function extract_context(
    carrier::AbstractVector{<:Pair{<:AbstractString,<:AbstractString}},
    propagator::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
)
    trace_id = nothing
    span_id = nothing
    trace_flag = nothing
    trace_state = TraceState()

    traceparent_idx = findfirst(kv -> lowercase(kv[1]) == "traceparent", carrier)

    if traceparent_idx !== nothing
        m = match(TRACEPARENT_HEADER_FORMAT, carrier[traceparent_idx][2])
        if m !== nothing && m["version"] == "00" && m["rest"] === nothing
            trace_id = parse(TraceIdType, m["trace_id"], base = 16)
            span_id = parse(SpanIdType, m["span_id"], base = 16)
            trace_flag = parse(TraceFlag, m["trace_flag"])

            # we only look for/parse tracestate if traceparent is ok
            tracestate_idx = findfirst(kv -> lowercase(kv[1]) == "tracestate", carrier)
            if tracestate_idx !== nothing
                trace_state = parse(TraceState, carrier[tracestate_idx][2])
            end
        end
    end

    return _extract_context(trace_id, span_id, trace_flag, trace_state, propagator, ctx)
end

function _extract_context(
    trace_id,
    span_id,
    trace_flag,
    trace_state,
    propagator::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
)
    return if (
        trace_id === nothing || 
        span_id === nothing || 
        trace_flag === nothing
    )
        ctx
    else
        merge(
            ctx,
            Context(Dict(
                SPAN_KEY_IN_CONTEXT => NonRecordingSpan(
                    "",
                    SpanContext(span_id, trace_id, false, trace_flag, trace_state),
                    nothing,
                )
            )),
        )
    end
end

# fallback
function extract_context(
    carrier::T,
    ::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
) where {T}
    @warn "unknown carrier type $T"
    ctx
end
