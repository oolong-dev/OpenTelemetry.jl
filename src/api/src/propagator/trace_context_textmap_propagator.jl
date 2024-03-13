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
    carrier::Union{
        AbstractVector{<:Pair{<:AbstractString,<:AbstractString}},
        AbstractDict{<:AbstractString,<:AbstractString},
    },
    propagator::TraceContextTextMapPropagator,
    ctx::Context = current_context(),
)
    trace_id, span_id, trace_flag, trace_state = nothing, nothing, nothing, TraceState()
    for (k, v) in carrier
        if k == "traceparent"
            m = match(TRACEPARENT_HEADER_FORMAT, v)
            if !isnothing(m)
                if m["version"] == "00" && isnothing(m["rest"])
                    trace_id = parse(TraceIdType, m["trace_id"], base = 16)
                    span_id = parse(SpanIdType, m["span_id"], base = 16)
                    trace_flag = parse(TraceFlag, m["trace_flag"])
                end
            end
        elseif k == "tracestate"
            trace_state = parse(TraceState, v)
        end
    end
    if isnothing(trace_id) || isnothing(span_id) || isnothing(trace_flag)
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
