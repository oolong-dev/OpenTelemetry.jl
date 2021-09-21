export TraceFlag,
    TraceState,
    SpanContext,
    Attributes,
    SPAN_KIND_CLIENT,
    SPAN_KIND_SERVER,
    SPAN_KIND_PRODUCER,
    SPAN_KIND_CONSUMER,
    SPAN_KIND_INTERNAL,
    Link,
    Event,
    SpanStatus,
    SPAN_STATUS_UNSET,
    SPAN_STATUS_ERROR,
    SPAN_STATUS_OK,
    Span,
    span_context,
    is_recording,
    add_event!,
    end!,
    set_status!,
    update_name!,
    record_exception!,
    NonRecordingSpan,
    global_tracer_provider,
    INVALID_SPAN_CONTEXT,
    current_span,
    create_span,
    with_span,
    get_tracer

using Dates: time

const TraceIdType = UInt128
const SpanIdType = UInt64

const SPAN_KEY = create_key("current-span")

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
struct TraceState
    kv::NamedTuple
    function TraceState(entries::Pair{String,String}...)
        if length(entries) > MAXIMUM_TRACESTATE_KEYS
            @warn "There can't be more than $MAXIMUM_TRACESTATE_KEYS key/value pairs"
        else
            kv = NamedTuple(Symbol(k) => v for (k,v) in entries if is_valid_trace_state_kv(k,v))
            new(kv)
        end
    end
end

Base.getindex(s::TraceState, key::String) = s.kv[Symbol(key)]
Base.haskey(s::TraceState, key::String) = haskey(s.kv, Symbol(key))

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
Base.@kwdef struct SpanContext
    span_id::SpanIdType
    trace_id::TraceIdType
    is_remote::Bool
    trace_flag::TraceFlag = TraceFlag()
    trace_state::TraceState = TraceState()
end

const INVALID_SPAN_ID = zero(SpanIdType)
const INVALID_TRACE_ID = zero(TraceIdType)

const INVALID_SPAN_CONTEXT = SpanContext(;
    trace_id = INVALID_TRACE_ID,
    span_id = INVALID_SPAN_ID,
    is_remote=false,
)

const TAttrVal = Union{
    String,
    Bool,
    Int64,
    Float64,
    Vector{String},
    Vector{Bool},
    Vector{Int64},
    Vector{Float64}
}

struct Attributes{T}
    count_limit::Int
    value_length_limit::Int
    kv::T
    n_dropped::Ref{Int}
end

_truncate(x, limit) = x

function _truncate(s::String, limit)
    if length(s) <= limit
        s
    else
        @warn "value is truncated to length $limit"
        s[1:min(end,limit)]
    end
end

function _truncate(xs::Vector{String}, limit)
    is_truncated = false
    for (i,s) in enumerate(xs)
        if length(s) > limit
            xs[i] = s[1:limit]
            is_truncated = true
        end
    end
    is_truncated && @warn "some elements in the value are truncated."
    xs
end

"""
    Attributes(kv::Pair{String,<:TAttrVal}...;count_limit=128, value_length_limit=typemax(Int), is_mutable=false)

Tha value type must be either `String`, `Bool`, `Int`, `Float64` or a `Vector` of above types. By default, we use a `NamedTuple` to represent the key-value pairs. If `is_mutable` is set to `true`, we'll use a `Dict` instead internally. If the value is of type `String` or `Vector{String}`, then each entry with length bigger than `value_length_limit` will be truncated.
"""
function Attributes(
    kv::Pair{String,<:TAttrVal}...
    ;count_limit=128,
    value_length_limit=typemax(Int),
    is_mutable=false
)
    if length(kv) > count_limit
        kv = kv[1:count_limit]
        n_dropped = Ref(length(kv) - count_limit)
    else
        n_dropped = Ref(0)
    end
    kv_truncated = (k=>_truncate(v, value_length_limit) for (k, v) in kv)
    if is_mutable
        data = Dict{String,TAttrVal}(kv)
    else
        data = NamedTuple(Symbol(k) => v for (k,v) in kv)
    end
    Attributes(count_limit, value_length_limit, data, n_dropped)
end

Base.getindex(d::Attributes, k::String) = getindex(d.kv, k)
Base.getindex(d::Attributes{<:NamedTuple}, k::String) = getindex(d.kv, Symbol(k))

