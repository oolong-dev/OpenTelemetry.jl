using Test
using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryProto
using OpenTelemetryExporterOtlpProtoGrpc

exporter =  InMemoryExporter()
# exporter = OtlpProtoGrpcExporter()

global_tracer_provider(
    TracerProvider(
        span_processor=CompositSpanProcessor(
            SimpleSpanProcessor(
                exporter
            )
        )
    )
)

tracer = get_tracer("test")

@testset "OtlpProtoGrpc" begin
    with_span("foo", tracer) do
        with_span("bar", tracer) do
            with_span("baz", tracer) do
                println("Hello world!")
            end
        end
    end

    req = convert(
        OpenTelemetryProto.OpentelemetryClients.ExportTraceServiceRequest,
        exporter.finished_spans
    )
end