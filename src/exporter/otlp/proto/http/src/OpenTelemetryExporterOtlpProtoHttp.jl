module OpenTelemetryExporterOtlpProtoHttp

using ProtoBuf

import OpenTelemetryAPI as API
import OpenTelemetrySDK as SDK

import OpenTelemetryProto.collector.logs.v1 as COLL_LOGS
import OpenTelemetryProto.collector.traces.v1 as COLL_TRACES
import OpenTelemetryProto.collector.metrics.v1 as COLL_METRICS

import OpenTelemetryProto.logs.v1 as LOGS
import OpenTelemetryProto.traces.v1 as TRACES
import OpenTelemetryProto.metrics.v1 as METRICS

import OpenTelemetryProto.common.v1 as COMMON
import OpenTelemetryProto.resource.v1 as RESOURCE

struct OtlpHttpExporter{Req,Resp} <: SDK.AbstractExporter
    url::String
    headers::Vector{Pair{String,String}}
    timeout::Float64
end

OtlpHttpLogsExporter(;
    url = OTEL_EXPORTER_OTLP_LOGS_ENDPOINT(),
    headers = OTEL_EXPORTER_OTLP_LOGS_HEADERS(),
    timeout = OTEL_EXPORTER_OTLP_LOGS_TIMEOUT(),
) =
    OtlpHttpExporter{COLL_LOGS.ExportLogsServiceRequest,COLL_LOGS.ExportLogsServiceResponse}(
        url,
        headers,
        timeout,
    )

OtlpHttpTracesExporter(;
    url = OTEL_EXPORTER_OTLP_TRACES_ENDPOINT(),
    headers = OTEL_EXPORTER_OTLP_TRACES_HEADERS(),
    timeout = OTEL_EXPORTER_OTLP_TRACES_TIMEOUT(),
) = OtlpHttpExporter{
    COLL_TRACES.ExportTraceServiceRequest,
    COLL_TRACES.ExportTraceServiceResponse,
}(
    url,
    headers,
    timeout,
)

OtlpHttpMetricsExporter(;
    url = OTEL_EXPORTER_OTLP_METRICS_ENDPOINT(),
    headers = OTEL_EXPORTER_OTLP_METRICS_HEADERS(),
    timeout = OTEL_EXPORTER_OTLP_METRICS_TIMEOUT(),
) = OtlpHttpExporter{
    COLL_METRICS.ExportMetricsServiceRequest,
    COLL_METRICS.ExportMetricsServiceResponse,
}(
    url,
    headers,
    timeout,
)

function SDK.export!(x::OtlpHttpExporter{Req,Resp}, batch) where {Req,Resp}
    res = SDK.EXPORT_FAILURE
    HTTP.open("GET", x.url, x.headers; readtimeout = x.timeout) do io
        e = ProtoEncoder(io)
        encode(e, convert(Req, batch))
        while !eof(io)
            d = ProtoDecoder(io)
            resp = decode(d, Resp)
            res = convert(SDK.ExportResult, resp)
        end
    end
    res
end

include("convert.jl")

end # module
