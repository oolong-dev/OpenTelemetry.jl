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
    is_shutdown::Bool # mutable
    max_queue_size::Int
    scheduled_delay_millis::Int
    export_timeout_millis::Int
    max_export_batch_size::Int
    export_event::Base.Event
    export_lock::ReentrantLock
    export_loop_task::Union{Nothing,Task}
end

function export_wrapper(bsp::BatchSpanProcessor)
    lock(bsp.export_lock) do
        batch_cond = true
        while batch_cond
            @debug("BatchSpanProcessor: Exporting batch")
            export!(bsp.exporter, take!(bsp.queue))
            batch_cond = has_maxExportBatchSize(bsp.queue)
        end
    end
    return nothing
end

function BatchSpanProcessor(
    exporter;
    max_queue_size = OTEL_BSP_MAX_QUEUE_SIZE(),
    scheduled_delay_millis = OTEL_BSP_SCHEDULE_DELAY(),
    export_timeout_millis = OTEL_BSP_EXPORT_TIMEOUT(),
    max_export_batch_size = OTEL_BSP_MAX_EXPORT_BATCH_SIZE(),
)
    queue = BatchContainer{OpenTelemetryAPI.AbstractSpan}(
        max_queue_size,
        max_export_batch_size,
    )
    bsp = BatchSpanProcessor(
        exporter,
        queue,
        false,
        max_queue_size,
        scheduled_delay_millis,
        export_timeout_millis,
        max_export_batch_size,
        Base.Event(true),
        ReentrantLock(),
        nothing
    )
    t = Threads.@spawn :default begin
        while !bsp.is_shutdown
            wait(bsp.export_event)
            batch_cond = has_maxExportBatchSize(bsp.queue) # check if has batchSize items
            !batch_cond && sleep(bsp.scheduled_delay_millis / 1_000) # only execute immediately when condition is set
            try
                export_wrapper(bsp)
            catch ex
                @error("Unexpected error in exporter", exception(ex, catch_backtrace()))
            end
        end
    end

    bsp.export_loop_task = t
    return bsp
end

on_start!(bsp::BatchSpanProcessor, span) = nothing

function on_end!(bsp::BatchSpanProcessor, span)
    if !bsp.is_shutdown
        is_full, was_empty = put!(bsp.queue, span)
        (was_empty || is_full) && notify(bsp.export_event)
    end
end

function Base.close(bsp::BatchSpanProcessor)
    close(bsp.exporter)
    bsp.is_shutdown = true
end

function Base.flush(bsp::BatchSpanProcessor)
    export_wrapper(bsp)
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