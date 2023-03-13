export BatchLogger

using Logging

struct BatchLogger{E<:AbstractExporter,T<:OtelLogTransformer} <: AbstractLogger
    exporter::E
    transformer::T
    queue::BatchContainer{LogRecord}
    timer::Ref{Timer}
    is_shutdown::Ref{Bool}
    max_queue_size::Int
    scheduled_delay_millis::Int
    export_timeout_millis::Int
    max_export_batch_size::Int
end

function reset_timer!(bl::BatchLogger)
    bl.timer[] = Timer(bl.scheduled_delay_millis / 1_000) do t
        export!(bl.exporter, take!(bl.queue))
        close(t)
        reset_timer!(bl)
    end
end

"""
    BatchLogger(exporter;kw...)

`BatchLogger` is a `Sink` (see [LoggingExtras.jl](https://github.com/JuliaLogging/LoggingExtras.jl) to understand the concept).  Note that it will create a [`OtelLogTransformer`](@ref) on construction and apply it automatically on each log message.

# Keyword arguments

  - `max_queue_size=nothing`
  - `scheduled_delay_millis = nothing`
  - `export_timeout_millis = nothing`
  - `max_export_batch_size = nothing`
  - `resource = Resource()`
  - `instrumentation_scope = InstrumentationScope()`
"""
function BatchLogger(
    exporter;
    max_queue_size = nothing,
    scheduled_delay_millis = nothing,
    export_timeout_millis = nothing,
    max_export_batch_size = nothing,
    resource = Resource(),
    instrumentation_scope = InstrumentationScope(),
)
    max_queue_size = something(max_queue_size, OTEL_BLRP_MAX_QUEUE_SIZE())
    scheduled_delay_millis = something(scheduled_delay_millis, OTEL_BLRP_SCHEDULE_DELAY())
    export_timeout_millis = something(export_timeout_millis, OTEL_BLRP_EXPORT_TIMEOUT())
    max_export_batch_size =
        something(max_export_batch_size, OTEL_BLRP_MAX_EXPORT_BATCH_SIZE())

    queue = BatchContainer(Array{LogRecord}(undef, max_queue_size), max_export_batch_size)
    bl = BatchLogger(
        exporter,
        OtelLogTransformer(resource, instrumentation_scope),
        queue,
        Ref{Timer}(),
        Ref(false),
        max_queue_size,
        scheduled_delay_millis,
        export_timeout_millis,
        max_export_batch_size,
    )
    reset_timer!(bl)
    bl
end

Logging.shouldlog(l::BatchLogger, args...; kw...) = true
Logging.min_enabled_level(l::BatchLogger, args...; kw...) = Logging.BelowMinLevel
Logging.catch_exceptions(l::BatchLogger, args...; kw...) = true

# [function handle_message_args(args...; kwargs...)](https://github.com/JuliaLogging/LoggingExtras.jl/blob/1bf42b8939b9d9014bb315ee9bd40786f0a39c79/src/CompositionalLoggers/activefiltered.jl#L65-L69)
function handle_message_args(args...; kwargs...)
    fieldnames = (:level, :message, :_module, :group, :id, :file, :line, :kwargs)
    fieldvals = (args..., kwargs)
    return NamedTuple{fieldnames,typeof(fieldvals)}(fieldvals)
end

function Logging.handle_message(bl::BatchLogger, args...; kw...)
    r = bl.transformer(handle_message_args(args...; kw...))
    if !bl.is_shutdown[]
        is_full = put!(bl.queue, r.message)
        if is_full
            export!(bl.exporter, take!(bl.queue))
            reset_timer!(bl)
        end
    end
end

function Base.close(bl::BatchLogger)
    close(bl.exporter)
    bl.is_shutdown[] = true
    close(bl.timer[])
end

function Base.flush(bl::BatchLogger)
    export!(bl.exporter, take!(bl.queue))
    flush(bl.exporter)
end
