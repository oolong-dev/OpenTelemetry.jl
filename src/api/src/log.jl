export OtelLogTransformer, LogRecord

using Logging
using Dates

"""
    LogRecord(;kw...)

A Julia representation of the [Log Data Model](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/logs/data-model.md#log-and-event-record-definition).
"""
Base.@kwdef struct LogRecord{B,R<:Resource,A<:BoundedAttributes}
    timestamp::UInt
    observed_timestamp::UInt
    trace_id::TraceIdType
    span_id::SpanIdType
    trace_flags::TraceFlag
    severity_text::String
    severity_number::Int
    body::B
    resource::R
    instrumentation_info::InstrumentationInfo
    attributes::A
end

"""
    OtelLogTransformer(resource::Resource)

It can be used as a function `f` to the [`TransformerLogger`](https://github.com/JuliaLogging/LoggingExtras.jl#transformerlogger-transformer).
After applying this transformer, a [`LogRecord`](@ref) will be returned.
"""
Base.@kwdef struct OtelLogTransformer{R<:Resource}
    resource::R = Resource()
    instrumentation_info::InstrumentationInfo = InstrumentationInfo()
end

function (L::OtelLogTransformer)(log)
    span_ctx = span_context()
    ts = UInt(time() * 10^9)
    merge(
        log,
        (
            message = LogRecord(;
                timestamp = ts,
                observed_timestamp = ts,
                trace_id = isnothing(span_ctx) ? INVALID_TRACE_ID : span_ctx.trace_id,
                span_id = isnothing(span_ctx) ? INVALID_SPAN_ID : span_ctx.span_id,
                trace_flags = isnothing(span_ctx) ? TraceFlag() : span_ctx.trace_flag,
                severity_text = uppercase(string(log.level)),
                # https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/logs/data-model.md#field-severitynumber
                severity_number = if log.level >= Logging.Error
                    17
                elseif log.level >= Logging.Warn
                    13
                elseif log.level >= Logging.Info
                    9
                elseif log.level >= Logging.Debug
                    5
                else
                    1
                end,
                body = log.message,
                resource = L.resource,
                instrumentation_info = L.instrumentation_info,
                attributes = BoundedAttributes(NamedTuple(log.kwargs)),
            ),
            kwargs = NamedTuple(),
        ),
    )
end
