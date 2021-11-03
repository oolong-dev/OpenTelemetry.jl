using Test
using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryProto
using OpenTelemetryExporterOtlpProtoGrpc

exporter =  InMemoryExporter()
# exporter = OtlpProtoGrpcExporter()

p = TracerProvider(
    span_processor=CompositSpanProcessor(
        SimpleSpanProcessor(
            exporter
        )
    )
)

tracer = Tracer(provider=p)

@testset "OtlpProtoGrpc" begin
    with_span(Span("foo", tracer)) do
        with_span(Span("bar", tracer)) do
            with_span(Span("baz", tracer)) do
                println("Hello world!")
            end
        end
    end

    req = convert(
        OpenTelemetryProto.OpentelemetryClients.ExportTraceServiceRequest,
        exporter.pool
    )
end