# View Metrics/Traces/Logs in Grafana/ElasticAPM

In previous tutorials, we've learned how to record and visualize metrics. This tutorial will continue on exploring traces and logs. In the end, we'll see how these three pillars are fused together to improve the observability of your system.

## Traces

In short, traces are used to record the time spans of each element operations we are interested in during a function call. In `OpenTelemetry.jl`, we use [`with_span`](@ref) to initiate a new span. Each span can be nested in another span. And the outest one is called the root span, which naturally forms one trace.

```julia
using OpenTelemetry

with_span("Hello") do
    with_span("World") do
        println("Hello world from OpenTelemetry.jl!")
    end
end
```

For example, here we created two spans, the root span is named `"Hello"`. By default, the spans are print to the console in detail. To visualize them, we can follow what we did before to set up the OpenTelemetry Collector first.

```bash
cd docs/src/tutorials/View_Logs_Traces,_and_Metrics_Together_in_Grafana_ElasticAPM
docker-compose -f docker-compose-jaeger.yml up
```

Then how to send the spans to OpenTelemetry Collector?

The idea is very similar to the logging system in Julia. At the end of each span, it will be sent to the [`global_tracer_provider`](@ref) implicitly. We can configure it to forward spans to the OpenTelemetry Collector.

```julia
global_tracer_provider!(
    TracerProvider(
        span_processor=SimpleSpanProcessor(
            OtlpProtoGrpcTraceExporter()
        )
    )
)
```

Now create the spans again:

```julia
with_span("Hello") do
    with_span("World") do
        println("Hello world from OpenTelemetry.jl!")
    end
end
```

Then open the Jaeger UI at [http://localhost:16686](http://localhost:16686). You can find the trace we just created by filtering the `Operations` with span name.

### View Traces in Tempo

Should be similar to Jaeger, but I haven't test it yet.

## Logs

### View Logs in Loki

Wait https://github.com/grafana/loki/issues/5346

## Putting Them All Together

### Grafana

TODO, wait Logs are supported in Loki

### Elastic APM

Elastic APM is very powerful to help you gain insights across logs, traces and metrics. However, setting up a workable Elastic APM environment may be over complicated for first time users. What make it more difficulty is the security related configurations enabled by default after ElasticSearch 8. Since you decide to give it a try, I can safely assume you are familiar with ElasticSearch, Kibana and a little bit about APM-Server. From the architecture level, Elastic APM is similar to what we've seen before. If you've already got a functional ElasticSearch and Kibana, then follow [the official documentation](https://www.elastic.co/guide/en/apm/guide/8.0/apm-quick-start.html) to set up the Fleet and add the APM integration. In the 4th step, Install APM Agents, you'll find that there's no Julia related APM agent yet! And that's why we use `OpenTelemetry.jl`! If you're familiar with one of the programming languages listed there, give it a try and explore the exported data in Kibana. Then come back and see how to do it with `OpenTelemetry.jl`.

If you do not have ElasticSearch and Kibana installed yet, you can follow the following instructions to set them up quickly. Most of the configs are adapted from [apm-server/docker-compose.yml](https://github.com/elastic/apm-server/blob/main/docker-compose.yml). Note that they are for test only, do not use them in production environments. (DO NOT SAY I DIDN'T WARN YOU!)

```bash
cd docs/src/tutorials/View_Logs_Traces,_and_Metrics_Together_in_Grafana_Logstash_SigNoz
docker-compose up
```

Then login to the kibana at [localhost:5601](http://localhost:5601) with the username `admin` and password `changeme` if you didn't change them. After that, follow the step 3 in [the official documentation](https://www.elastic.co/guide/en/apm/guide/8.0/apm-quick-start.html) to add a APM integration. You may want to change the host and url to `0.0.0.0:8200` and `http://0.0.0.0:8200`.

The only left one is to setup the OpenTelemetry Collector. In the `docker-compose.yml` file, it's already setup. You can read more details on the configurations at [OpenTelemetry Integration in Elastic APM](https://www.elastic.co/guide/en/apm/guide/8.0/open-telemetry.html).

The rest is the same as we did before. Open the Julia REPL and try to add some traces/logs/metrics to the OpenTelemetry Collector. Then explore the collected data by following step 5 in [the official doc on Elastic APM](https://www.elastic.co/guide/en/apm/guide/8.0/apm-quick-start.html).