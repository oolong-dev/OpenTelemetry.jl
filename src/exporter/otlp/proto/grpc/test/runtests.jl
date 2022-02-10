using Test
using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryProto
using OpenTelemetryExporterOtlpProtoGrpc

# exporter = OtlpProtoGrpcTraceExporter()

@testset "OtlpProtoGrpc" begin
    # NonRecordingSpan
    with_span("foo") do
        req = convert(
            OpenTelemetryProto.OpentelemetryClients.ExportTraceServiceRequest,
            current_span(),
        )
    end

    # Span
    with_span("foo", Tracer(provider = TracerProvider())) do
        req = convert(
            OpenTelemetryProto.OpentelemetryClients.ExportTraceServiceRequest,
            current_span(),
        )
    end
end
