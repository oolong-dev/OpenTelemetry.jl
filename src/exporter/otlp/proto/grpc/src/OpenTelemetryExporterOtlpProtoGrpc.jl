module OpenTelemetryExporterOtlpProtoGrpc

export OtlpProtoGrpcTraceExporter

using gRPCClient

import OpenTelemetryAPI
import OpenTelemetrySDK
import OpenTelemetryProto

const API = OpenTelemetryAPI
const SDK = OpenTelemetrySDK
const Otlp = OpenTelemetryProto.OpentelemetryClients
const Trace = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.trace.v1
const Resource = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.resource.v1
const Common = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.common.v1

struct OtlpProtoGrpcTraceExporter{T} <: SDK.AbstractExporter
    client::T
end

function OtlpProtoGrpcTraceExporter(; url = "http://localhost:4317", is_blocking = true, kw...)
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

Base.convert(t::Type{Otlp.ExportTraceServiceRequest}, s::API.Span) = convert(t, [s])

function Base.convert(::Type{Otlp.ExportTraceServiceRequest}, spans::Vector)
    Otlp.ExportTraceServiceRequest(
        resource_spans = [
            Trace.ResourceSpans(
                resource = convert(Resource.Resource, spans[1].tracer.provider.resource),
                schema_url = spans[1].tracer.provider.resource.schema_url,
                # Typically only one element is contained
                # TODO: maybe group spans by resource first?
                instrumentation_library_spans = [
                    convert(Trace.InstrumentationLibrarySpans, spans),
                ],
            ),
        ],
    )
end

function Base.convert(::Type{Resource.Resource}, r::SDK.Resource)
    Resource.Resource(
        attributes = convert(Vector{Common.KeyValue}, r.attributes),
        dropped_attributes_count = API.n_dropped(r.attributes),
    )
end

function Base.convert(::Type{Trace.InstrumentationLibrarySpans}, spans::Vector)
    Trace.InstrumentationLibrarySpans(
        instrumentation_library = convert(
            Common.InstrumentationLibrary,
            spans[1].tracer.instrumentation,
        ),
        schema_url = spans[1].tracer.provider.resource.schema_url,
        spans = [convert(Trace.Span, s) for s in spans],
    )
end

function Base.convert(::Type{Common.InstrumentationLibrary}, info::API.InstrumentationInfo)
    Common.InstrumentationLibrary(name = info.name, version = string(info.version))
end

# TODO: use method call instead of accessing field directly
function Base.convert(::Type{Trace.Span}, s::API.Span)
    Trace.Span(
        trace_id = reinterpret(UInt8, [API.span_context(s).trace_id]),
        span_id = reinterpret(UInt8, [API.span_context(s).span_id]),
        trace_state = string(API.span_context(s).trace_state),
        parent_span_id = if isnothing(s.parent_span_context)
            UInt8[]
        else
            reinterpret(UInt8, [s.parent_span_context.span_id])
        end,
        name = s.name[],
        kind = Int32(s.kind),
        start_time_unix_nano = s.start_time,
        end_time_unix_nano = s.end_time[],
        attributes = convert(Vector{Common.KeyValue}, s.attributes),
        dropped_attributes_count = UInt32(API.n_dropped(s.attributes)),
        events = [convert(Trace.Span_Event, e) for e in s.events],
        dropped_events_count = UInt32(API.n_dropped(s.events)),
        links = [convert(Trace.Span_Link, e) for e in s.links],
        dropped_links_count = UInt32(API.n_dropped(s.links)),
        status = convert(Trace.Status, s.status[]),
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

function Base.convert(::Type{Trace.Status}, status::SDK.SpanStatus)
    Trace.Status(code = Int32(status.code), message = something(status.description, ""))
end

end # module
