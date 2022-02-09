
struct Span{P<:AbstractTracerProvider} <: AbstractSpan
    name::Ref{String}
    tracer::Tracer{P}
    span_context::SpanContext
    parent_span_context::Union{Nothing,SpanContext}
    kind::SpanKind
    start_time::UInt
    end_time::Ref{Union{Nothing,UInt}}
    attributes::DynamicAttrs
    links::Vector{Link}
    events::Vector{Event}
    status::Ref{SpanStatus}
end

is_recording(s::Span) = isnothing(s.end_time[])

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

function end!(s::Span, t)
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

function set_name!(s::Span, name::String)
    if is_recording(s)
        s.name[] = name
    else
        @warn "the span is not recording."
    end
end

span_context(s::Span) = s.span_context