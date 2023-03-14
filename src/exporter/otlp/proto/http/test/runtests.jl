using OpenTelemetryExporterOtlpProtoHttp
using OpenTelemetrySDK
using Logging

global_tracer_provider(
    TracerProvider(
        span_processor = CompositSpanProcessor(SimpleSpanProcessor(InMemoryExporter())),
    ),
)

exporter = InMemoryExporter()
with_logger(BatchLogger(exporter)) do
    with_span("Julia") do
        @debug "Hi!!!"
        @info "Hello!!!" foo = "foo"
        @warn "World!!!" bar = "bar"
        @error "!!!!!"
    end
end

otlp = OtlpHttpLogsExporter()

using OpenTelemetryProto

# export!(otlp, exporter.pool)
convert(
    OpenTelemetryProto.opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest,
    exporter.pool,
)