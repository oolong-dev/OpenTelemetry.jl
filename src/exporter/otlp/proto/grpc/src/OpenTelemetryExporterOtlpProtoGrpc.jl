module OpenTelemetryExporterOtlpProtoGrpc

using OpenTelemetrySDK
using OpenTelemetryProto

const SDK = OpenTelemetrySDK
const Otlp = OpenTelemetryProto.OpentelemetryClients
const Trace = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.trace.v1
const Resource = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.resource.v1
const Common = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.common.v1

Base.@kwdef struct OtlpProtoGrpcExporter{T} <: AbstractSpanExporter
    client::T
end

function OtlpProtoGrpcExporter(;url="http://localhost:4317", is_blocking=true, kw...)
    if is_blocking
        client = Otlp.TraceServiceBlockingClient(url;kw...)
    else
        client = Otlp.TraceServiceClient(url;kw...)
    end
    OtlpProtoGrpcExporter(client)
end

Base.convert(t::Type{Otlp.ExportTraceServiceRequest}, s::SDK.WrappedSpan) = convert(t, [s])

function Base.convert(::Type{Otlp.ExportTraceServiceRequest}, s::Vector{SDK.WrappedSpan})
    Otlp.ExportTraceServiceRequest(
        Trace.ResourceSpans(
            resource
        )
    )
end

function export!(se::OtlpProtoGrpcExporter, sp)
    res, status = Otlp.Export(se.client, convert(Otlp.ExportTraceServiceRequest, sp))
    if gRPCClient.gRPCCheck(status;throw_error=false)
        SDK.SUCCESS
    else
        SDK.FAILURE
    end
end

end # module
