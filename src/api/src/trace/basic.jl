export TraceIdType,
    SpanIdType,
    INVALID_SPAN_ID,
    INVALID_SPAN_ID,
    current_span,
    TraceFlag,
    TraceState,
    SpanContext,
    INVALID_SPAN_CONTEXT,
    span_context,
    SPAN_KIND_UNSPECIFIED,
    SPAN_KIND_INTERNAL,
    SPAN_KIND_SERVER,
    SPAN_KIND_CLIENT,
    SPAN_KIND_PRODUCER,
    SPAN_KIND_CONSUMER,
    LimitInfo,
    Link,
    Event,
    SPAN_STATUS_UNSET,
    SPAN_STATUS_OK,
    SPAN_STATUS_ERROR,
    SpanStatus

const TraceIdType = UInt128
const SpanIdType = UInt64

const INVALID_TRACE_ID = zero(TraceIdType)
const INVALID_SPAN_ID = zero(SpanIdType)

const SPAN_KEY_IN_CONTEXT = create_key("current-span")

"""
    current_span([current_context])

Get the span in the current context.
"""
current_span() = current_span(current_context())
current_span(ctx::Context) = get(ctx, SPAN_KEY_IN_CONTEXT, nothing)

Base.@kwdef struct TraceFlag
    sampled::Bool = false
end

const MAXIMUM_TRACESTATE_KEYS = 32
const TRACESTATE_KEY_PATTERN = r"^[a-z][_0-9a-z\\-\\*\\/]{0,255}|[a-z0-9][_0-9a-z\\-\\*\\/]{0,240}@[a-z][_0-9a-z\\-\\*\\/]{0,13}$"
const TRACESTATE_VAL_PATTERN = r"^[\x20-\x2b\x2d-\x3c\x3e-\x7e]{0,255}[\x21-\x2b\x2d-\x3c\x3e-\x7e]$"

function is_valid_trace_state_kv(k,v)
    if isnothing(match(TRACESTATE_KEY_PATTERN, k))
        @warn "Invalid key $k found"
        false
    elseif isnothing(match(TRACESTATE_VAL_PATTERN, v))
        @warn "Invalid val $v found"
        false
    else
        true
    end
end

"""
    TraceState(entries::Pair{String,String}...)

`TraceState` carries vendor-specific trace identification data, represented as a list of key-value pairs. `TraceState` allows multiple tracing systems to participate in the same trace. It is fully described in the [W3C Trace Context specification](https://www.w3.org/TR/trace-context/#tracestate-header).
"""
struct TraceState{T<:NamedTuple}
    kv::T
    function TraceState(entries::Pair{String,String}...)
        if length(entries) > MAXIMUM_TRACESTATE_KEYS
            @warn "There can't be more than $MAXIMUM_TRACESTATE_KEYS key/value pairs"
        else
            kv = NamedTuple(Symbol(k) => v for (k,v) in entries if is_valid_trace_state_kv(k,v))
            new{typeof(kv)}(kv)
        end
    end
end

Base.getindex(s::TraceState, key) = s.kv[key]
Base.haskey(s::TraceState, key) = haskey(s.kv, key)
Base.haskey(s::TraceState, key::String) = haskey(s, Symbol(key))
Base.length(s::TraceState) = length(s.kv)

function Base.show(io::IO, ts::TraceState)
    for (i, (k,v)) in enumerate(pairs(ts.kv))
        print(io, k)
        print(io, '=')
        print(io, v)
        if i != length(ts)
            print(io, ',')
        end
    end
end

