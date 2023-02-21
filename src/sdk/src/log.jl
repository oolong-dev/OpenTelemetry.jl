export BatchLogger

using Logging

"""
    BatchLogger(logger;kw...)
"""
struct BatchLogger{E<:AbstractExporter} <: AbstractLogger
    exporter::E
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

function BatchLogger(
    exporter;
    max_queue_size = nothing,
    scheduled_delay_millis = nothing,
    export_timeout_millis = nothing,
    max_export_batch_size = nothing,
)
    max_queue_size = something(max_queue_size, OTEL_BLRP_MAX_QUEUE_SIZE())
    scheduled_delay_millis = something(scheduled_delay_millis, OTEL_BLRP_SCHEDULE_DELAY())
    export_timeout_millis = something(export_timeout_millis, OTEL_BLRP_EXPORT_TIMEOUT())
    max_export_batch_size =
        something(max_export_batch_size, OTEL_BLRP_MAX_EXPORT_BATCH_SIZE())

    queue = BatchContainer(
        Array{OpenTelemetryAPI.AbstractSpan}(undef, max_queue_size),
        max_export_batch_size,
    )
    bl = BatchLogger(
        exporter,
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

function Logging.handle_message(bl::BatchLogger, r::LogRecord)
    if !bl.is_shutdown[]
        is_full = put!(bl.container, r)
        if is_full
            export!(bl.exporter, take!(bl.container))
            reset_timer!(bl)
        end
    end
end

function shut_down!(bl::BatchLogger)
    shut_down!(bl.exporter)
    bl.is_shutdown[] = true
    close(bl.timer[])
end

function force_flush!(bl::BatchLogger)
    export!(bl.exporter, take!(bl.container))
    force_flush!(bl.exporter)
end
