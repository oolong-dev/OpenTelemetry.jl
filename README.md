# OpenTelemetry.jl
[![doc](https://img.shields.io/badge/docs-dev-blue.svg)](https://oolong-dev.github.io/OpenTelemetry.jl/)
[![CI](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl/branch/master/graph/badge.svg?token=A3DMIK8K58)](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


An *unofficial* implementation of [OpenTelemetry](https://opentelemetry.io/) in Julia.

## Packages

| Package | Latest Version | Status |
|:--------|:---------------|:-------|
|`OpenTelemetry` | | |
|`OpenTelemetryAPI` | [![version](https://juliahub.com/docs/OpenTelemetryAPI/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryAPI/p4SiN) | [![pkgeval](https://juliahub.com/docs/OpenTelemetryAPI/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetryAPI/p4SiN) |
| `OpenTelemetrySDK` | [![version](https://juliahub.com/docs/OpenTelemetrySDK/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetrySDK/NFHPX) | [![pkgeval](https://juliahub.com/docs/OpenTelemetrySDK/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetrySDK/NFHPX) |
| `OpenTelemetryProto` | [![version](https://juliahub.com/docs/OpenTelemetryProto/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryProto/l1kB4) | [![pkgeval](https://juliahub.com/docs/OpenTelemetryProto/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetryProto/l1kB4) |
| `OpenTelemetryExporterOtlpProtoGrpc` | [![version](https://juliahub.com/docs/OpenTelemetryExporterOtlpProtoGrpc/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterOtlpProtoGrpc/S0kTL) | [![pkgeval](https://juliahub.com/docs/OpenTelemetryExporterOtlpProtoGrpc/pkgeval.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterOtlpProtoGrpc/S0kTL) |
| `OpenTelemetryExporterPrometheus` | | |

## Progress

- API
    - [x] Tracing
    - [x] Metrics
    - [x] Logging

- SDK
    - [x] Tracing
    - [x] Metric

- Exporter
    - OTLP
        - [x] Tracing
        - [ ] Metrics
    - [x] Prometheus

- Instrumentation
    - Std Lib
        - [ ] Core
        - [ ] Sockets
        - [ ] Distributed
        - [ ] Downloads
    - Common Packages
        - [ ] HTTP
        - [ ] Genie

## Get Started

### Traces

To show traces in your console:

```julia
using OpenTelemetry

tracer = Tracer(
    provider = TracerProvider(
        span_processor = SimpleSpanProcessor(
            ConsoleExporter()
        )
    )
);

with_span(Span("Hello", tracer)) do
    println("World!")
end
```

### Metrics

```julia
using OpenTelemetry

p = MeterProvider();
e = ConsoleExporter();
r = MetricReader(p, e);

m = Meter("my_metrics"; provider=p);
c = Counter{Int}("fruit_counter", m);

c(; name = "apple", color = "red")
c(2; name = "lemon", color = "yellow")
c(1; name = "lemon", color = "yellow")
c(2; name = "apple", color = "green")
c(5; name = "apple", color = "red")
c(4; name = "lemon", color = "yellow")

r()
```

### Logging

```julia
using OpenTelemetry
using Logging
using LoggingExtras

with_logger(TransformerLogger(LogTransformer(), global_logger())) do
    @info "hello world!"
end
```