"""
    SpanContext(;span_id, trace_id, is_remote, trace_flag=TraceFlag(), trace_state=TraceState())

A `SpanContext` represents the portion of a `Span` which must be serialized and
propagated along side of a distributed context. `SpanContext`s are immutable.

The OpenTelemetry `SpanContext` representation conforms to the [W3C TraceContext
specification](https://www.w3.org/TR/trace-context/). It contains two
identifiers - a `TraceId` and a `SpanId` - along with a set of common
`TraceFlags` and system-specific `TraceState` values.

`TraceId` A valid trace identifier is a 16-byte array with at least one
non-zero byte.

`SpanId` A valid span identifier is an 8-byte array with at least one non-zero
byte.

`TraceFlags` contain details about the trace. Unlike TraceState values,
TraceFlags are present in all traces. The current version of the specification
only supports a single flag called [sampled](https://www.w3.org/TR/trace-context/#sampled-flag).

`TraceState` carries vendor-specific trace identification data, represented as a list
of key-value pairs. TraceState allows multiple tracing
systems to participate in the same trace. It is fully described in the [W3C Trace Context
specification](https://www.w3.org/TR/trace-context/#tracestate-header).
"""
Base.@kwdef struct SpanContext{TS<:TraceState}
    span_id::SpanIdType
    trace_id::TraceIdType
    is_remote::Bool
    trace_flag::TraceFlag = TraceFlag()
    trace_state::TS = TraceState()
end

const INVALID_SPAN_CONTEXT = SpanContext(;
    trace_id = INVALID_TRACE_ID,
    span_id = INVALID_SPAN_ID,
    is_remote=false,
)

"""
    span_context([s::Span])

Get the `SpanContext` from a span `s`. If `s` is not specified, [`current_span()`](@ref) will be used. `nothing` is returned if no span context found.
"""
span_context(s) = s.span_context
span_context(::Nothing) = nothing
span_context() = span_context(current_span())

# !!! must be of the same order with https://github.com/open-telemetry/opentelemetry-proto/blob/main/opentelemetry/proto/trace/v1/trace.proto
@enum SpanKind begin
    SPAN_KIND_UNSPECIFIED 
    SPAN_KIND_INTERNAL
    SPAN_KIND_SERVER
    SPAN_KIND_CLIENT
    SPAN_KIND_PRODUCER
    SPAN_KIND_CONSUMER
end

"""
    LimitInfo(;kw...)

Used in [`TracerProvider`](@ref) to configure generated [`Tracer`](@ref).

# Keyword arguments:

- `span_attribute_count_limit::Int` = 128
- `span_attribute_value_length_limit::Union{Nothing,Int}` = nothing
- `span_event_count_limit::Int` = 128
- `span_link_count_limit::Int` = 128
"""
Base.@kwdef struct LimitInfo
    span_attribute_count_limit::Int = 128
    span_attribute_value_length_limit::Union{Nothing, Int} = nothing
    span_event_count_limit::Int = 128
    span_link_count_limit::Int = 128
end

"""
    Link(span_context, attributes)

See more details at [links between spans](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#links-between-spans).
"""
struct Link{C<:SpanContext,A<:StaticAttrs}
    context::C
    attributes::A
end

"""
    Event(name, timestamp=time()*10^9, attributes=StaticAttrs())

`timestamp` is the *nanoseconds*.
"""
Base.@kwdef struct Event{A<:StaticAttrs}
    name::String
    timestamp::UInt = UInt(time() * 10^9)
    attributes::A = StaticAttrs()
end

# !!! must be of the same order as https://github.com/open-telemetry/opentelemetry-proto/blob/main/opentelemetry/proto/trace/v1/trace.proto
@enum SpanStatusCode begin
    SPAN_STATUS_UNSET
    SPAN_STATUS_OK
    SPAN_STATUS_ERROR
end

"""
    SpanStatus(code, description=nothing)

Possible codes are:

- `SPAN_STATUS_UNSET`
- `SPAN_STATUS_ERROR`
- `SPAN_STATUS_OK`

`description` is required when `code` is `SPAN_STATUS_ERROR`.
"""
struct SpanStatus
    code::SpanStatusCode
    description::Union{String,Nothing}
    function SpanStatus(code::SpanStatusCode, description=nothing)
        if code === SPAN_STATUS_ERROR
            isnothing(description) && @error "description not provided"
            new(code, description)
        else
            # description is ignored
            new(code, nothing)
        end
    end
end
