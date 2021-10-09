export MultiSpanProcessor, SimpleSpanProcessor

abstract type AbstractSpanProcessor end

struct MultiSpanProcessor <: AbstractSpanProcessor
    span_processors::Vector
    is_spawn::Bool
    MultiSpanProcessor(ps...;is_spawn=true) = new([ps...], is_spawn)
end

for f in (:on_start, :on_end, :shutdown!)
    @eval function $f(sp::MultiSpanProcessor, args...)
        # ??? spawn
        for p in sp.span_processors
            $f(p, args...)
        end
    end
end

function Common.force_flush!(sp::MultiSpanProcessor, timeout_millis=30_000)
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

struct SimpleSpanProcessor{T} <: AbstractSpanProcessor
    span_exporter::T
end

on_start(ssp::SimpleSpanProcessor, span) = nothing

function on_end(ssp::SimpleSpanProcessor, span::API.AbstractSpan)
    if span_context(span).trace_flag.sampled
        export!(ssp.span_exporter, span)
    end
end

Common.shut_down!(ssp::SimpleSpanProcessor) = shut_down!(ssp.span_exporter)

Common.force_flush!(ssp::SimpleSpanProcessor, args...) = true

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
    on_end(s.span_processor, s)
end
