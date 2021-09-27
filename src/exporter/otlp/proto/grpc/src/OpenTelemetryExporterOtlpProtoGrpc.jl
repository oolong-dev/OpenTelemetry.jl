module OpenTelemetryExporterOtlpProtoGrpc

import OpenTelemetrySDK
import OpenTelemetryProto

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

function export!(se::OtlpProtoGrpcExporter, sp)
    res, status = Otlp.Export(se.client, convert(Otlp.ExportTraceServiceRequest, sp))
    if gRPCClient.gRPCCheck(status;throw_error=false)
        SDK.SUCCESS
    else
        SDK.FAILURE
    end
end

Base.convert(t::Type{Otlp.ExportTraceServiceRequest}, s::SDK.WrappedSpan) = convert(t, [s])

function Base.convert(::Type{Otlp.ExportTraceServiceRequest}, spans::Vector{SDK.WrappedSpan})
    Otlp.ExportTraceServiceRequest(
        Trace.ResourceSpans(
            resource = convert(Resource.Resource, spans[1].resource),
            schema_url = spans[1].resource.schema_url,
            # Typically only one element is contained
            # TODO: maybe group spans by resource first?
            instrumentation_library_spans = [
                convert(Trace.InstrumentationLibrarySpans, spans)
            ]
        )
    )
end

function Base.convert(::Type{Resource.Resource}, r::SDK.Resource)
    Resource.Resource(
        attributes = convert(Vector{Common.KeyValue}, r.attributes),
        dropped_attributes_count = SDK.n_dropped(r.attributes)
    )
end

function Base.convert(::Type{Trace.InstrumentationLibrarySpans}, spans::Vector{SDK.WrappedSpan})
    Trace.InstrumentationLibrarySpans(
        instrumentation_library = convert(Common.InstrumentationLibrary, spans[1].instrumentation_info),
        schema_url = spans[1].resource.schema_url,
        spans = [convert(Trace.Span, s) for s in spans]
    )
end

function Base.convert(::Type{Common.InstrumentationLibrary}, info::SDK.InstrumentationInfo)
    Common.InstrumentationLibrary(
        name = info.name,
        version = string(info.version)
    )
end

# TODO: use method call instead of access field directly
function Base.convert(::Type{Trace.Span}, s::SDK.WrappedSpan)
    Trace.Span(
        trace_id = reinterpret(UInt8, [span_context(s).trace_id]),
        span_id = reinterpret(UInt8, [span_context(s).span_id]),
        trace_state = string(span_context(s).trace_state),
        parent_span_id = isnothing(s.span.parent_span_context) ? UInt8[] : reinterpret(UInt8, [s.span.parent_span_context.span_id]),
        name = s.span.name,
        kind = Int32(s.span.kind),
        start_time_unix_nano = s.span.start_time * 1_000,
        end_time_unix_nano = s.span.end_time * 1_000,
        attributes = convert(Vector{Common.KeyValue}, s.span.attributes),
        dropped_attributes_count = UInt32(SDK.n_dropped(s.span.attributes)),
        events = [convert(Trace.Event, e) for e in s.span.events.xs],
        dropped_events_count = UInt32(SDK.n_dropped(s.span.events)),
        links = [convert(Trace.Link, e) for e in s.span.links.xs],
        dropped_links_count = UInt32(SDK.n_dropped(s.span.links)),
        status = convert(Trace.Status, s.span.status)
    )
end

function Base.convert(::Type{Vector{Common.KeyValue}}, attrs::SDK.Attributes)
    [
        Common.KeyValue(
            key = k,
            value = convert(Common.AnyValue, v)
        )
        for (k, v) in pairs(attrs.kv.xs)
    ]
end

Base.convert(::Type{Common.AnyValue}, v::String) = Common.AnyValue(string_value=v)
Base.convert(::Type{Common.AnyValue}, v::Bool) = Common.AnyValue(bool_value=v)
Base.convert(::Type{Common.AnyValue}, v::Int) = Common.AnyValue(int_value=v)
Base.convert(::Type{Common.AnyValue}, v::Float64) = Common.AnyValue(double_value=v)
Base.convert(::Type{Common.AnyValue}, v::Vector{UInt8}) = Common.AnyValue(bytes_value=v)
Base.convert(::Type{Common.AnyValue}, v::Vector) = Common.AnyValue(array_value=convert(Common.ArrayValue, v))
Base.convert(::Type{Common.AnyValue}, v::Attributes) = Common.AnyValue(kvlist_value=convert(Common.KeyValueList, v))

Base.convert(::Type{Common.ArrayValue}, v::Vector) = Common.ArrayValue(values=[convert(Common.AnyValue, x) for x in v])
Base.convert(::Type{Common.KeyValueList}, v::Attributes) = Common.KeyValueList(values=convert(Vector{Common.KeyValue}, v))

function Base.convert(::Type{Trace.Event}, event::SDK.Event)
    Trace.Event(
        time_unix_nano = event.timestamp * 1_000,
        name = event.name,
        attributes = convert(Vector{Common.KeyValue}, event.attributes),
        dropped_attributes_count = SDK.n_dropped(event.attributes)
    )
end

function Base.convert(::Type{Trace.Link}, link::SDK.Link)
    Trace.Link(
        trace_id = reinterpret(UInt8, [link.context.trace_id]),
        span_id = reinterpret(UInt8, [link.context.span_id]),
        trace_state = string(link.context.trace_state),
        attributes = convert(Vector{Common.KeyValue}, link.attributes),
        dropped_attributes_count = SDK.n_dropped(link.attributes)
    )
end

function Base.convert(::Type{Trace.Status}, status::SDK.SpanStatus)
    Trace.Status(
        code = Int32(status.code),
        message = something(status.description, "")
    )
end

end # module
