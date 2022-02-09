export AbstractSpanProcessor, CompositSpanProcessor, SimpleSpanProcessor

"""
Each span processor must implement the following methods:

  - [`on_start!(span_processor::AbstractSpanProcessor, span::AbstractSpan)`](@ref)
  - [`on_end!(span_processor::AbstractSpanProcessor, span::AbstractSpan)`](@ref)
  - [`shut_down!(span_processor::AbstractSpanProcessor)`](@ref)
  - [`force_flush!(span_processor::AbstractSpanProcessor)`](@ref)
"""
abstract type AbstractSpanProcessor end

"""
    CompositSpanProcessor(processors...)

A wrapper of different concrete span processors. Users can also `push!` new span processors into it after construction.

See also [`SimpleSpanProcessor`](@ref).
"""
struct CompositSpanProcessor <: AbstractSpanProcessor
    span_processors::Vector{Any}
    function CompositSpanProcessor(ps...)
        new([ps...])
    end
end

for f in (:on_start!, :on_end!, :shut_down!)
    @eval function $f(sp::CompositSpanProcessor, args...)
        # ??? spawn
        for p in sp.span_processors
            $f(p, args...)
        end
    end
end

function force_flush!(sp::CompositSpanProcessor, timeout_millis = 30_000)
    res = fill(false, length(sp.span_processors))
    @sync for (i, p) in enumerate(sp.span_processors)
        @async res[i] = force_flush!(p, timeout_millis)
    end
    all(res)
end

Base.push!(sp::CompositSpanProcessor, p::AbstractSpanProcessor) =
    push!(sp.span_processors, p)

#####

"""
    SimpleSpanProcessor(span_exporter)

Export each span immediately when [`on_end!`](@ref) is called on this processor.
"""
struct SimpleSpanProcessor{T} <: AbstractSpanProcessor
    span_exporter::T
end

"""
    on_start!(ssp::SimpleSpanProcessor, span)
"""
on_start!(ssp::SimpleSpanProcessor, span) = nothing

"""
    on_end!(ssp::SimpleSpanProcessor, span)

The `span` is exported immediately if it is sampled.
"""
function on_end!(ssp::SimpleSpanProcessor, span)
    if span_context(span).trace_flag.sampled
        export!(ssp.span_exporter, [span])
    end
end

shut_down!(ssp::SimpleSpanProcessor) = shut_down!(ssp.span_exporter)

force_flush!(ssp::SimpleSpanProcessor, args...) = force_flush!(ssp.span_exporter)

#####

# TODO: BatchSpanProcessor