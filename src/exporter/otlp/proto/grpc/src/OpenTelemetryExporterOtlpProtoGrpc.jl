module OpenTelemetryExporterOtlpProtoGrpc

export OtlpProtoGrpcTraceExporter

using gRPCClient
using URIs

import OpenTelemetryAPI
import OpenTelemetrySDK
import OpenTelemetryProto

const API = OpenTelemetryAPI
const SDK = OpenTelemetrySDK
const Otlp = OpenTelemetryProto.OpentelemetryClients
const Trace = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.trace.v1
const Resource = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.resource.v1
const Common = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.common.v1

#####

struct OtlpProtoGrpcTraceExporter{T} <: SDK.AbstractExporter
    client::T
end

"""
    OtlpProtoGrpcTraceExporter(;kw...)

## Keyword arguments

  - `scheme=http`
  - `host="localhost"`
  - `port=4317`
  - `is_blocking=true`, by default the `BlockingClient` is used.
  - Rest keyword arguments will be forward to the gRPC client.

`scheme`, `host` and `port` specifies the OTEL Collector to connect with.
"""
function OtlpProtoGrpcTraceExporter(;
    scheme = "http",
    host = "localhost",
    port = 4317,
    is_blocking = true,
    kw...,
)
    url = string(URI(; scheme = scheme, host = host, port = port))
    if is_blocking
        client = Otlp.TraceServiceBlockingClient(url; kw...)
    else
        client = Otlp.TraceServiceClient(url; kw...)
    end
    OtlpProtoGrpcTraceExporter(client)
end

function SDK.export!(se::OtlpProtoGrpcTraceExporter, sp)
    res, status = Otlp.Export(se.client, convert(Otlp.ExportTraceServiceRequest, sp))
    if gRPCClient.gRPCCheck(status; throw_error = false)
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end
end

Base.convert(t::Type{Otlp.ExportTraceServiceRequest}, s::API.AbstractSpan) = convert(t, [s])

function Base.convert(::Type{Otlp.ExportTraceServiceRequest}, spans)
    r = Otlp.ExportTraceServiceRequest(; resource_spans = [])
    s_res_pre = nothing
    s_ins_pre = nothing
    for s in spans
        s_res = API.resource(s)
        if s_res != s_res_pre
            push!(
                r.resource_spans,
                Trace.ResourceSpans(
                    resource = convert(Resource.Resource, s_res),
                    schema_url = s_res.schema_url,
                    instrumentation_library_spans = [],
                ),
            )
        end
        s_ins = API.tracer(s).instrumentation
        if s_ins != s_ins_pre
            push!(
                r.resource_spans[end].instrumentation_library_spans,
                Trace.InstrumentationLibrarySpans(
                    instrumentation_library = convert(Common.InstrumentationLibrary, s_ins),
                    schema_url = "",
                    spans = [],
                ),
            )
        end

        push!(
            r.resource_spans[end].instrumentation_library_spans[end].spans,
            convert(Trace.Span, s),
        )

        s_res_pre = s_res
        s_ins_pre = s_ins
    end
    r
end

function Base.convert(::Type{Resource.Resource}, r::API.Resource)
    Resource.Resource(
        attributes = convert(Vector{Common.KeyValue}, r.attributes),
        dropped_attributes_count = API.n_dropped(r.attributes),
    )
end

function Base.convert(::Type{Common.InstrumentationLibrary}, info::API.InstrumentationInfo)
    Common.InstrumentationLibrary(name = info.name, version = string(info.version))
end

