using OpenTelemetryUber

OpenTelemetryUber.init(
    meter_provider = MeterProvider(),
    tracer_provider = TracerProvider(;
        span_processor = CompositSpanProcessor(SimpleSpanProcessor(ConsoleExporter())),
    ),
)

reader = MetricReader(ConsoleExporter())
reader()