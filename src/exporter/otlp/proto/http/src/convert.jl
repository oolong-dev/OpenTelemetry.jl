Base.convert(::Type{SDK.ExportResult}, resp::COLL_LOGS.ExportLogsServiceResponse) =
    if isnothing(resp.partial_success) || resp.partial_success.rejected_log_records == 0
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end

Base.convert(::Type{SDK.ExportResult}, resp::COLL_TRACES.ExportTraceServiceResponse) =
    if isnothing(resp.partial_success) || resp.partial_success.rejected_spans == 0
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end

Base.convert(::Type{SDK.ExportResult}, resp::COLL_METRICS.ExportMetricsServiceResponse) =
    if isnothing(resp.partial_success) || resp.partial_success.rejected_data_points == 0
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end


"""
uint2uint8(u::Unsigned)

Converts any UInt into Network byte order (big-endian) UInt8 vector
"""
uint2uint8(u::Unsigned) = reinterpret(UInt8, [hton(u)])

# Resource

# !!! The dropped attributes of `Resource` is always 0
# !!! The attributes of `Resource` is a `NamedTuple` instead of `BoundedAttributes`
Base.convert(::Type{RESOURCE.Resource}, r::API.Resource) =
    RESOURCE.Resource(convert(Vector{COMMON.KeyValue}, r.attributes), 0)

Base.convert(::Type{Vector{COMMON.KeyValue}}, attrs::API.BoundedAttributes) =
    [convert(COMMON.KeyValue, kv) for kv in pairs(attrs)]

Base.convert(::Type{COMMON.KeyValue}, x::Pair) =
    COMMON.KeyValue(string(first(x)), convert(COMMON.AnyValue, last(x)))

# https://github.com/oolong-dev/OpenTelemetry.jl/issues/82
Base.convert(::Type{COMMON.AnyValue}, x::Any) =
    COMMON.AnyValue(OneOf(:string_value, repr(x)))
Base.convert(::Type{COMMON.AnyValue}, x::COMMON.AnyValue) = x

Base.convert(::Type{COMMON.AnyValue}, x::SubString) =
    COMMON.AnyValue(OneOf(:string_value, string(x)))
