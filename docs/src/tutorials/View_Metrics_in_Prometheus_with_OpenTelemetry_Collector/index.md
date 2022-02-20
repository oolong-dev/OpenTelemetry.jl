# View Metrics in Prometheus with OpenTelemetry Collector

In [the previous tutorial](../View_Metrics_in_Prometheus/), we learned how to view metrics in Prometheus by initializing a [`PrometheusExporter`](@ref). Everything seems to work perfectly as expected, then why bother to use OpenTelemetry collector here? Quoted from the official doc:

> "The OpenTelemetry Collector offers a vendor-agnostic implementation of how to receive, process and export telemetry data. It removes the need to run, operate, and maintain multiple agents/collectors."

It provides us a nice way to utilize many different APMs. And we'll see many examples in the following tutorials. Here we'll focus on Prometheus only. First, we'll learn how to use Prometheus to view metrics through OpenTelemetry collector. Then we'll explore some advanced features provided `OpenTelemetry.jl`.

## The Relationship between `OpenTelemetry.jl`, OpenTelemetry Collector and Prometheus

Let's take a look at two figures from the official opentelemetry website.

![](https://raw.github.com/open-telemetry/opentelemetry.io/main/iconography/Reference_Architecture.svg)

In this figure, `OpenTelemetry.jl` lies in the top left corner or the top right corer given that it's just a OpenTelemetry library in Julia. In `OpenTelemetry.jl`, we push observed signals to the OpenTelemetry collector on the same host (named **Agent**) first. Then different **Agent**s can either push data to a centeralized OpenTelemetry collector (named **Service**) or send data directly to desired backends (like Prometheus).

![](https://raw.github.com/open-telemetry/opentelemetry.io/main/iconography/Otel_Collector.svg)

Inside of each OpenTelemetry Collector, it has three parts. The receivers receive data from other OpenTelemetry collectors (for example the **Agent**s in the first figure) or OpenTelemetry Library (`OpenTelemetry.jl` here) through the OpenTelemetry Protocol (OTLP). The processors can process the collected data further for downstream backends. And the receivers will deal with the communication between different backends.

Here what we want to do is described in the following figure:

```
┌──────────────────┐  OTLP  ┌────────────────┐   ┌────────────┐
| OpenTelemetry.jl |------->| OTel Collector |-->| Prometheus |
└──────────────────┘        └────────────────┘   └────────────┘
```
