using Test
using Logging
using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryProto
using OpenTelemetryExporterOtlpProtoGrpc

# exporter = OtlpProtoGrpcTraceExporter()

@testset "OtlpProtoGrpc Trace" begin
    # NonRecordingSpan
    with_span("foo") do
        req = convert(
            OpenTelemetryProto.OpentelemetryClients.ExportTraceServiceRequest,
            current_span(),
        )
    end

    # Span
    with_span("foo", Tracer(provider = TracerProvider())) do
        s = current_span()
        s["a"] = "a"
        s["b"] = true
        s["c"] = 1.0
        s["d"] = UInt8[0, 1, 2]
        s["e"] = -1
        push!(
            s,
            Event(; name = "example", attributes = (;e = "eee"),
        )
        push!(
            s,
            Link(
                SpanContext(;
                    trace_id = rand(TraceIdType),
                    span_id = rand(SpanIdType),
                    is_remote = false,
                ),
                BoundedAttributes((; f = "fff")),
            ),
        )

        req = convert(
            OpenTelemetryProto.OpentelemetryClients.ExportTraceServiceRequest,
            current_span(),
        )
    end
end

@testset "OtlpProtoGrpc Metrics" begin
    p = MeterProvider()
    m = Meter("abc"; provider = p)
    c = Counter{Int}("fruit_counter", m)
    c(1; name = "lemon", color = "yellow")

    h = Histogram{Float64}("fake_hist", m)
    h(1; name = "lemon", color = "yellow")

    convert(OpenTelemetryProto.OpentelemetryClients.ExportMetricsServiceRequest, metrics(p))
end

@testset "OtlpProtoGrpc Logs" begin
    r = OpenTelemetryAPI.LogRecord(;
        timestamp = UInt(time() * 10^9),
        trace_id = INVALID_TRACE_ID,
        span_id = INVALID_SPAN_ID,
        trace_flags = TraceFlag(),
        severity_text = "INFO",
        severity_number = 1,
        name = "",
        body = "Hi",
        resource = Resource(),
        attributes = BoundedAttributes(),
        instrumentation_info = InstrumentationInfo(),
    )
    convert(OpenTelemetryProto.OpentelemetryClients.ExportLogsServiceRequest, r)
end
