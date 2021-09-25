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