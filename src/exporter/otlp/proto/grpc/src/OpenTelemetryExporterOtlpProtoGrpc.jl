module OpenTelemetryExporterOtlpProtoGrpc

export OtlpProtoGrpcTraceExporter

using gRPCClient
using URIs

import OpenTelemetryAPI
import OpenTelemetrySDK
import OpenTelemetryProto

import Logging

const API = OpenTelemetryAPI
const SDK = OpenTelemetrySDK
const Otlp = OpenTelemetryProto.OpentelemetryClients
const Trace = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.trace.v1
const Metrics = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.metrics.v1
const Logs = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.logs.v1
const CollectorTrace =
    OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.trace.v1
const CollectorMetrics =
    OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.metrics.v1
const CollectorLogs =
    OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.logs.v1
const Resource = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.resource.v1
const Common = OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.common.v1

##### Traces

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
    res, status = CollectorTrace.Export(
        se.client,
        convert(CollectorTrace.ExportTraceServiceRequest, sp),
    )
    if gRPCClient.gRPCCheck(status; throw_error = false)
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end
end

Base.convert(t::Type{CollectorTrace.ExportTraceServiceRequest}, s::API.AbstractSpan) =
    convert(t, [s])

Base.convert(
    ::Type{CollectorTrace.ExportTraceServiceRequest},
    s::CollectorTrace.ExportTraceServiceRequest,
) = s

