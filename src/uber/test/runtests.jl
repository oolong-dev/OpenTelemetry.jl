using Test
using Downloads

using OpenTelemetryUber

OpenTelemetryUber.init(
    meter_provider = MeterProvider(),
    tracer_provider = TracerProvider(;
        span_processor = CompositSpanProcessor(SimpleSpanProcessor(ConsoleExporter()))
    ),
)

console_metric_reader = MetricReader(ConsoleExporter())
console_metric_reader()

in_memory_metric_reader = MetricReader(InMemoryExporter())
in_memory_metric_reader()

prometheus_metric_reader = MetricReader(PrometheusExporter())

@test_throws Downloads.RequestError with_span("test download") do
    Downloads.download("https://julialang.org")
    Downloads.download("http://localhost:9966")  # Prometheus
    Downloads.download("http://localhost:1234")  # throw exception
end