function Base.setindex!(d::Attributes{<:Dict}, k::String, v::TAttrVal)
    if length(d.kv) == d.count_limit
        @warn "Count limit exceeded. Discarded."
        d.n_dropped[] += 1
    else
        d.kv[k] = _truncate(v, d.value_length_limit)
    end
end

@enum SpanKind begin
    SPAN_KIND_CLIENT
    SPAN_KIND_SERVER
    SPAN_KIND_PRODUCER
    SPAN_KIND_CONSUMER
    SPAN_KIND_INTERNAL
end

"""
    Link(span_context, attributes)

See more details at [links between spans](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#links-between-spans).
"""
struct Link
    context::SpanContext
    attributes::Attributes
end

"""
    Event(name, timestamp=time(), attributes=Attributes())
"""
Base.@kwdef struct Event
    name::String
    timestamp::Float64 = time()
    attributes::Attributes = Attributes()
end

@enum SpanStatusCode begin
    SPAN_STATUS_UNSET
    SPAN_STATUS_ERROR
    SPAN_STATUS_OK
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

abstract type AbstractSpan end

mutable struct Span <: AbstractSpan
    name::String
    span_context::SpanContext
    parent::Union{Nothing,Span,SpanContext}
    kind::SpanKind
    start_time::Float64
    end_time::Union{Nothing,Float64}
    attributes::Attributes
    links::Vector{Link}
    events::Vector{Event}
    status::SpanStatus
end

"""
    Span(;kw...)

# Keyword Arguments

- `name`
- `span_context::SpanContext`
- `parent_context`
- `kind=SPAN_KIND_INTERNAL`
- `attributes=Attributes()`
- `links=[]`
- `start_time=time()`
"""
function Span(
    ;name,
    span_context,
    parent_context::Context=current_context(),
    kind=SPAN_KIND_INTERNAL,
    attributes=Attributes(;is_mutable=true),
    links=[],
    start_time=time()
)
    parent = get(parent_context, SPAN_KEY, nothing)
    Span(name, span_context, parent, kind, start_time, nothing, attributes, links, [], SpanStatus(SPAN_STATUS_UNSET))
end

is_end(s::Span) = !isnothing(s.end_time)

"""
    span_context(s::AbstractSpan)

Get the `SpanContext` from a span `s`.
"""
span_context(s::Span) = s.span_context

"""
    is_recording(s::AbstractSpan)

Returns `true` if this span `s` is recording information like events with the [`add_event!`](@ref) operation, attributes using [`setindex!`](@ref), status with [`set_status!`](@ref), etc.
"""
is_recording(s::Span) = !is_end(s)

"""
    s::AbstractSpan[key] = val

Set the attributes in span `s`. Only valid when the span is not ended yet.
"""
function Base.setindex!(s::Span, key, val)
    if is_end(s)
        @warn "the span is ended."
    else
        s.attributes[key] = val
    end
end

"""
    add_event!(s::AbstractSpan, event::Event)

Record a new `event`. Only valid when the span is not ended yet.
"""
function add_event!(s::Span, event::Event)
    if is_end(s)
        @warn "the span is ended."
    else
        push!(s.events, event)
    end
end

"""
    set_status!(s::Span, code::SpanStatusCode, description=nothing)

Update the status of span `s` by following the original specification. `description` is only considered when the `code` is `SPAN_STATUS_ERROR`. Only valid when the span is not ended yet.
"""
function set_status!(s::Span, code::SpanStatusCode, description=nothing)
    if is_end(s)
        @warn "the span is ended."
    else
        if s.status.code === OK
            # no further updates
        else
            if code === SPAN_STATUS_UNSET
                # ignore
            else
                s.status = StateStatus(code, description)
            end
        end
    end
end

"""
    update_name!(s::Span, name::String)

Update the name of span `s` with `name`. Only valid when the span is not ended yet.
"""
function update_name!(s::Span, name::String)
    if is_end(s)
        @warn "the span is ended."
    else
        s.name = name
    end
end

"""
    end!(s::Span, t=time())

Set the end time of the span.
"""
function end!(s::Span, t=time())
    if is_end(s)
        @warn "the span is ended"
    else
        s.end_time = t
    end
end

