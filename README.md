# OpenTelemetry.jl
[![doc](https://img.shields.io/badge/docs-dev-blue.svg)](https://oolong-dev.github.io/OpenTelemetry.jl/dev)
[![CI](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl/branch/master/graph/badge.svg?token=A3DMIK8K58)](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


An *unofficial* implementation of [OpenTelemetry](https://opentelemetry.io/) in Julia.

## Packages

| Package | Description | Latest Version |
|:--------|:------------|:---------------|
|[`OpenTelemetryAPI`](https://oolong.dev/OpenTelemetry.jl/dev/design_api/) | Common data structures and interfaces. Instrumentations should rely on it only. | [![version](https://juliahub.com/docs/OpenTelemetryAPI/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryAPI/p4SiN) |
| [`OpenTelemetrySDK`](https://oolong.dev/OpenTelemetry.jl/dev/design_sdk/) | Based on [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#sdk), application owners use SDK constructors; plugin authors use SDK plugin interfaces| [![version](https://juliahub.com/docs/OpenTelemetrySDK/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetrySDK/NFHPX) |
|`OpenTelemetry` | Reexport all above. | [![version](https://juliahub.com/docs/OpenTelemetry/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetry/L4aUb) |
| `OpenTelemetryProto` | See [the OTLP specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/README.md) | [![version](https://juliahub.com/docs/OpenTelemetryProto/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryProto/l1kB4) |
| `OpenTelemetryExporterOtlpProtoGrpc` | Provide an `AbstractExporter` in OTLP through gRPC | [![version](https://juliahub.com/docs/OpenTelemetryExporterOtlpProtoGrpc/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterOtlpProtoGrpc/S0kTL) |
| `OpenTelemetryExporterPrometheus` | Provide an `AbstractExporter` to allow pulling metrics from Prometheus |[![version](https://juliahub.com/docs/OpenTelemetryExporterPrometheus/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterPrometheus/Xma7h) |
| `OpenTelemetryUber` | Reexport all above. For demonstration and test only. Application users should import `OpenTelemetry` and necessary plugins or instrumentations explicitly. | | |

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

with_span("Hello") do
    with_span("World") do
        println("from OpenTelemetry")
    end
end
```

### Metrics

```julia
using OpenTelemetry

r = MetricReader();

m = Meter("demo_metrics");
c = Counter{Int}("fruit_counter", m);
h = Histogram{Float64}("normal_distribution", m);

c(; name = "apple", color = "red")
c(2; name = "lemon", color = "yellow")
c(1; name = "lemon", color = "yellow")
c(2; name = "apple", color = "green")
c(5; name = "apple", color = "red")
c(4; name = "lemon", color = "yellow")

for _ in 1:1_000
    h(randn() * 100)
end

r()

```

### Logging

```julia
using OpenTelemetry
using Logging
using LoggingExtras

with_span("Hello") do
    with_logger(TransformerLogger(OtelLogTransformer(), global_logger())) do
        @info "World!"
    end
end
```

## Versioning and Stability

## Benchmarks

Check out the benchmark results with [Julia@v1.6](https://oolong-dev.github.io/OpenTelemetry.jl/benchmarks/Julia-v1.6/), [Julia@v1.7](https://oolong-dev.github.io/OpenTelemetry.jl/benchmarks/Julia-v1.7/).
