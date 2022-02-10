export AbstractTracerProvider,
    global_tracer_provider,
    global_tracer_provider!,
    Tracer,
    AbstractSpan,
    with_span,
    span_context,
    is_recording,
    span_status!,
    end_span!,
    span_name!,
    span_name,
    span_links,
    span_events,
    span_status

"""
A tracer provider is a part of an [`Tracer`](@ref). For each concrete tracer
provider, `OpenTelemetryAPI.create_span(name::String, tracer::Tracer{<:YourCustomProvider})` should also be implemented.
"""
abstract type AbstractTracerProvider end

struct DummyTracerProvider <: AbstractTracerProvider end

const GLOBAL_TRACER_PROVIDER = Ref{AbstractTracerProvider}(DummyTracerProvider())

"""
    global_tracer_provider()

Get the global tracer provider.
"""
global_tracer_provider() = GLOBAL_TRACER_PROVIDER[]

"""
    global_tracer_provider!(p)

Set the global tracer provider to `p`.
"""
global_tracer_provider!(p) = GLOBAL_TRACER_PROVIDER[] = p

struct Tracer{P<:AbstractTracerProvider}
    instrumentation::InstrumentationInfo
    provider::P
end

"""
    Tracer(name="Main", version=v"0.0.1-dev";provider=global_tracer_provider())

The `name` and `version` will form the [`InstrumentationInfo`](@ref).
value.
"""
function Tracer(name = "Main", version = v"0.0.1-dev"; provider = global_tracer_provider())
    Tracer(InstrumentationInfo(name, version), provider)
end

"""
Each concrete span should have the following interfaces implemented.

  - [`span_context`](@ref)
  - [`is_recording`](@ref)
  - [`Base.setindex!(s::AbstractSpan, val, key)`](@ref)
  - [`Base.getindex(s::AbstractSpan, key)`](@ref)
  - [`Base.haskey(s::AbstractSpan, key)`](@ref)
  - [`Base.push!(s::AbstractSpan, event::Event)`](@ref)
  - [`Base.push!(s::AbstractSpan, link::Link)`](@ref)
  - [`Base.push!(s::AbstractSpan, ex::Exception; is_rethrow_followed = false)`](@ref)
  - [`end_span!`](@ref)
  - [`span_status!`](@ref)
  - [`span_status`](@ref)
  - [`span_name!`](@ref)
  - [`span_name`](@ref)
  - [`span_links`](@ref)
  - [`span_events`](@ref)
"""
abstract type AbstractSpan end

struct NonRecordingSpan <: AbstractSpan
    name::String
    span_context::SpanContext
    parent_span_context::Union{Nothing,SpanContext}
end

"""
    is_recording([current_span()])

Returns `true` if this span `s` is recording information like [`Event`](@ref) operations, attribute modification using [`setindex!`](@ref), etc.
"""
is_recording() = is_recording(current_span())
is_recording(s::NonRecordingSpan) = false

"""
    (s::AbstractSpan)[key] = val

Set the attributes in span `s`. Only valid when the span is not ended yet.
"""
Base.setindex!(::NonRecordingSpan, val, key) = @warn "the span is not recording."

"""
    Base.getindex(s::AbstractSpan, key)

Look up `key` in the attributes of the span `s`.
"""
Base.getindex(s::NonRecordingSpan, key) = throw(KeyError(key))

"""
    Base.haskey(s::AbstractSpan, key)

Check if the span `s` has the key in its attributes.
"""
Base.haskey(s::NonRecordingSpan, key) = false

"""
    Base.push!([s::AbstractSpan], event::Event)

Add an [`Event`](@ref) into the span `s`.
"""
Base.push!(event::Event) = push!(current_span(), event)
Base.push!(s::NonRecordingSpan, event::Event) = @warn "the span is not recording."

"""
    span_events(s::AbstractSpan)

Get the recorded events in a span.
"""
span_events() = span_events(current_span())
span_events(s::NonRecordingSpan) = Event[]

"""
    Base.push!([current_span()], link::Link)

Add a [`Link`](@ref) into the span `s`.
"""
Base.push!(link::Link) = push!(current_span(), link)
Base.push!(s::NonRecordingSpan, link::Link) = @warn "the span is not recording."