"""
    record_exception!(s::Span, ex::Exception, is_rethrow_followed=false)

A specialized variant of `add_event!` to record exceptions. Usually used in a `try... catch...end` to capture the backtrace. If the `ex` is `rethrow`ed in the `catch...end`, `is_rethrow_followed` should be set to `true`.
"""
function record_exception!(s::Span, ex::Exception, is_rethrow_followed=false)
    attrs = Attributes()

    attrs["exception.type"] = string(typeof(ex))

    msg_io = IOBuffer()
    showerror(msg_io, ex)
    attrs["exception.message"] = String(take!(msg_io))

    st_io = IOBuffer()
    showerror(st_io, CapturedException(ex, catch_backtrace()))
    attrs["exception.stacktrace"] = String(take!(st_io))
    attrs["exception.escaped"] = is_rethrow_followed

    add_event!(s, Event(name="exception", attributes=attrs))
end

struct NonRecordingSpan <: AbstractSpan
    span_context::SpanContext
end

for f in (:record_exception!, :end!, :update_name!, :set_status!, :add_event!)
    @eval $f(::NonRecordingSpan, args...) = nothing
end

Base.setindex!(::NonRecordingSpan, args...) = nothing
is_recording(::NonRecordingSpan) = false
span_context(s::NonRecordingSpan) = s.span_context

const INVALID_SPAN = NonRecordingSpan(INVALID_SPAN_CONTEXT)

"""
    current_span([current_context])

Get the span in the current context.
"""
current_span() = current_span(current_context())
current_span(ctx::Context) = get(ctx, SPAN_KEY, INVALID_SPAN)

#####
# Tracer
#####

abstract type AbstractTracer end

struct DefaultTracer <: AbstractTracer
end

"""
    create_span(name, t::AbstractTracer)

Create a new span based on tracer `t`.
"""
create_span(name, ::DefaultTracer) = INVALID_SPAN

"""
    with_span(f, s::AbstractSpan;kw...)

Call function `f` with the current span set to `s`.

# Keyword arguments

- `end_on_exit`, controls whether to call [`end!`](@ref) after `f` or not.
- `record_exception`, controls whether to record the exception.
- `set_status_on_exception`, decides whether to set status to [`SPAN_STATUS_ERROR`](@ref) automatically when an exception is caught.
"""
function with_span(
    f,
    s::AbstractSpan
    ;end_on_exit=true,
    record_exception=true,
    set_status_on_exception=true
)
    with_context(SPAN_KEY => s) do
        try
            f()
        catch ex
            if is_recording(s)
                if record_exception
                    record_exception!(s, ex, true)
                end
                if set_status_on_exception
                    set_status!(s, SPAN_STATUS_ERROR, string(ex))
                end
            end
            rethrow(ex)
        finally 
            if end_on_exit
                end!(s)
            end
        end
    end
end

"""
    with_span(f, name, t::AbstractTracer; kw...)

The same with `with_span(f, create_span(name, t; kw...); kw...)`.
"""
function with_span(
    f,
    name::String,
    t::AbstractTracer
    ;end_on_exit=true,
    record_exception=true,
    set_status_on_exception=true,
    kw...
)
    with_span(
        f,
        create_span(name, t; kw...)
        ;end_on_exit=end_on_exit,
        record_exception=record_exception,
        set_status_on_exception=set_status_on_exception
    )
end

#####
# TracerProvider
#####

abstract type AbstractTracerProvider end

struct DefaultTracerProvider <: AbstractTracerProvider
end

"""
    get_tracer([global_tracer_provider], name="", version="", schema_url="")

Generate a new tracer based on tracer provider.
"""
get_tracer(args...) = get_tracer(global_tracer_provider(), args...)
get_tracer(::DefaultTracerProvider, args...) = DefaultTracer()

const GLOBAL_TRACER_PROVIDER = Ref{AbstractTracerProvider}(DefaultTracerProvider())

"""
    global_tracer_provider(p::AbstractTracerProvider)

Set the global tracer provider to `p`.
"""
global_tracer_provider(p::AbstractTracerProvider) = GLOBAL_TRACER_PROVIDER[] = p

"""
    global_tracer_provider()

Get the global tracer provider.
"""
global_tracer_provider() = GLOBAL_TRACER_PROVIDER[]
