# OpenTelemetrySDK

## Exporters

Two common exporters are provided to for debugging:

```@autodocs
Modules = [OpenTelemetrySDK]
Pages = ["exporter.jl"]
Private = false
```

## Tracer

### TracerProvider

In SDK, [`TracerProvider`](@ref) and [`Span`](@ref) are provided to replace the
dummy ones in API. `Span` is not exported since we mainly use [`with_span`](@ref) to
create new spans.

```@autodocs
Modules = [OpenTelemetrySDK]
Pages = ["trace_provider.jl"]
Private = false
```

### ID Generators

```@autodocs
Modules = [OpenTelemetrySDK]
Pages = ["id_generator.jl"]
Private = false
```

### Samplers

```@autodocs
Modules = [OpenTelemetrySDK]
Pages = ["sampling.jl"]
Private = false
```

### Span Processors

```@autodocs
Modules = [OpenTelemetrySDK]
Pages = ["span_processor.jl"]
Private = false
```

## Metric

The current implementation of metrics in SDK is mainly inspired by the [dotnet
sdk](https://github.com/open-telemetry/opentelemetry-dotnet).

```
┌──────────────────────────────────────────┐
│MeterProvider                             │
│                                          │
│  meters                                  │
│  views                                   │
│                                          │
│  instrument_associated_metric_names      │
│    instrument =>  Set{metric_name}       │
│                                          │
│  metrics                                 │
│    name => metric                        │
│    ┌───────────────────────────────────┐ │
│    │Metric                             │ │
│    │                                   │ │
│    │  name                             │ │
│    │  description                      │ │
│    │  criteria                         │ │
│    │  aggregation                      │ │
│    │    ┌──────────────────────────┐   │ │
│    │    │AggregationStore          │   │ │
│    │    │                          │   │ │
│    │    │  attributes => data_point│   │ │
│    │    │   ┌─────────────────┐    │   │ │
│    │    │   │AbstractDataPoint│    │   │ │
│    │    │   │                 │    │   │ │
│    │    │   │  value          │    │   │ │
│    │    │   │  start_time     │    │   │ │
│    │    │   │  end_time       │    │   │ │
│    │    │   │  exemplars      │    │   │ │
│    │    │   │ ┌────────────┐  │    │   │ │
│    │    │   │ │Exemplar    │  │    │   │ │
│    │    │   │ │            │  │    │   │ │
│    │    │   │ │ value      │  │    │   │ │
│    │    │   │ │ trace_id   │  │    │   │ │
│    │    │   │ │ span_id    │  │    │   │ │
│    │    │   │ └────────────┘  │    │   │ │
│    │    │   │                 │    │   │ │
│    │    │   └─────────────────┘    │   │ │
│    │    │                          │   │ │
│    │    └──────────────────────────┘   │ │
│    │                                   │ │
│    └───────────────────────────────────┘ │
│                                          │
└──────────────────────────────────────────┘
```

A [`View`](@ref) specifies which instruments are grouped together through [`Criteria`](@ref). For each view, a
[`Metric`](@ref) is created to store the [`Measurement`](@ref)s. Each metric may have many different dimensions
configured by [`StaticAttrs`](@ref) in a [`Measurement`](@ref). For each dimension, we may also collect those
[`Exemplar`](@ref)s in the mean while.

### Design decisions

- For each registered instrument, we have stored the associated metrics configured by views into the
  `instrument_associated_metric_names` field. So that for each pair of `instrument => measurement`, we can quickly
  determine which metrics to update.
- To make sure that measurements of the same attribute key-values but with different order can be updated in the same
  dimension in the [`AggregationStore`](@ref), a design from
  [opentelemetry-dotnet#2374](https://github.com/open-telemetry/opentelemetry-dotnet/issues/2374) is borrowed here.

```@autodocs
Modules = [OpenTelemetrySDK]
Pages = ["aggregation.jl", "datapoint_atomic.jl", "datapoint_lock.jl", "meter_provider.jl", "meter_reader.jl", "view.jl"]
Private = false
```

## Misc

```@autodocs
Modules = [OpenTelemetrySDK]
```