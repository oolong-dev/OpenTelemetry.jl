# View Traces in Jaeger

In recent [Jaeger](https://www.jaegertracing.io/) versions, OTLP is supported natively. This means we can send traces to it directly without OpenTelemetry Collector in the middle.

Let's review the example provided in README first.

```julia
using OpenTelemetry
using Term # optional, for better display
```

```julia
global_tracer_provider(TracerProvider());
```

Here we set a [`TracerProvider`](@ref) as the `global_tracer_provider`. One argument we omitted when constructing `TracerProvider` is the `span_processor`. Its default value is `SimpleSpanProcessor(ConsoleExporter())`. By default, it will redirect all the spans to console.

```julia
with_span("Hello, World!") do
    with_span("from") do
        @info "OpenTelemetry.jl!"
    end
end
```

In the above code, two spans are created. As you can see, the span context of these two spans are correlated. The `trace_id` and `span_id` in the `OpenTelemetry.jl!` log record is also associated with the inner span of `from`.

## Export Spans to Jaeger

Let's setup the `Jaeger` first:

```bash
cd docs/src/tutorials/View_Traces_in_Jaeger
docker compose up
```

Then we replace the original `ConsoleExporter` with `OtlpHttpTracesExporter`.

```julia
global_tracer_provider(TracerProvider(;span_processor=SimpleSpanProcessor(OtlpHttpTracesExporter())))

with_span("Hello, World!") do
    with_span("from") do
        @info "OpenTelemetry.jl!"
    end
end
```

Now open the Jaeger web portal at [http://localhost:16686/](http://localhost:16686/). You should find a trace with the name of `unknown_service:julia: Hello, World!` by filtering the service. After clicking the `Find Traces` button, you should see the detailed spans like the the screenshot below.

![](docs/src/assets/span_jaeger.png)

## Reduce the Time Cost with `BatchSpanProcessor`

Note that with `SimpleSpanProcessor`, we're actually sending spans to the Jaeger immediately at the end of each span. To reduce the overall time cost, we can replace it with [`BatchSpanProcessor`](@ref).


```julia
global_tracer_provider(TracerProvider(;span_processor=BatchSpanProcessor(OtlpHttpTracesExporter())))

with_span("Hello, World!") do
    with_span("from") do
        @info "OpenTelemetry.jl!"
    end
end
```