"""
    span_links(s::AbstractSpan)

Get the recorded links in a span.
"""
span_links() = span_links(current_span())
span_links(s::NonRecordingSpan) = Link[]

"""
    span_status!([current_span()], code::SpanStatusCode, description=nothing)

Update the status of span `s` by following the original specification. `description` is only considered when the `code` is `SPAN_STATUS_ERROR`. Only valid when the span is not ended yet.
"""
span_status!(code::SpanStatusCode, description) =
    span_status!(current_span(), code, description)
span_status!(s::NonRecordingSpan, code::SpanStatusCode, description = nothing) =
    @warn "the span is not recording."

"""
    span_status([current_span()])

Get status of the span. A [`SpanStatusCode`](@ref) is returned.
"""
span_status() = span_status(current_span())
span_status(s::NonRecordingSpan) = SpanStatus(SPAN_STATUS_UNSET)

"""
    end_span!([s=current_span()], [t=UInt(time()*10^9)])

Set the end time of the span and trigger span processors. Note `t` is the nanoseconds.
"""
end_span!() = end_span!(current_span())
end_span!(s::AbstractSpan) = end_span!(s, UInt(time() * 10^9))
end_span!(s::NonRecordingSpan) = @warn "the span is not recording."
end_span!(s::NonRecordingSpan, t) = @warn "the span is not recording."

"""
    Base.push!(s::AbstractSpan, ex::Exception; is_rethrow_followed = false)

A specialized variant of [`add_event!`](@ref) to record exceptions. Usually used in a `try... catch...end` to capture the backtrace. If the `ex` is `rethrow`ed in the `catch...end`, `is_rethrow_followed` should be set to `true`.
"""
Base.push!(s::NonRecordingSpan, ex::Exception; is_rethrow_followed = false) =
    @warn "the span is not recording."

"""
    span_name([current_span()])
"""
span_name() = span_name(current_span())
span_name(s::NonRecordingSpan) = s.name

"""
    span_name!([current_span()], name::String)
"""
span_name!(name::String) = span_name!(current_span(), name)
span_name!(s::NonRecordingSpan, name::String) = @warn "the span is not recording."

#####

"""
    span_context([s::AbstractSpan])

Get the [`SpanContext`](@ref) from a span `s`. If `s` is not specified,
[`current_span()`](@ref) will be used. `nothing` is returned if no span context
found.
"""
span_context() = span_context(current_span())
span_context(::Nothing) = nothing
span_context(s::NonRecordingSpan) = s.span_context

"""
Here we follow the [Behavior of the API in the absence of an installed SDK](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#behavior-of-the-api-in-the-absence-of-an-installed-sdk).
"""
function create_span(
    name::String,
    tracer::Tracer{DummyTracerProvider};
    context = current_context(),
    kw...,
)
    parent_span = current_span(context)
    if isnothing(parent_span)
        NonRecordingSpan(name, INVALID_SPAN_CONTEXT, nothing)
    elseif is_recording(parent_span)
        parent_span_ctx = span_context(parent_span)
        NonRecordingSpan(name, parent_span_ctx, parent_span_ctx)
    else
        parent_span
    end
end

"""
    with_span(f, name::String, tracer::Tracer;kw...)

Call function `f` with the current span set to `s`.

# Keyword arguments

  - `end_on_exit=true`, controls whether to call [`end_span!`](@ref) after `f` or not.
  - `record_exception=true`, controls whether to record the exception.
  - `set_status_on_exception=true`, decides whether to set status to [`SPAN_STATUS_ERROR`](@ref) automatically when an exception is caught.
"""
function with_span(
    f,
    name::String,
    tracer::Tracer;
    end_on_exit = true,
    record_exception = true,
    set_status_on_exception = true,
)
    s = create_span(name, tracer)
    with_context(; SPAN_KEY_IN_CONTEXT => s) do
        try
            f()
        catch ex
            if is_recording(s)
                if record_exception
                    push!(s, ex; is_rethrow_followed = true)
                end
                if set_status_on_exception
                    span_status!(s, SPAN_STATUS_ERROR, string(ex))
                end
            end
            rethrow(ex)
        finally
            if end_on_exit
                end_span!(s)
            end
        end
    end
end
