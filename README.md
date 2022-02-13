# OpenTelemetry.jl
[![doc](https://img.shields.io/badge/docs-dev-blue.svg)](https://oolong-dev.github.io/OpenTelemetry.jl/dev)
[![CI](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/oolong-dev/OpenTelemetry.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl/branch/master/graph/badge.svg?token=A3DMIK8K58)](https://codecov.io/gh/oolong-dev/OpenTelemetry.jl)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)


An *unofficial* implementation of [OpenTelemetry](https://opentelemetry.io/) in Julia.

## Packages

| Package | Description | Latest Version |
|:--------|:------------|:---------------|
|[`OpenTelemetryAPI`](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryAPI/) | Common data structures and interfaces. Instrumentations should rely on it only. | [![version](https://juliahub.com/docs/OpenTelemetryAPI/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryAPI/p4SiN) |
| [`OpenTelemetrySDK`](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetrySDK/) | Based on [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#sdk), application owners use SDK constructors; plugin authors use SDK plugin interfaces| [![version](https://juliahub.com/docs/OpenTelemetrySDK/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetrySDK/NFHPX) |
| [`OpenTelemetryProto`](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryProto/) | See [the OTLP specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/README.md) | [![version](https://juliahub.com/docs/OpenTelemetryProto/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryProto/l1kB4) |
| [`OpenTelemetryExporterOtlpProtoGrpc`](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryExporterOtlpProtoGrpc/) | Provide an `AbstractExporter` in OTLP through gRPC | [![version](https://juliahub.com/docs/OpenTelemetryExporterOtlpProtoGrpc/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterOtlpProtoGrpc/S0kTL) |
| [`OpenTelemetryExporterPrometheus`](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryExporterPrometheus/) | Provide an `AbstractExporter` to allow pulling metrics from Prometheus |[![version](https://juliahub.com/docs/OpenTelemetryExporterPrometheus/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetryExporterPrometheus/Xma7h) |
|`OpenTelemetry` | Reexport all above. For demonstration and test only. Application users should import `OpenTelemetrySDK` and necessary plugins or instrumentations explicitly. | [![version](https://juliahub.com/docs/OpenTelemetry/version.svg)](https://juliahub.com/ui/Packages/OpenTelemetry/L4aUb) |
| [`OpenTelemetryInstrumentationBase`](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationBase/) | Add basic metrics under the `Base` module in Julia runtime. | |
| `OpenTelemetryUber` | Reexport all above. For demonstration and test only. Application users should import `OpenTelemetrySDK` and necessary plugins or instrumentations explicitly. | |

## Get Started

### Traces

To show traces in your console:

```julia
using OpenTelemetry

with_span("Hello") do
    with_span("World") do
        println("Hello world from OpenTelemetry.jl!")
    end
end
```

### Metrics

```julia
using OpenTelemetry

m = Meter("demo_metrics");
c = Counter{Int}("fruit_counter", m);

c(; name = "apple", color = "red")
c(2; name = "lemon", color = "yellow")
c(1; name = "lemon", color = "yellow")
c(2; name = "apple", color = "green")
c(5; name = "apple", color = "red")
c(4; name = "lemon", color = "yellow")

r = MetricReader();
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

For more details, please read the [tutorial](https://oolong.dev/OpenTelemetry.jl/dev/tutorial).

## Benchmarks

Check out the benchmark results with [Julia@v1.6](https://oolong-dev.github.io/OpenTelemetry.jl/benchmarks/Julia-v1.6/), [Julia@v1.7](https://oolong-dev.github.io/OpenTelemetry.jl/benchmarks/Julia-v1.7/).
