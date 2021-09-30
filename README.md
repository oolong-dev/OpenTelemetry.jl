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

To show traces in your console:

```julia
using OpenTelemetryAPI
using OpenTelemetrySDK

global_tracer_provider(
    TracerProvider(
        span_processor=MultiSpanProcessor(
            SimpleSpanProcessor(
                ConsoleSpanExporter()
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
        span_processor=MultiSpanProcessor(
            SimpleSpanProcessor(
                OtlpProtoGrpcExporter()
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