export SimpleSpanProcessor, BatchSpanProcessor, CompositSpanProcessor

"""
Each span processor must implement the following methods:

  - [`on_start!(span_processor::AbstractSpanProcessor, span::AbstractSpan)`](@ref)
  - [`on_end!(span_processor::AbstractSpanProcessor, span::AbstractSpan)`](@ref)
  - [`close(span_processor::AbstractSpanProcessor)`](@ref)
  - [`flush(span_processor::AbstractSpanProcessor)`](@ref)
"""
abstract type AbstractSpanProcessor end

#####

"""
    SimpleSpanProcessor(exporter)

Export each span immediately when [`on_end!`](@ref) is called on this processor.
"""
struct SimpleSpanProcessor{T} <: AbstractSpanProcessor
    exporter::T
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
        export!(ssp.exporter, [span])
    end
end

Base.close(ssp::SimpleSpanProcessor) = close(ssp.exporter)

Base.flush(ssp::SimpleSpanProcessor) = flush(ssp.exporter)

#####

# TODO: BatchSpanProcessor
# https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/sdk.md#batching-processor

"""
    BatchSpanProcessor(exporter;kw...)

# Keyword arguments

  - `max_queue_size`
  - `scheduled_delay_millis`
  - `export_timeout_millis`
  - `max_export_batch_size`

The default values of above keyword arugments are read from corresponding environment variables.
"""
mutable struct BatchSpanProcessor{T} <: AbstractSpanProcessor
    exporter::T
    queue::BatchContainer{<:OpenTelemetryAPI.AbstractSpan}
    timer::Timer # mutable
    is_shutdown::Bool # mutable
    max_queue_size::Int
    scheduled_delay_millis::Int
    export_timeout_millis::Int
    max_export_batch_size::Int
end

function reset_timer!(bsp::BatchSpanProcessor)
    bsp.timer = Timer(bsp.scheduled_delay_millis / 1_000) do t
        export!(bsp.exporter, take!(bsp.queue))
        close(t)
        reset_timer!(bsp)
    end
end

function BatchSpanProcessor(
    exporter;
    max_queue_size = OTEL_BSP_MAX_QUEUE_SIZE(),
    scheduled_delay_millis = OTEL_BSP_SCHEDULE_DELAY(),
    export_timeout_millis = OTEL_BSP_EXPORT_TIMEOUT(),
    max_export_batch_size = OTEL_BSP_MAX_EXPORT_BATCH_SIZE(),
)
    queue = BatchContainer(
        Array{OpenTelemetryAPI.AbstractSpan}(undef, max_queue_size),
        max_export_batch_size,
    )
    bsp = BatchSpanProcessor(
        exporter,
        queue,
        Timer(0),
        false,
        max_queue_size,
        scheduled_delay_millis,
        export_timeout_millis,
        max_export_batch_size,
    )
    reset_timer!(bsp)
    bsp
end

on_start!(bsp::BatchSpanProcessor, span) = nothing

function on_end!(bsp::BatchSpanProcessor, span)
    if !bsp.is_shutdown
        is_full = put!(bsp.queue, span)
        if is_full
            export!(bsp.exporter, take!(bsp.queue))
            reset_timer!(bsp)
        end
    end
end

function Base.close(bsp::BatchSpanProcessor)
    close(bsp.exporter)
    bsp.is_shutdown = true
    close(bsp.timer)
end

function Base.flush(bsp::BatchSpanProcessor)
    export!(bsp.exporter, take!(bsp.queue))
    flush(bsp.exporter)
end

#####

"""
    CompositSpanProcessor(processors...)

A wrapper of different concrete span processors. Users can also `push!` new span processors into it after construction.
See also [`SimpleSpanProcessor`](@ref).
"""
struct CompositSpanProcessor <: AbstractSpanProcessor
    span_processors::Vector{AbstractSpanProcessor}
    function CompositSpanProcessor(ps...)
        new(AbstractSpanProcessor[ps...])
    end
end

for f in (:on_start!, :on_end!)
    @eval function $f(sp::CompositSpanProcessor, args...)
        # ??? spawn
        for p in sp.span_processors
            $f(p, args...)
        end
    end
end

for f in (:close, :flush)
    @eval function Base.$f(sp::CompositSpanProcessor, args...)
        # ??? spawn
        for p in sp.span_processors
            $f(p, args...)
        end
    end
end

for f in (:push!, :pop!, :empty!, :getindex, :setindex!)
    @eval function Base.$f(sp::CompositSpanProcessor, args...)
        $f(sp.span_processors, args...)
    end
end