Base.convert(::Type{COMMON.AnyValue}, x::String) = COMMON.AnyValue(OneOf(:string_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::Bool) = COMMON.AnyValue(OneOf(:bool_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::Int) = COMMON.AnyValue(OneOf(:int_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::Integer) =
    COMMON.AnyValue(OneOf(:int_value, convert(Int, x)))
Base.convert(::Type{COMMON.AnyValue}, x::Float64) = COMMON.AnyValue(OneOf(:double_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::AbstractFloat) =
    COMMON.AnyValue(OneOf(:double_value, convert(Float64, x)))
Base.convert(::Type{COMMON.AnyValue}, x::Vector{UInt8}) =
    COMMON.AnyValue(OneOf(:bytes_value, x))

Base.convert(::Type{COMMON.AnyValue}, x::AbstractArray) =
    COMMON.AnyValue(OneOf(:array_value, convert(COMMON.ArrayValue, x)))

Base.convert(::Type{COMMON.ArrayValue}, xs::AbstractArray) =
    COMMON.ArrayValue([convert(COMMON.AnyValue, x) for x in xs])

Base.convert(::Type{COMMON.AnyValue}, x::AbstractArray{<:Pair}) =
    COMMON.AnyValue(OneOf(:kvlist_value, convert(COMMON.KeyValueList, x)))

Base.convert(::Type{COMMON.KeyValueList}, xs::AbstractArray{<:Pair}) =
    COMMON.KeyValueList(convert(Vector{COMMON.KeyValue}, xs))

# InstrumentationScope

Base.convert(::Type{COMMON.InstrumentationScope}, ins::API.InstrumentationScope) =
    COMMON.InstrumentationScope(
        ins.name,
        string(ins.version),
        convert(Vector{COMMON.KeyValue}, ins.attributes),
        API.n_dropped(ins.attributes),
    )

# Logs

Base.convert(::Type{COLL_LOGS.ExportLogsServiceRequest}, batch::AbstractVector) =
    if !isempty(batch)
        COLL_LOGS.ExportLogsServiceRequest(
            LOGS.ResourceLogs[convert(LOGS.ResourceLogs, batch)],
        )
    end

function Base.convert(::Type{LOGS.ResourceLogs}, batch::AbstractVector)
    x = first(batch)  # we can safely assume the log records are from the same provider
    r = API.resource(x)
    LOGS.ResourceLogs(
        convert(RESOURCE.Resource, r),
        LOGS.ScopeLogs[convert(LOGS.ScopeLogs, batch)],
        r.schema_url,
    )
end

function Base.convert(::Type{LOGS.ScopeLogs}, batch::AbstractVector)
    x = first(batch)
    LOGS.ScopeLogs(
        convert(COMMON.InstrumentationScope, x.instrumentation_scope),
        [convert(LOGS.LogRecord, x) for x in batch],
        x.instrumentation_scope.schema_url,
    )
end

Base.convert(::Type{LOGS.LogRecord}, x::API.LogRecord) = LOGS.LogRecord(
    x.timestamp,
    x.observed_timestamp,
    LOGS.SeverityNumber.T(x.severity_number),
    x.severity_text,
    convert(COMMON.AnyValue, x.body),
    convert(Vector{COMMON.KeyValue}, x.attributes),
    API.n_dropped(x.attributes),
    convert(UInt32, x.trace_flags.sampled),
    uint2uint8(x.trace_id),
    uint2uint8(x.span_id),
)

# Traces

Base.convert(::Type{COLL_TRACES.ExportTraceServiceRequest}, batch::AbstractVector) =
    if !isempty(batch)
        COLL_TRACES.ExportTraceServiceRequest([convert(TRACES.ResourceSpans, batch)])
    end

function Base.convert(::Type{TRACES.ResourceSpans}, batch::AbstractVector)
    x = first(batch)
    r = API.resource(x)
    TRACES.ResourceSpans(
        convert(RESOURCE.Resource, r),
        [convert(TRACES.ScopeSpans, batch)],
        r.schema_url,
    )
end

function Base.convert(::Type{TRACES.ScopeSpans}, batch::AbstractVector)
    x = first(batch)
    t = API.tracer(x)
    TRACES.ScopeSpans(
        convert(COMMON.InstrumentationScope, t.instrumentation_scope),
        [convert(TRACES.Span, x) for x in batch],
        t.instrumentation_scope.schema_url,
    )
end

function Base.convert(::Type{TRACES.Span}, x::SDK.Span)
    ctx = API.span_context(x)
    parent_ctx = API.parent_span_context(x)
    parent_span_id = if parent_ctx === nothing
        UInt8[]
    else
        uint2uint8(parent_ctx.span_id)
    end
    attrs = API.attributes(x)
    evts = API.span_events(x)
    links = API.span_links(x)
    TRACES.Span(
        uint2uint8(ctx.trace_id),
        uint2uint8(ctx.span_id),
        string(ctx.trace_state),
        parent_span_id,
        API.span_name(x),
        convert(TRACES.var"Span.SpanKind".T, API.span_kind(x)),
        API.start_time(x),
        API.end_time(x),
        convert(Vector{COMMON.KeyValue}, attrs),
        API.n_dropped(attrs),
        [convert(TRACES.var"Span.Event", evt) for evt in evts],
        API.n_dropped(evts),
        [convert(TRACES.var"Span.Link", link) for link in links],
        API.n_dropped(links),
        convert(TRACES.Status, API.span_status(x)),
    )
end

Base.convert(::Type{TRACES.var"Span.SpanKind".T}, x::API.SpanKind) =
    TRACES.var"Span.SpanKind".T(Int(x))

Base.convert(::Type{TRACES.var"Span.Event"}, x::API.Event) = TRACES.var"Span.Event"(
    x.timestamp,
    x.name,
    convert(Vector{COMMON.KeyValue}, x.attributes),
    API.n_dropped(x.attributes),
)

function Base.convert(::Type{TRACES.var"Span.Link"}, x::API.Link)
    ctx = x.context
    TRACES.var"Span.Link"(
        uint2uint8(ctx.trace_id),
        uint2uint8(ctx.span_id),
        string(ctx.trace_state),
        convert(Vector{COMMON.KeyValue}, x.attributes),
        API.n_dropped(x.attributes),
    )
end

Base.convert(::Type{TRACES.Status}, x::API.SpanStatus) = TRACES.Status(
    something(x.description, ""),
    convert(TRACES.var"Status.StatusCode".T, x.code),
)

Base.convert(::Type{TRACES.var"Status.StatusCode".T}, x::API.SpanStatusCode) =
    TRACES.var"Status.StatusCode".T(Int(x))

# Metrics
using Base: IdSet

Base.convert(::Type{COLL_METRICS.ExportMetricsServiceRequest}, batch::IdSet) =
    if !isempty(batch)
        COLL_METRICS.ExportMetricsServiceRequest([convert(METRICS.ResourceMetrics, batch)])
    end

function Base.convert(::Type{METRICS.ResourceMetrics}, batch::IdSet)
    x = first(batch)
    r = API.resource(x)
    METRICS.ResourceMetrics(
        convert(RESOURCE.Resource, r),
        [convert(METRICS.ScopeMetrics, batch)],
        r.schema_url,
    )
end

function Base.convert(::Type{METRICS.ScopeMetrics}, batch::IdSet)
    x = first(batch)
    ins = x.instrument.meter.instrumentation_scope
    METRICS.ScopeMetrics(
        convert(COMMON.InstrumentationScope, ins),
        [convert(METRICS.Metric, x) for x in batch],
        ins.schema_url,
    )
end

const KnownOtlpMetrics = Union{
    METRICS.Gauge,
    METRICS.Sum,
    METRICS.Histogram,
    METRICS.ExponentialHistogram,
    METRICS.Summary,
}

Base.convert(::Type{METRICS.Metric}, x::SDK.Metric) = METRICS.Metric(
    x.name,
    x.description,
    x.instrument.unit,
    convert(OneOf{KnownOtlpMetrics}, x),
)

Base.convert(::Type{OneOf{KnownOtlpMetrics}}, x::SDK.Metric{<:SDK.SumAgg}) =
    OneOf(:sum, convert(METRICS.Sum, x))

Base.convert(::Type{METRICS.Sum}, x::SDK.Metric{<:SDK.SumAgg}) = METRICS.Sum(
    [convert(METRICS.NumberDataPoint, p) for p in x],
    METRICS.AggregationTemporality.AGGREGATION_TEMPORALITY_CUMULATIVE, # the only supported temporality for now
    x.aggregation.is_monotonic,
)

Base.convert(::Type{OneOf{KnownOtlpMetrics}}, x::SDK.Metric{<:SDK.LastValueAgg}) =
    OneOf(:gauge, convert(METRICS.Gauge, x))

Base.convert(::Type{METRICS.Gauge}, x::SDK.Metric{<:SDK.LastValueAgg}) =
    METRICS.Gauge([convert(METRICS.NumberDataPoint, p) for p in x])

Base.convert(::Type{OneOf{KnownOtlpMetrics}}, x::SDK.Metric{<:SDK.HistogramAgg}) =
    OneOf(:histogram, convert(METRICS.Histogram, x))

Base.convert(::Type{METRICS.Histogram}, x::SDK.Metric{<:SDK.HistogramAgg}) =
    METRICS.Histogram(
        [convert(METRICS.HistogramDataPoint, p) for p in x],
        METRICS.AggregationTemporality.AGGREGATION_TEMPORALITY_CUMULATIVE,  # the only supported temporality for now
    )

Base.convert(
    ::Type{METRICS.NumberDataPoint},
    (k, v)::Pair{<:API.BoundedAttributes,<:SDK.DataPoint{<:Union{Integer,AbstractFloat}}},
) = METRICS.NumberDataPoint(
    convert(Vector{COMMON.KeyValue}, k),
    v.start_time_unix_nano,
    v.time_unix_nano,
    if v.value isa Integer
        OneOf(:as_int, convert(Int, v.value))
    else
        OneOf(:as_double, convert(Float64, v.value))
    end,
    METRICS.Exemplar[], # TODO: add exemplars later
    UInt(METRICS.DataPointFlags.FLAG_NONE), # TODO: when to set other flags???
)

Base.convert(
    ::Type{METRICS.HistogramDataPoint},
    (k, v)::Pair{<:API.BoundedAttributes,<:SDK.DataPoint},
) = METRICS.HistogramDataPoint(
    convert(Vector{COMMON.KeyValue}, k),
    v.start_time_unix_nano,
    v.time_unix_nano,
    sum(v.value.counts),
    something(v.value.sum, 0.0),
    collect(v.value.counts),
    collect(v.value.boundaries),
    METRICS.Exemplar[], # TODO: add exemplars later
    UInt(METRICS.DataPointFlags.FLAG_NONE), # TODO: when to set other flags???
    something(v.value.min, 0),
    something(v.value.max, 0),
)