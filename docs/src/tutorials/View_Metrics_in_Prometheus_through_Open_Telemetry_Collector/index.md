# View Metrics in Prometheus with OpenTelemetry Collector

In [the previous tutorial](../View_Metrics_in_Prometheus/), we learned how to view metrics in Prometheus by initializing a [`PrometheusExporter`](@ref). Everything seems to work perfectly as expected, then why bother to use OpenTelemetry collector here? Quoted from the official doc:

> "The OpenTelemetry Collector offers a vendor-agnostic implementation of how to receive, process and export telemetry data. It removes the need to run, operate, and maintain multiple agents/collectors."

It provides us a nice way to utilize many different APMs. And we'll see many examples in the following tutorials. Here we'll focus on Prometheus only. First, we'll learn how to use Prometheus to view metrics through OpenTelemetry collector. Then we'll explore some advanced metrics related features provided by `OpenTelemetry.jl`.

## The Relationship between `OpenTelemetry.jl`, OpenTelemetry Collector and Prometheus

Let's take a look at two figures from the official opentelemetry website first.

![](https://raw.github.com/open-telemetry/opentelemetry.io/main/iconography/Reference_Architecture.svg)

In this figure, `OpenTelemetry.jl` lies in the top left corner or the top right corer given that it's just a OpenTelemetry library in Julia. In `OpenTelemetry.jl`, we push observed signals to the OpenTelemetry collector on the same host (named **Agent** above) first. Then different **Agent**s can either push data to a centeralized OpenTelemetry collector (named **Service** above) or send data directly to desired backends (like Prometheus).

![](https://raw.github.com/open-telemetry/opentelemetry.io/main/iconography/Otel_Collector.svg)

Inside of each OpenTelemetry Collector, there are three important parts. The **receivers** receive data from other OpenTelemetry collectors (for example the **Agent**s in the first figure) or OpenTelemetry Library (`OpenTelemetry.jl` here) through the OpenTelemetry Protocol (OTLP). The **processors** can process the collected data further for downstream backends. And the **exporters** will handle the communication between different backends.

What we want to do in this tutorial is described as follows:

```
┌──────────────────┐  OTLP  ┌────────────────┐   ┌────────────┐
| OpenTelemetry.jl |------->| OTel Collector |-->| Prometheus |
└──────────────────┘        └────────────────┘   └────────────┘
```

This time we setup the Prometheus and OTel Collector first.

```bash
cd docs/src/tutorials/View_Metrics_in_Prometheus_through_Open_Telemetry_Collector
docker-compose up -d
```

The docker compose file and related configurations are listed below:

(TODO: insert)

Then open the Julia REPL as usual and add some metrics like what we did in the previous tutorial.

```julia
using OpenTelemetry

m = Meter("demo_metrics");
c = Counter{UInt}("fruit_counter", m)
c(2; name = "apple", color = "green")

r = MetricReader(OtlpProtoGrpcMetricsExporter())
```

Then head to the Prometheus portal at [http://localhost:9090](http://localhost:9090) and select the `fruit_counter` metric to view the number of fruits. Try adding more different fruits to see how they are displayed on the portal.

## Beyond `Counter`

[`Counter`](@ref) is the most frequently used metric. Beyond that, many other instruments are also provided. If you try to set a negative value to the counter we created above, an `ArgumentError` will be thrown. That's because a `Counter` can only accept non-negative values. You can use the [`UpDownCounter`](@ref) instead if you want.

```julia
b = UpDownCounter{Float64}("balance", m)
b(1.8)
b(-2)
r()  # upload measurements

b(3.3)
r()  # upload measurements
```

If you want to measure the latest value of some metrics instead of the cumulative value. Then the [`ObservableGauge`](@ref) is the best suitable instrument.

```julia
g = ObservableGauge{Float64}("temperature", m) do
    rand() * 30 - 10
end

for _ in 1:10
    r()
    sleep(3)
end
```

You're encouraged to try some other instruments listed under [Instruments](https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryAPI/#Instruments).
