# OpenTelemetryAPI

The content in this page is organized in the same order as the [OpenTelemetry
Specification](https://github.com/open-telemetry/opentelemetry-specification).

## Context

`Context` is implemented as a wrapper of `NamedTuple`, which means it is immutable. Each `Task` has exactly **ONE**
`Context` instance, which is injected into the `task_local_storage` of the `current_task` by the parent task automatically.

!!! warning
    [Type piracy](https://docs.julialang.org/en/v1/manual/style-guide/#Avoid-type-piracy) is used to the propagate context between tasks. See more discussions in [#32](https://github.com/oolong-dev/OpenTelemetry.jl/issues/32)

`create_key` is used to create a context key. But it is not exported yet because it seems to be only used internally until now.

`Base.getindex(::Context, key)` is implemented so to get a value in a `Context`, one can simply call `ctx[key]` to get
the associated value of a key in a `ctx`.

Setting value of a `Context` is not directly supported. Given that `Context` is immutable, updating an immutable object
in Julia seems strange. We provide the [`with_context`](@ref) function to create a new context based on the key-value
pairs in the [`current_context`](@ref). This syntax is more common than the attach/detach operations in the original
specification.

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["context.jl"]
```

## Propagators

[`inject!`](@ref) and [`extract`](@ref) are provided to 

The global propagator can be set to a `CompositePropagator`, with multiple dispatch, each inner propagator can be
customized to handle different contexts and carriers.

`TextMapPropagator` is not implemented yet! Personally I feel that every propagator may depends on a third party
package. To minimize the dependencies of `OpenTelemetryAPI.jl`, those specialized propagators can be registered as
independent packages.

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["propagator.jl"]
```

## Trace

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


```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["tracer_basic.jl", "tracer_provider.jl"]
```

## Metric

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

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["metric_provider.jl", "instruments.jl"]
```

## Misc

```@autodocs
Modules = [OpenTelemetryAPI]
```