# Design

The content in this page is organized in the same order as the [OpenTelemetry
Specification](https://github.com/open-telemetry/opentelemetry-specification).

```@setup api
using OpenTelemetryAPI
```

## API

### Context

`Context` is implemented as a wrapper of `NamedTuple`, which means it is immutable. Each `Task` has exactly **ONE**
`Context` instance, which is injected into the `task_local_storage` of the `current_task` by the parent task automatically.

!!! warning
    [Type piracy](https://docs.julialang.org/en/v1/manual/style-guide/#Avoid-type-piracy) is used to the propagate context between tasks.

`create_key` is used to create a context key. But it is not exported yet because it seems to be only used internally until now.

`Base.getindex(::Context, key)` is implemented so to get a value in a `Context`, one can simply call `ctx[key]` to get
the associated value of a key in a `ctx`.

Setting value of a `Context` is not directly supported. Given that `Context` is immutable, updating an immutable object
in Julia seems strange. We provide the [`with_context`](@ref) function to create a new context based on the key-value
pairs in the [`current_context`](@ref). This syntax is more common than the attach/detach operations in the original
specification.

```@docs
with_context
current_context
```

### Propagators

[`inject!`](@ref) and [`extract`](@ref) are provided to 

The global propagator can be set to a `CompositePropagator`, with multiple dispatch, each inner propagator can be
customized to handle different contexts and carriers.

`TextMapPropagator` is not implemented yet! Personally I feel that every propagator may depends on a third party
package. To minimize the dependencies of `OpenTelemetryAPI.jl`, those specialized propagators can be registered as
independent packages.

```@docs
inject!
extract
```

### Trace

The relationship between trace provider, tracer, span context and span is depicted below:

```
┌────────────────────────────┐
│Span                        │
│                            │
│ tracer                     │
│   ┌──────────────────────┐ │
│   │Tracer                │ │
│   │                      │ │
│   │  provider            │ │
│   │   ┌────────────────┐ │ │
│   │   │    Abstract    │ │ │
│   │   │ TracerProvider │ │ │
│   │   └────────────────┘ │ │
│   │  instrumentation     │ │
│   │   ┌────────────────┐ │ │
│   │   │ name           │ │ │
│   │   │ version        │ │ │
│   │   └────────────────┘ │ │
│   │                      │ │
│   └──────────────────────┘ │
│ span_context               │
│   ┌──────────────────────┐ │
│   │ trace_id             │ │
│   │ span_id              │ │
│   │ is_remote            │ │
│   │ trace_flag           │ │
│   │ trace_state          │ │
│   └──────────────────────┘ │
│ parent_span_context        │
│ kind                       │
│ start_time                 │
│ end_time                   │
│ attributes                 │
│ links                      │
│ events                     │
│ status                     │
└────────────────────────────┘
```

- In `OpenTelemetryAPI.jl`, only one `AbstractTracerProvider` (`DummyTracerProvider`) is provided and is set as the [`global_tracer_provider`](@ref).
- `Span` is immutable. Modifiable fields like `status`, `end_time` are set to `Ref`.
- To add [`Event`](@ref)s and [`Link`](@ref)s, users can call `push!(span, event_or_link)`.
- The `attributes` in the [`Span`](@ref) is a [`DynamicAttrs`](@ref), and can be updated with the syntax like `span[key]=value`.
- `end_time` will be set by default after the call to [`with_span`](@ref).
- Always use `set_status!` to update the status of span.

!!! note
    In some other languages, only a dummy span is defined in API and the concrete span is defined in SDK. Personally I
    prefer to defined it in API, otherwise we need to define many *getter* methods.

```@docs
global_tracer_provider
Tracer
Span
current_span
with_span
Base.push!(s::Span, ex::Exception)
Base.push!(s::Span, link::Link)
Base.setindex!(s::Span, val, key)
Base.getindex(s::Span, key)
set_status!
end!
is_recording
```


Some other exported symbols:

```@docs
TraceIdType
SpanIdType
INVALID_TRACE_ID
INVALID_SPAN_ID
current_span
TraceFlag
TraceState
SpanContext
INVALID_SPAN_CONTEXT
span_context
SPAN_KIND_UNSPECIFIED
SPAN_KIND_INTERNAL
SPAN_KIND_SERVER
SPAN_KIND_CLIENT
SPAN_KIND_PRODUCER
SPAN_KIND_CONSUMER
LimitInfo
Link
Event
SPAN_STATUS_UNSET
SPAN_STATUS_OK
SPAN_STATUS_ERROR
SpanStatu
```

### Metric

The relationship between `MeterProvider`, `Meter` and different instruments are depicted below:

```
 ┌─────────────────────────────┐
 │AbstractInstrument           │
 │                             │
 │  name                       │
 │  unit                       │
 │  description                │
 │                             │
 │  meter                      │
 │   ┌───────────────────────┐ │
 │   │Meter                  │ │
 │   │                       │ │
 │   │  provider             │ │
 │   │   ┌────────────────┐  │ │
 │   │   │   Abstract     │  │ │
 │   │   │ MeterProvider  │  │ │
 │   │   └────────────────┘  │ │
 │   │  name                 │ │
 │   │  version              │ │
 │   │  schema_url           │ │
 │   │                       │ │
 │   │  instrumentation      │ │
 │   │   ┌────────────────┐  │ │
 │   │   │ name           │  │ │
 │   │   │ version        │  │ │
 │   │   └────────────────┘  │ │
 │   │  instruments          │ │
 │   │                       │ │
 │   │    * Counter          │ │
 │   │    * Histogram        │ │
 │   │    * UpDownCounter    │ │
 │   │    * ObservableCounter│ │
 │   │    * Observable       │ │
 │   │      UpDownCounter    │ │
 │   └───────────────────────┘ │
 │                             │
 └─────────────────────────────┘
```

- An `Instrument` belongs to a `Meter`, each `Meter` may contain many different `Instrument`s. Similarly, a `Meter`
  belongs to a `MeterProvider` and a `MeterProvider` may contain many different `Meter`s.

```@docs
global_meter_provider
Meter
Measurement
Counter
ObservableCounter
Histogram
ObservableGauge
UpDownCounter
ObservableUpDownCounter
```

## SDK

Two common exporters are provided to for debugging:

```@docs
InMemoryExporter
ConsoleExporter
```

### Trace

In SDK, a dedicated [`TraceProvider`](@ref) is provided.

```@docs
TraceProvider
CompositSpanProcessor
ALWAYS_ON
ALWAYS_OFF
DEFAULT_ON
DEFAULT_OFF
TraceIdRatioBased
```

### Metric

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
[`Exemplar`]s in the mean while.

#### Design decisions

- For each registered instrument, we have stored the associated metrics configured by views into the
  `instrument_associated_metric_names` field. So that for each pair of `instrument => measurement`, we can quickly
  determine which metrics to update.
- The make sure that measurements with the same attribute key-values but with different order can be updated in the same
  dimension in the [`AggregationStore`](@ref), a design from
  [opentelemetry-dotnet#2374](https://github.com/open-telemetry/opentelemetry-dotnet/issues/2374) is borrowed here.


```@docs
MeterProvider
View
Metric
AggregationStore
```
