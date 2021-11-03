# OpenTelemetry.jl

[![CI](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl/branch/master/graph/badge.svg?token=A3DMIK8K58)](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


An *unofficial* implementation of [OpenTelemetry](https://opentelemetry.io/) in Julia.

## Packages

| Package | Latest Version | Status |
|:--------|:---------------|:-------|
|`OpenTelemetryAPI` | [![version](https://juliahub.com/docs/OpenTelemetryAPI/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryAPI/p4SiN) | [![pkgeval](https://juliahub.com/docs/OpenTelemetryAPI/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetryAPI/p4SiN) |
| `OpenTelemetrySDK` | [![version](https://juliahub.com/docs/OpenTelemetrySDK/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetrySDK/NFHPX) | [![pkgeval](https://juliahub.com/docs/OpenTelemetrySDK/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetrySDK/NFHPX) |
| `OpenTelemetryProto` | [![version](https://juliahub.com/docs/OpenTelemetryProto/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryProto/l1kB4) | [![pkgeval](https://juliahub.com/docs/OpenTelemetryProto/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetryProto/l1kB4) |
| `OpenTelemetryExporterOtlpProtoGrpc` | [![version](https://juliahub.com/docs/OpenTelemetryExporterOtlpProtoGrpc/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterOtlpProtoGrpc/S0kTL) | [![pkgeval](https://juliahub.com/docs/OpenTelemetryExporterOtlpProtoGrpc/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterOtlpProtoGrpc/S0kTL) |

## Progress

- API
    - [x] Tracing
    - [ ] Baggage
    - [x] Metrics
    - [ ] Logging

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

provider = TracerProvider(
    span_processor=CompositSpanProcessor(
        SimpleSpanProcessor(
            ConsoleExporter()
        )
    )
)

tracer = Tracer(provider=provider)

with_span(Span("foo", tracer)) do
    with_span(Span("bar", tracer)) do
        with_span(Span("baz", tracer)) do
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

provider = TracerProvider(
        span_processor=CompositSpanProcessor(
            SimpleSpanProcessor(
                OtlpProtoGrpcExporter(;url="http://localhost:4317")
            )
        )
    )
)

tracer = Tracer(provider=provider)

with_span(Span("foo", tracer)) do
    with_span(Span("bar", tracer)) do
        with_span(Span("baz", tracer)) do
            println("Hello world!")
        end
    end
end
```

### Metrics

```julia
using OpenTelemetryAPI
using OpenTelemetrySDK

provider = MeterProvider()
meter = Meter("my_metrics"; provider=provider)
counter = Counter{Int}("counter", m1)
counter(1)
counter(3, "m.a" => 1, "m.b" => "b", "m.c" => 3.)
```