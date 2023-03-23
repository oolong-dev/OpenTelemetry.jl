# View Metrics in Prometheus with OpenTelemetry Collector

In [the previous tutorial](../View_Metrics_in_Prometheus/), we learned how to view metrics in Prometheus by initializing a [`PrometheusExporter`](@ref). Everything seems to work perfectly as expected, then why bother to use OpenTelemetry collector here? Quoted from the official doc:

> "The OpenTelemetry Collector offers a vendor-agnostic implementation of how to receive, process and export telemetry data. It removes the need to run, operate, and maintain multiple agents/collectors."

It provides us a nice way to utilize many different APMs. And we'll see many examples in the following tutorials. Here we'll focus on Prometheus only. First, we'll learn how to use Prometheus to view metrics through OpenTelemetry collector. Then we'll explore some advanced metrics related features provided by `OpenTelemetry.jl`.

## The Relationship between `OpenTelemetry.jl`, OpenTelemetry Collector and Prometheus

Let's take a look at a figure from the official OpenTelemetry website first.

![](https://opentelemetry.io/img/otel_diagram.png)

What `OpenTelemetry.jl` provides is a collection of `OTel API`, `OTel SDK`, and `OTel Instruments` in Julia, which lies in the top left corner in the above figure. Observed signals are first sent to `OTel Collector`, then they are forwarded to many different kinds of receivers. In this tutorial, we are most interested in viewing metrics in Prometheus.

So in short, we want to send metrics in the OTLP format to a OTel Collector, and then view them in Prometheus.

```
┌──────────────────┐  OTLP  ┌────────────────┐   ┌────────────┐
| OpenTelemetry.jl |------->| OTel Collector |-->| Prometheus |
└──────────────────┘        └────────────────┘   └────────────┘
```

This time we setup the Prometheus and OTel Collector first.

```bash
cd docs/src/tutorials/View_Metrics_in_Prometheus_through_Open_Telemetry_Collector
docker compose up
```

Then open the Julia REPL as usual and add some metrics like what we did in the previous tutorial.

```julia
using OpenTelemetry

global_meter_provider(MeterProvider());

m = Meter("demo_metrics");
c = Counter{UInt}("fruit_counter", m)
c(2; name = "apple", color = "green")
```

Instead of using the default `ConsoleExporter`, this time we'll use the [`OtlpHttpMetricsExporter`](@ref).

```julia
r = MetricReader(OtlpHttpMetricsExporter())
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

You're encouraged to try some other instruments listed under [Instruments](@ref).
