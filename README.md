# OpenTelemetry.jl

An *unofficial* implementation of [OpenTelemetry](https://opentelemetry.io/) in Julia.

## Progress

- API
    - [x] Tracing
    - [ ] Baggage
    - [ ] Metrics

- SDK
    - [x] Tracing
    - [x] Resource

- Instrumentation
    - [ ] HTTP.jl

## Get Started

### Traces

To show traces in your console:

```julia
using OpenTelemetryAPI
using OpenTelemetrySDK

global_tracer_provider(
    TracerProvider(
        span_processor=CompositSpanProcessor(
            SimpleSpanProcessor(
                ConsoleExporter()
            )
        )
    )
)

tracer = get_tracer("test")

with_span("foo", tracer) do
    with_span("bar", tracer) do
        with_span("baz", tracer) do
            println("Hello world!")
        end
    end
end
```

To send traces to OpenTelemetry Collector:

```julia
using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryExporterOtlpProtoGrpc

global_tracer_provider(
    TracerProvider(
        span_processor=CompositSpanProcessor(
            SimpleSpanProcessor(
                OtlpProtoGrpcExporter(;url="http://localhost:4317")
            )
        )
    )
)

tracer = get_tracer("test")

with_span("foo", tracer) do
    with_span("bar", tracer) do
        with_span("baz", tracer) do
            println("Hello world!")
        end
    end
end
```

### Metrics

```julia
using OpenTelemetryAPI
using OpenTelemetrySDK

p = MetricProvider()
m = Meter(p, "my_metrics")
c = Counter(m)
inc!(c)
```