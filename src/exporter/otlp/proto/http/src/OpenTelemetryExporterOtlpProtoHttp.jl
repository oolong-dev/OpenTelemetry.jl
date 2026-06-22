module OpenTelemetryExporterOtlpProtoHttp

export OtlpHttpLogsExporter, OtlpHttpTracesExporter, OtlpHttpMetricsExporter

using ProtoBuf

import HTTP

import OpenTelemetryAPI as API
import OpenTelemetrySDK as SDK

import OpenTelemetryProto.opentelemetry.proto.collector.logs.v1 as COLL_LOGS
import OpenTelemetryProto.opentelemetry.proto.collector.trace.v1 as COLL_TRACES
import OpenTelemetryProto.opentelemetry.proto.collector.metrics.v1 as COLL_METRICS

import OpenTelemetryProto.opentelemetry.proto.logs.v1 as LOGS
import OpenTelemetryProto.opentelemetry.proto.trace.v1 as TRACES
import OpenTelemetryProto.opentelemetry.proto.metrics.v1 as METRICS

import OpenTelemetryProto.opentelemetry.proto.common.v1 as COMMON
import OpenTelemetryProto.opentelemetry.proto.resource.v1 as RESOURCE

# HTTP.jl 2.0 renamed the request-wide deadline keyword: `readtimeout` (HTTP 1.x)
# became a deprecated alias mapping to the inactivity-based `read_idle_timeout`,
# while overall request deadlines now use `request_timeout`. Detect the major
# version once at load time and pick the right keyword. `pkgversion` exists since
# Julia 1.9; HTTP 2 itself requires Julia >= 1.10, so on older Julia (no
# `pkgversion`) only HTTP 1 can be installed and `false` is the correct default.
const _HTTP_V2 = isdefined(Base, :pkgversion) ? Base.pkgversion(HTTP) >= v"2" : false

struct OtlpHttpExporter{Req,Resp} <: SDK.AbstractExporter
    url::String
    headers::Vector{Pair{String,String}}
    timeout::Int
    function OtlpHttpExporter{Req,Resp}(url, headers, timeout) where {Req,Resp}
        push!(headers, "Content-Type" => "application/x-protobuf") # TODO: detect duplicate?
        new{Req,Resp}(url, headers, timeout)
    end
end

OtlpHttpLogsExporter(;
    url = API.OTEL_EXPORTER_OTLP_LOGS_ENDPOINT(),
    headers = API.OTEL_EXPORTER_OTLP_LOGS_HEADERS(),
    timeout = API.OTEL_EXPORTER_OTLP_LOGS_TIMEOUT(),
) =
    OtlpHttpExporter{COLL_LOGS.ExportLogsServiceRequest,COLL_LOGS.ExportLogsServiceResponse}(
        "$url/v1/logs",
        headers,
        timeout,
    )

OtlpHttpTracesExporter(;
    url = API.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT(),
    headers = API.OTEL_EXPORTER_OTLP_TRACES_HEADERS(),
    timeout = API.OTEL_EXPORTER_OTLP_TRACES_TIMEOUT(),
) = OtlpHttpExporter{
    COLL_TRACES.ExportTraceServiceRequest,
    COLL_TRACES.ExportTraceServiceResponse,
}(
    "$url/v1/traces",
    headers,
    timeout,
)

OtlpHttpMetricsExporter(;
    url = API.OTEL_EXPORTER_OTLP_METRICS_ENDPOINT(),
    headers = API.OTEL_EXPORTER_OTLP_METRICS_HEADERS(),
    timeout = API.OTEL_EXPORTER_OTLP_METRICS_TIMEOUT(),
) = OtlpHttpExporter{
    COLL_METRICS.ExportMetricsServiceRequest,
    COLL_METRICS.ExportMetricsServiceResponse,
}(
    "$url/v1/metrics",
    headers,
    timeout,
)

function SDK.export!(x::OtlpHttpExporter{Req,Resp}, batch::Union{AbstractVector, Base.IdSet}) where {Req,Resp}
    isempty(batch) && return SDK.EXPORT_SUCCESS

    try
        io = IOBuffer()
        e = ProtoEncoder(io)
        encode(e, convert(Req, batch))
        seekstart(io)

        # `retry` / `retry_non_idempotent` remain valid keywords in both HTTP 1.x
        # and 2.x; only the timeout keyword changed (see `_HTTP_V2` above).
        timeout_kw = _HTTP_V2 ? (; request_timeout = x.timeout) : (; readtimeout = x.timeout)

        res = API.with_context(; API.SUPPRESS_INSTRUMENTATION_KEY => true) do
            HTTP.post(
                x.url,
                x.headers;
                body = io,
                retry = true,
                retry_non_idempotent = true,
                timeout_kw...,
            )
        end

        res_io = IOBuffer(res.body)
        d = ProtoDecoder(res_io)
        resp = decode(d, Resp)
        return convert(SDK.ExportResult, resp)
    catch ex
        @error(
            "Error in OtlpHttpExporter, the attempted batch export failed and will not be retried anymore. " *
            "The batch will not be returned to the queue either.",
            exception=(ex, stacktrace(catch_backtrace()))
        )
        return SDK.EXPORT_FAILURE
    end
end

include("convert.jl")

end # module
