using OpenTelemetryExporterOtlpProtoHttp
using OpenTelemetrySDK
using OpenTelemetryProto

using Logging

span_exporter = InMemoryExporter()
log_exporter = InMemoryExporter()
logger = BatchLogger(log_exporter)

global_tracer_provider(
    TracerProvider(
        span_processor = CompositSpanProcessor(SimpleSpanProcessor(span_exporter)),
    ),
)

with_logger(logger) do
    with_span("foo") do
        @debug "Hi!!!"
        with_span("bar") do
            @info "Hello!!!" foo = "foo"
            with_span("baz") do
                @warn "World!!!" bar = "bar"
                @error "!!!!!"
            end
        end
    end
end

# otlp = OtlpHttpLogsExporter()
# export!(otlp, exporter.pool)

# flush(logger)
# convert(
#     OpenTelemetryProto.opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest,
#     log_exporter.pool,
# )

flush(global_tracer_provider())
convert(
    OpenTelemetryProto.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest,
    span_exporter.pool,
)