export MultiSpanProcessor,
    SimpleSpanProcessor,
    InMemorySpanExporter,
    ConsoleSpanExporter

using GarishPrint: pprint

abstract type AbstractSpanProcessor end

struct MultiSpanProcessor <: AbstractSpanProcessor
    span_processors::Vector
    is_spawn::Bool
    MultiSpanProcessor(ps...;is_spawn=true) = new([ps...], is_spawn)
end

for f in (:on_start, :on_end, :shutdown!)
    @eval function $f(sp::MultiSpanProcessor, args...)
        @sync for p in sp.span_processors
            if sp.is_spawn
                Threads.@spawn $f(p, args...)
            else
                @async $f(p, args...)
            end
        end
    end
end

function force_flush!(sp::MultiSpanProcessor, timeout_millis=30_000)
    res = fill(false, length(sp.span_processors))
    @sync for (i,p) in enumerate(sp.span_processors)
        if sp.is_spawn
            Threads.@spawn res[i] = force_flush!(p, timeout_millis)
        else
            @async res[i] = force_flush!(p, timeout_millis)
        end
    end
    res
end

abstract type AbstractSpanExporter end

function export!(se::AbstractSpanExporter, sp::Vector{<:API.AbstractSpan})
    res = SUCCESS
    for s in sp
        r = export!(se, s)
        if r === FAILURE
            res = FAILURE
        end
    end
    res
end

@enum SpanExportResult begin
    SUCCESS
    FAILURE
end

Base.@kwdef struct InMemorySpanExporter <: AbstractSpanExporter
    finished_spans::Vector = []
    is_shut_down::Ref{Bool} = Ref(false)
end

Base.empty!(se::InMemorySpanExporter) = empty!(se.finished_spans)

shut_down!(se::InMemorySpanExporter) = se.is_shut_down[] = true

function export!(se::InMemorySpanExporter, sp::API.AbstractSpan)
    if se.is_shut_down[]
        FAILURE
    else
        push!(se.finished_spans, sp)
        SUCCESS
    end
end

Base.@kwdef struct ConsoleSpanExporter <: AbstractSpanExporter
    io::IO = stdout
end

function export!(se::ConsoleSpanExporter, sp::API.AbstractSpan)
    pprint(se.io, sp)
    println(se.io)
    SUCCESS
end

function export!(se::ConsoleSpanExporter, sp::Vector{<:API.AbstractSpan})
    for s in sp
        pprint(se.io, s)
        println(se.io)
    end
    SUCCESS
end

struct SimpleSpanProcessor <: AbstractSpanProcessor
    span_exporter
end

on_start(ssp::SimpleSpanProcessor, span) = nothing

function on_end(ssp::SimpleSpanProcessor, span::API.AbstractSpan)
    if span.span_context.trace_flag.sampled
        export!(ssp.span_exporter, span)
    end
end

shut_down!(ssp::SimpleSpanProcessor) = shut_down!(ssp.span_exporter)

force_flush!(ssp::SimpleSpanProcessor, args...) = true

struct WrappedSpan <: API.AbstractSpan
    span::Span
    span_processor::MultiSpanProcessor
    instrumentation_info::InstrumentationInfo
    resource::Resource
    function WrappedSpan(
        ;span_processor,
        instrumentation_info,
        resource,
        kw...
    )
        sp = Span(;kw...)
        sw = new(sp, span_processor, instrumentation_info, resource)
        on_start(span_processor, sp)
        sw
    end
end

for f in (:record_exception!, :update_name!, :set_status!, :add_event!, :is_recording, :span_context)
    @eval API.$f(s::WrappedSpan, args...;kw...) = $f(s.span, args...;kw...)
end

Base.setindex!(s::WrappedSpan, args...) = setindex!(s.span, args...)

function API.end!(s::WrappedSpan)
    end!(s.span)
    on_end(s.span_processor, s.span)
end