# TODO: use method call instead of accessing field directly
function Base.convert(::Type{Trace.Span}, s::API.AbstractSpan)
    Trace.Span(
        trace_id = reinterpret(UInt8, [API.span_context(s).trace_id]),
        span_id = reinterpret(UInt8, [API.span_context(s).span_id]),
        trace_state = string(API.span_context(s).trace_state),
        parent_span_id = if isnothing(API.parent_span_context(s))
            UInt8[]
        else
            reinterpret(UInt8, [API.parent_span_context(s).span_id])
        end,
        name = API.span_name(s),
        kind = Int32(API.span_kind(s)),
        start_time_unix_nano = API.start_time(s),
        end_time_unix_nano = API.end_time(s),
        attributes = convert(Vector{Common.KeyValue}, API.attributes(s)),
        dropped_attributes_count = UInt32(API.n_dropped(API.attributes(s))),
        events = [convert(Trace.Span_Event, e) for e in API.span_events(s)],
        dropped_events_count = UInt32(API.n_dropped(API.span_events(s))),
        links = [convert(Trace.Span_Link, e) for e in API.span_links(s)],
        dropped_links_count = UInt32(API.n_dropped(API.span_links(s))),
        status = convert(Trace.Status, API.span_status(s)),
    )
end

function Base.convert(
    ::Type{Vector{Common.KeyValue}},
    attrs::Union{API.StaticAttrs,API.DynamicAttrs},
)
    [
        Common.KeyValue(key = k, value = convert(Common.AnyValue, v)) for
        (k, v) in pairs(attrs)
    ]
end

Base.convert(::Type{Common.AnyValue}, v::String) = Common.AnyValue(string_value = v)
Base.convert(::Type{Common.AnyValue}, v::Bool) = Common.AnyValue(bool_value = v)
Base.convert(::Type{Common.AnyValue}, v::Int) = Common.AnyValue(int_value = v)
Base.convert(::Type{Common.AnyValue}, v::Float64) = Common.AnyValue(double_value = v)
Base.convert(::Type{Common.AnyValue}, v::Vector{UInt8}) = Common.AnyValue(bytes_value = v)
Base.convert(::Type{Common.AnyValue}, v::Vector) =
    Common.AnyValue(array_value = convert(Common.ArrayValue, v))
Base.convert(::Type{Common.AnyValue}, v::Union{API.StaticAttrs,API.DynamicAttrs}) =
    Common.AnyValue(kvlist_value = convert(Common.KeyValueList, v))

Base.convert(::Type{Common.ArrayValue}, v::Vector) =
    Common.ArrayValue(values = [convert(Common.AnyValue, x) for x in v])
Base.convert(::Type{Common.KeyValueList}, v::Union{API.StaticAttrs,API.DynamicAttrs}) =
    Common.KeyValueList(values = convert(Vector{Common.KeyValue}, v))

function Base.convert(::Type{Trace.Span_Event}, event::API.Event)
    Trace.Span_Event(
        time_unix_nano = event.timestamp,
        name = event.name,
        attributes = convert(Vector{Common.KeyValue}, event.attributes),
        dropped_attributes_count = API.n_dropped(event.attributes),
    )
end

function Base.convert(::Type{Trace.Span_Link}, link::API.Link)
    Trace.Span_Link(
        trace_id = reinterpret(UInt8, [link.context.trace_id]),
        span_id = reinterpret(UInt8, [link.context.span_id]),
        trace_state = string(link.context.trace_state),
        attributes = convert(Vector{Common.KeyValue}, link.attributes),
        dropped_attributes_count = API.n_dropped(link.attributes),
    )
end

function Base.convert(::Type{Trace.Status}, status::API.SpanStatus)
    Trace.Status(code = Int32(status.code), message = something(status.description, ""))
end

#####

struct OtlpProtoGrpcMetricsExporter{T} <: SDK.AbstractExporter
    client::T
end

"""
    OtlpProtoGrpcMetricsExporter(;kw...)

## Keyword arguments

  - `scheme=http`
  - `host="localhost"`
  - `port=4317`
  - `is_blocking=true`, by default the `BlockingClient` is used.
  - Rest keyword arguments will be forward to the gRPC client.

`scheme`, `host` and `port` specifies the OTEL Collector to connect with.
"""
function OtlpProtoGrpcMetricExporter(;
    scheme = "http",
    host = "localhost",
    port = 4317,
    is_blocking = true,
    kw...,
)
    url = string(URI(; scheme = scheme, host = host, port = port))
    if is_blocking
        client = Otlp.TraceServiceBlockingClient(url; kw...)
    else
        client = Otlp.TraceServiceClient(url; kw...)
    end
    OtlpProtoGrpcTraceExporter(client)
end

end # module
