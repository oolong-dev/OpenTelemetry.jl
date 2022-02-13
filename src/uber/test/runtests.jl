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

with_span("test download") do
    download("https://julialang.org")
    download("http://localhost:9966")  # Prometheus
    download("http://localhost:1234")  # throw exception
end
