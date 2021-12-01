export AbstractTracerProvider,
    global_tracer_provider, Tracer, Span, with_span, is_recording, set_status!, end!

using Random

abstract type AbstractTracerProvider end

struct DummyTracerProvider <: AbstractTracerProvider end

const GLOBAL_TRACER_PROVIDER = Ref{AbstractTracerProvider}(DummyTracerProvider())

"""
get the global tracer provider
"""
global_tracer_provider() = GLOBAL_TRACER_PROVIDER[]

"""
set the global tracer provider to `p`
"""
global_tracer_provider(p) = GLOBAL_TRACER_PROVIDER[] = p

"""
    Tracer(;provider=global_tracer_provider(), instrumentation=InstrumentationInfo())

For instrumentation library developers, `instrumentation` must be configured clearly instead of the default value.
"""
Base.@kwdef struct Tracer{P<:AbstractTracerProvider}
    instrumentation::InstrumentationInfo = InstrumentationInfo()
    provider::P = global_tracer_provider()
end

struct Span{T<:Tracer,SC<:SpanContext}
    name::Ref{String}
    tracer::T
    span_context::SC
    parent_span_context::Union{Nothing,SpanContext}
    kind::SpanKind
    start_time::UInt
    end_time::Ref{Union{Nothing,UInt}}
    attributes::DynamicAttrs
    links::Limited{Vector{Link}}
    events::Limited{Vector{Event}}
    status::Ref{SpanStatus}
end

function Span(
    name::String,
    tracer::Tracer{DummyTracerProvider};
    context = current_context(),
    start_time = UInt(time() * 10^9),
)
    parent_span = current_span(context)
    parent_span_ctx = span_context(parent_span)
    if isnothing(parent_span_ctx)
        Span(
            Ref(name),
            tracer,
            INVALID_SPAN_CONTEXT,
            parent_span_ctx,
            SPAN_KIND_INTERNAL,
            start_time,
            Ref{Union{Nothing,UInt}}(start_time),
            DynamicAttrs(),
            Limited(Link[]),
            Limited(Event[]),
            Ref(SpanStatus(SPAN_STATUS_UNSET)),
        )
    else
        parent_span
    end
end

"""
    with_span(f, s::AbstractSpan;kw...)

Call function `f` with the current span set to `s`.

# Keyword arguments

  - `end_on_exit=true`, controls whether to call [`end!`](@ref) after `f` or not.
  - `record_exception=true`, controls whether to record the exception.
  - `set_status_on_exception=true`, decides whether to set status to [`SPAN_STATUS_ERROR`](@ref) automatically when an exception is caught.
"""
function with_span(
    f,
    s::Span;
    end_on_exit = true,
    record_exception = true,
    set_status_on_exception = true
)
    with_context(; SPAN_KEY_IN_CONTEXT => s) do
        try
            f()
        catch ex
            if is_recording(s)
                if record_exception
                    push!(s, ex; is_rethrow_followed = true)
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
    is_recording(s::Span)

Returns `true` if this span `s` is recording information like [`Event`](@ref) operations, attribute modification using [`setindex!`](@ref), etc.
"""
is_recording(s::Span) = isnothing(s.end_time[])

"""
    (s::Span)[key] = val

Set the attributes in span `s`. Only valid when the span is not ended yet.
"""
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

"""
    set_status!(s::Span, code::SpanStatusCode, description=nothing)

Update the status of span `s` by following the original specification. `description` is only considered when the `code` is `SPAN_STATUS_ERROR`. Only valid when the span is not ended yet.
"""
function set_status!(s::Span, code::SpanStatusCode, description = nothing)
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

"""
    end!(s::Span, t=UInt(time()*10^9))

Set the end time of the span and trigger span processors.
"""
function end!(s::Span{Tracer{DummyTracerProvider}}, t = UInt(time() * 10^9))
    if is_recording(s)
        s.end_time[] = t
    else
        @warn "the span is not recording."
    end
end

"""
A specialized variant of `add_event!` to record exceptions. Usually used in a `try... catch...end` to capture the backtrace. If the `ex` is `rethrow`ed in the `catch...end`, `is_rethrow_followed` should be set to `true`.
"""
function Base.push!(s::Span, ex::Exception; is_rethrow_followed = false)
    msg_io = IOBuffer()
    showerror(msg_io, ex)
    msg = String(take!(msg_io))

    st_io = IOBuffer()
    showerror(st_io, CapturedException(ex, catch_backtrace()))
    st = String(take!(st_io))

    attrs = StaticAttrs((
        ; Symbol("exception.type") => string(typeof(ex)),
        Symbol("exception.type") => string(typeof(ex)),
        Symbol("exception.message") => msg,
        Symbol("exception.stacktrace") => st,
        Symbol("exception.escaped") => is_rethrow_followed
    )
    )

    push!(s, Event(name = "exception", attributes = attrs))
end
