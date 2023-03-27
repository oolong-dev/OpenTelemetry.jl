using OpenTelemetry
using HTTP
using OpenTelemetrySDK.OpenTelemetrySDKHTTPExt
using Logging

global_logger(OtelBatchLogger(OtlpHttpLogsExporter()))
global_tracer_provider(
    TracerProvider(span_processor = BatchSpanProcessor(OtlpHttpTracesExporter())),
)
global_meter_provider(MeterProvider())

READER = PeriodicMetricReader(
    MetricReader(OtlpHttpMetricsExporter());
    export_interval_seconds = 5,
)

instrument!(HTTP)

route =
    HTTP.Router(HTTP.Handlers.default404, HTTP.Handlers.default405, otel_http_middleware)
HTTP.register!(route, "/", req -> (@info "hello"; HTTP.Response(200, "world")))

server = HTTP.serve!(route, "127.0.0.1", 8122)

# simulate client requests

for i in 1:3
    @info "Sending $(i) requests ..."
    HTTP.get("http://localhost:8122")
    sleep(1)
end

sleep(10)
