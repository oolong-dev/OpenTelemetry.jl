using OpenTelemetryExporterOtlpProtoHttp
using OpenTelemetrySDK
using OpenTelemetryProto

using Logging
using Test

@testset "HTTP Proto" begin
    span_exporter = InMemoryExporter()
    log_exporter = InMemoryExporter()
    logger = OtelBatchLogger(log_exporter)

    global_tracer_provider(
        TracerProvider(
            span_processor = CompositSpanProcessor(SimpleSpanProcessor(span_exporter)),
        ),
    )

    with_logger(logger) do
        with_span("foo") do
            @debug "Hi!!!"
            with_span("bar") do
                @info "Hello!!!" foo = "foo"
                with_span("baz") do
                    @warn "World!!!" bar = "bar"
                    @error "!!!!!"
                end
            end
        end
    end

    flush(logger)
    convert(
        OpenTelemetryProto.opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest,
        log_exporter.pool,
    )

    otlp = OtlpHttpLogsExporter()
    export!(otlp, log_exporter.pool)

    #####

    flush(global_tracer_provider())
    convert(
        OpenTelemetryProto.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest,
        span_exporter.pool,
    )

    otlp = OtlpHttpTracesExporter()
    export!(otlp, span_exporter.pool)

    #####

    p = MeterProvider()
    e = InMemoryExporter()
    r = MetricReader(p, e)

    m = Meter("test"; provider = p)

    c = Counter{Int}("fruit_counter", m)
    c(; name = "apple", color = "red")
    c(2; name = "lemon", color = "yellow")
    c(1; name = "lemon", color = "yellow")
    c(2; name = "apple", color = "green")
    c(5; name = "apple", color = "red")
    c(4; name = "lemon", color = "yellow")

    udc = UpDownCounter{Int}("stock", m)
    udc(200)
    udc(-50)
    udc(150)

    function fake_observer(x)
        i = x
        function ()
            res = i * 2
            i += 1
            res
        end
    end

    oc = ObservableCounter{Int}(fake_observer(0), "observable_counter", m)

    oudc = ObservableUpDownCounter{Int}(fake_observer(-2), "observable_up_down_counter", m)

    og = ObservableGauge{Int}(fake_observer(-3), "observable_gauge", m)

    h = Histogram{Int}("n_requests", m)
    h(3)
    h(5)
    h(8)
    h(12)
    h(2)
    h(1_000_000)

    r()

    convert(
        OpenTelemetryProto.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest,
        metrics(p),
    )

    otlp = OtlpHttpMetricsExporter()
    export!(otlp, metrics(p))
end