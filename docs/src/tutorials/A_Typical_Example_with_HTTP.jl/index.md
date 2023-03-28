# A Typical Example with HTTP.jl

In previous tutorials, we learned how to export logs, traces, and metrics independently. In fact, these three signals are usually correlated. In this tutorial, we'll learn how to export them together with a simple example in [HTTP.jl](https://juliaweb.github.io/HTTP.jl/stable/).

## A Simple Example with HTTP.jl

First, let's setup the necessary services to collect logs, traces, and metrics.

```bash
cd docs/src/tutorials/A_Typical_Example_with_HTTP.jl

docker compose up -d
```

Then create a new Julia REPL and configure the providers for each kind of signal.

```julia
using OpenTelemetry
using Logging

global_logger(OtelSimpleLogger(OtlpHttpLogsExporter()))
global_tracer_provider(TracerProvider(;span_processor=SimpleSpanProcessor(OtlpHttpTracesExporter())))
global_meter_provider(MeterProvider())

METRIC_READER = PeriodicMetricReader(MetricReader(OtlpHttpMetricsExporter()))
```

Note that we use a [`PeriodicMetricReader`](@ref) here to avoid manually sending metrics repeatedly.

Next, we'll create a simple HTTP service and make several requests to it.

```julia
using HTTP
instrument!(HTTP)
```

Let me explain a little bit about `instrument!(HTTP)` first. `OpenTelemetry.jl` has a built-in support for `HTTP.jl`. By executing `instrument!(HTTP)`, we're actually injecting some hooks into the `HTTP` package. So that when you use HTTP to make requests, we'll create a new span and pass the current trace context to the server automatically. Beyond that, by convention, we'll also record some common metrics automatically. We'll see them soon.

```julia
# For now, we still need to manually set the OpenTelemetry middleware layer
# Watch: https://github.com/JuliaWeb/HTTP.jl/issues/801#issuecomment-1484097096
using OpenTelemetrySDK.OpenTelemetrySDKHTTPExt: otel_http_middleware

function handle(req)
    sleep(rand())
    @info "hello"
    HTTP.Response(200, "world")
end

router = HTTP.Router(HTTP.Handlers.default404, HTTP.Handlers.default405, otel_http_middleware) 
HTTP.register!(router, "/", handle)
server = HTTP.serve!(router, "127.0.0.1", 8122)
```

Here we simply setup a http service listening at the `8122` port. On receiving a request, it will sleep for a random time within 1 second.

Now try to simulate several requests:

```julia
for _ in 1:10
    HTTP.get("http://127.0.0.1:8122")
end
```

Then heads over to the Grafana portal at [http://localhost:3000](http://localhost:3000). You should now see the logs, traces, and metrics in under the exploration tab.