function Base.convert(::Type{CollectorTrace.ExportTraceServiceRequest}, spans)
    r = CollectorTrace.ExportTraceServiceRequest(; resource_spans = [])
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
        s_ins = API.tracer(s).instrumentation_info
        if s_ins != s_ins_pre
            push!(
                r.resource_spans[end].instrumentation_library_spans,
                Trace.InstrumentationLibrarySpans(
                    instrumentation_library = convert(Common.InstrumentationLibrary, s_ins),
                    schema_url = s_ins.schema_url,
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
    attrs::Union{API.StaticBoundedAttributes,API.DynamicAttrs},
)
    [
        Common.KeyValue(key = string(k), value = convert(Common.AnyValue, v)) for
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
Base.convert(
    ::Type{Common.AnyValue},
    v::Union{API.StaticBoundedAttributes,API.DynamicAttrs},
) = Common.AnyValue(kvlist_value = convert(Common.KeyValueList, v))

Base.convert(::Type{Common.ArrayValue}, v::Vector) =
    Common.ArrayValue(values = [convert(Common.AnyValue, x) for x in v])
Base.convert(
    ::Type{Common.KeyValueList},
    v::Union{API.StaticBoundedAttributes,API.DynamicAttrs},
) = Common.KeyValueList(values = convert(Vector{Common.KeyValue}, v))

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

##### Metrics

export OtlpProtoGrpcMetricsExporter

struct OtlpProtoGrpcMetricsExporter{T} <: SDK.AbstractExporter
    client::T
end

"""
    OtlpProtoGrpcMetricsExporter(;kw...)

This exporter is push-based.

## Keyword arguments

  - `scheme=http`
  - `host="localhost"`
  - `port=4317`
  - `is_blocking=true`, by default the `BlockingClient` is used.
  - Rest keyword arguments will be forward to the gRPC client.

`scheme`, `host` and `port` specifies the OTEL Collector to connect with.
"""
function OtlpProtoGrpcMetricsExporter(;
    scheme = "http",
    host = "localhost",
    port = 4317,
    is_blocking = true,
    kw...,
)
    url = string(URI(; scheme = scheme, host = host, port = port))
    if is_blocking
        client = Otlp.MetricsServiceBlockingClient(url; kw...)
    else
        client = Otlp.MetricsServiceClient(url; kw...)
    end
    OtlpProtoGrpcMetricsExporter(client)
end

function SDK.export!(e::OtlpProtoGrpcMetricsExporter, ms)
    res, status = CollectorMetrics.Export(
        e.client,
        convert(CollectorMetrics.ExportMetricsServiceRequest, ms),
    )
    if gRPCClient.gRPCCheck(status; throw_error = false)
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end
end

Base.convert(t::Type{CollectorMetrics.ExportMetricsServiceRequest}, s::SDK.Metric) =
    convert(t, [s])

Base.convert(
    t::Type{CollectorMetrics.ExportMetricsServiceRequest},
    ms::CollectorMetrics.ExportMetricsServiceRequest,
) = ms

function Base.convert(t::Type{CollectorMetrics.ExportMetricsServiceRequest}, ms)
    r = CollectorMetrics.ExportMetricsServiceRequest(; resource_metrics = [])
    m_res_pre = nothing
    m_ins_pre = nothing
    for m in ms
        m_res = API.resource(m)
        if m_res != m_res_pre
            push!(
                r.resource_metrics,
                Metrics.ResourceMetrics(
                    resource = convert(Resource.Resource, m_res),
                    schema_url = m_res.schema_url,
                    instrumentation_library_metrics = [],
                ),
            )
        end
        m_ins = m.instrument.meter.instrumentation_info
        if m_ins != m_ins_pre
            push!(
                r.resource_metrics[end].instrumentation_library_metrics,
                Metrics.InstrumentationLibraryMetrics(
                    instrumentation_library = convert(Common.InstrumentationLibrary, m_ins),
                    schema_url = m_ins.schema_url,
                    metrics = [],
                ),
            )
        end

        push!(
            r.resource_metrics[end].instrumentation_library_metrics[end].metrics,
            convert(Metrics.Metric, m),
        )

        m_res_pre = m_res
        m_ins_pre = m_ins
    end
    r
end

function Base.convert(::Type{Metrics.Metric}, m::SDK.Metric{<:SDK.LastValueAgg})
    Metrics.Metric(
        name = m.name,
        description = m.description,
        unit = m.instrument.unit,
        gauge = convert(Metrics.Gauge, m.aggregation),
    )
end

function Base.convert(::Type{Metrics.Gauge}, agg::SDK.LastValueAgg)
    Metrics.Gauge(data_points = convert(Vector{Metrics.NumberDataPoint}, agg.agg_store))
end

function Base.convert(
    ::Type{Vector{Metrics.NumberDataPoint}},
    agg_store::SDK.AggregationStore,
)
    data_points = Metrics.NumberDataPoint[]
    for (attr, data_point) in agg_store
        if data_point.value isa Integer
            push!(
                data_points,
                Metrics.NumberDataPoint(
                    attributes = convert(Vector{Common.KeyValue}, attr),
                    start_time_unix_nano = data_point.start_time_unix_nano,
                    time_unix_nano = data_point.time_unix_nano,
                    as_int = data_point.value,
                    exemplars = [], # TODO
                    flags = Metrics.DataPointFlags.FLAG_NONE,
                ),
            )
        else
            push!(
                data_points,
                Metrics.NumberDataPoint(
                    attributes = convert(Vector{Common.KeyValue}, attr),
                    # start_time_unix_nano = data_point.start_time_unix_nano,
                    time_unix_nano = data_point.time_unix_nano,
                    as_double = data_point.value,
                    exemplars = [], # TODO
                    flags = Metrics.DataPointFlags.FLAG_NONE,
                ),
            )
        end
    end
    data_points
end

function Base.convert(::Type{Metrics.Metric}, m::SDK.Metric{<:SDK.SumAgg})
    Metrics.Metric(
        name = m.name,
        description = m.description,
        unit = m.instrument.unit,
        sum = convert(Metrics.Sum, m.aggregation),
    )
end

function Base.convert(::Type{Metrics.Sum}, agg::SDK.SumAgg)
    Metrics.Sum(
        data_points = convert(Vector{Metrics.NumberDataPoint}, agg.agg_store),
        aggregation_temporality = Metrics.AggregationTemporality.AGGREGATION_TEMPORALITY_CUMULATIVE,  # TODO
        is_monotonic = false, # TODO
    )
end

function Base.convert(::Type{Metrics.Metric}, m::SDK.Metric{<:SDK.HistogramAgg})
    Metrics.Metric(
        name = m.name,
        description = m.description,
        unit = m.instrument.unit,
        histogram = convert(Metrics.Histogram, m.aggregation),
    )
end

function Base.convert(::Type{Metrics.Histogram}, agg::SDK.HistogramAgg)
    Metrics.Histogram(
        data_points = convert(Vector{Metrics.HistogramDataPoint}, agg.agg_store),
        aggregation_temporality = Metrics.AggregationTemporality.AGGREGATION_TEMPORALITY_CUMULATIVE,  # TODO
    )
end

function Base.convert(
    ::Type{Vector{Metrics.HistogramDataPoint}},
    agg_store::SDK.AggregationStore,
)
    [
        Metrics.HistogramDataPoint(
            attributes = convert(Vector{Common.KeyValue}, attr),
            start_time_unix_nano = data_point.start_time_unix_nano,
            time_unix_nano = data_point.time_unix_nano,
            count = sum(data_point.value.counts),
            sum = something(data_point.value.sum, 0),
            bucket_counts = [Float64(x) for x in data_point.value.counts],
            explicit_bounds = collect(data_point.value.boundaries),
            exemplars = [], # TODO
            flags = Metrics.DataPointFlags.FLAG_NONE,
        ) for (attr, data_point) in agg_store
    ]
end

##### Logs

export OtlpProtoGrpcLogsExporter

struct OtlpProtoGrpcLogsExporter{T} <: SDK.AbstractExporter
    client::T
end

"""
    OtlpProtoGrpcLogsExporter(;kw...)

This can be used as a **sink** in [`LoggingExtras.jl`](https://github.com/JuliaLogging/LoggingExtras.jl).

!!! note
    
    This logger only export one [`LogRecord`](@ref) at a time. A batched version may be provided later.

## Keyword arguments

  - `scheme=http`
  - `host="localhost"`
  - `port=4317`
  - `is_blocking=true`, by default the `BlockingClient` is used.
  - Rest keyword arguments will be forward to the gRPC client.

`scheme`, `host` and `port` specifies the OTEL Collector to connect with.
"""
function OtlpProtoGrpcLogsExporter(;
    scheme = "http",
    host = "localhost",
    port = 4317,
    is_blocking = true,
    kw...,
)
    url = string(URI(; scheme = scheme, host = host, port = port))
    if is_blocking
        client = Otlp.LogsServiceBlockingClient(url; kw...)
    else
        client = Otlp.LogsServiceClient(url; kw...)
    end
    OtlpProtoGrpcLogsExporter(client)
end

function SDK.export!(e::OtlpProtoGrpcLogsExporter, logs)
    res, status = CollectorLogs.Export(
        e.client,
        convert(CollectorLogs.ExportLogsServiceRequest, logs),
    )
    if gRPCClient.gRPCCheck(status; throw_error = false)
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end
end

Base.convert(t::Type{CollectorLogs.ExportLogsServiceRequest}, s::SDK.LogRecord) =
    convert(t, [s])

Base.convert(
    t::Type{CollectorLogs.ExportLogsServiceRequest},
    r::CollectorLogs.ExportLogsServiceRequest,
) = r

function Base.convert(t::Type{CollectorLogs.ExportLogsServiceRequest}, log_records)
    CollectorLogs.ExportLogsServiceRequest(
        resource_logs = [
            Logs.ResourceLogs(
                resource = convert(Resource.Resource, first(log_records).resource),
                schema_url = first(log_records).resource.schema_url,
                instrumentation_library_logs = [
                    Logs.InstrumentationLibraryLogs(
                        instrumentation_library = convert(
                            Common.InstrumentationLibrary,
                            first(log_records).instrumentation_info,
                        ),
                        log_records = [
                            Logs.LogRecord(
                                time_unix_nano = r.timestamp,
                                observed_time_unix_nano = UInt(time() * 10^9),
                                severity_number = r.severity_number,
                                severity_text = r.severity_text,
                                body = convert(Common.AnyValue, r.body),
                                attributes = convert(Vector{Common.KeyValue}, r.attributes),
                                dropped_attributes_count = API.n_dropped(r.attributes),
                                trace_id = reinterpret(UInt8, [r.trace_id]),
                                span_id = reinterpret(UInt8, [r.span_id]),
                                flags = r.trace_flags.sampled ? Int32(1) : Int32(0),
                            ) for r in log_records
                        ],
                        schema_url = first(log_records).instrumentation_info.schema_url,
                    ),
                ],
            ),
        ],
    )
end

function Logging.handle_message(
    logger::OtlpProtoGrpcLogsExporter,
    log_record, # single LogRecord or an iterator of LogRecords
)
    SDK.export!(logger, log_record)
end

Logging.shouldlog(logger::OtlpProtoGrpcLogsExporter, arg...) = true
Logging.min_enabled_level(logger::OtlpProtoGrpcLogsExporter) = Logging.BelowMinLevel
Logging.catch_exceptions(logger::OtlpProtoGrpcLogsExporter) = true
end # module
