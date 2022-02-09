# OpenTelemetryAPI

The content in this page is organized in the same order as the [OpenTelemetry
Specification](https://github.com/open-telemetry/opentelemetry-specification).

## Context

All the **MUST** items in the original [specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/context/context.md) are implemented.

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
Private = false
```

## Propagators

[`inject!`](@ref) and [`extract`](@ref) are provided based on the original [specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/context/api-propagators.md). However, `TextMapPropagator` is not implemented yet! Personally I feel that every propagator may depends on a third party
package. To minimize the dependencies of `OpenTelemetryAPI.jl`, those specialized propagators can be registered as
independent packages.

The `GLOBAL_PROPAGATOR` is set to a `CompositePropagator`, with multiple dispatch, each inner propagator can be
customized to handle different contexts and carriers. Since it's mainly used internally for now, it's not exposed yet.

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["propagator.jl"]
Private = false
```

## Trace

The relationship between trace provider, tracer, span context and span is depicted below:

```
┌────────────────────────────┐
│ AbstractSpan               │
│   ┌──────────────────────┐ │
│   │ Tracer               │ │
│   │   ┌────────────────┐ │ │
│   │   │    Abstract    │ │ │
│   │   │ TracerProvider │ │ │
│   │   └────────────────┘ │ │
│   │  instrumentation     │ │
│   │   ┌────────────────┐ │ │
│   │   │ name           │ │ │
│   │   │ version        │ │ │
│   │   └────────────────┘ │ │
│   └──────────────────────┘ │
└────────────────────────────┘
```

In `OpenTelemetryAPI.jl`, only one concrete [`AbstractTracerProvider`](@ref)
(the `DummyTracerProvider`) is provided. It is set as the  default
[`global_tracer_provider`](@ref). Without SDK installed, the [`with_span`](@ref)
will only create a `NonRecordingSpan`. This is to make the `OpenTelemetryAPI.jl`
lightweight enough so that instrumentation package users can happily add it as a
dependency without losing performance.

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["tracer_provider.jl"]
Private = false
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
Pages = ["metric_provider.jl"]
Private = false
```
### Instruments

All instruments provided here can be classified into two categories: [`AbstractSyncInstrument`](@ref) and [`AbstractAsyncInstrument`](@ref).

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["instruments.jl"]
Private = false
```

## Logging

The idea is simple, a [`LogTransformer`](@ref) is provided to transform each logging message into a [`LogRecord`](@ref). To understand how to use it, users should be familiar with how **TransformerLogger** from [LoggingExtras.jl](https://github.com/JuliaLogging/LoggingExtras.jl#transformerlogger-transformer) works.

```@autodocs
Modules = [OpenTelemetryAPI]
Pages = ["log.jl"]
Private = false
```

## Misc

```@autodocs
Modules = [OpenTelemetryAPI]
Private = false
```