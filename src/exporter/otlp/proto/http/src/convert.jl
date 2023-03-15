Base.convert(
    ::Type{SDK.ExportResult},
    resp::Union{
        COLL_LOGS.ExportLogsServiceResponse,
        COLL_TRACES.ExportTraceServiceResponse,
        COLL_METRICS.ExportMetricsServiceResponse,
    },
) =
    if isnothing(resp.partial_success)
        SDK.EXPORT_SUCCESS
    elseif resp.partial_success.rejected_log_records == 0
        SDK.EXPORT_SUCCESS
    else
        SDK.EXPORT_FAILURE
    end

# Resource

# !!! The dropped attributes of `Resource` is always 0
# !!! The attributes of `Resource` is a `NamedTuple` instead of `BoundedAttributes`
Base.convert(::Type{RESOURCE.Resource}, r::API.Resource) =
    RESOURCE.Resource(convert(Vector{COMMON.KeyValue}, r.attributes), 0)

Base.convert(::Type{Vector{COMMON.KeyValue}}, attrs::API.BoundedAttributes) =
    [convert(COMMON.KeyValue, kv) for kv in pairs(attrs)]

Base.convert(::Type{COMMON.KeyValue}, x::Pair) =
    COMMON.KeyValue(string(first(x)), convert(COMMON.AnyValue, last(x)))

Base.convert(::Type{COMMON.AnyValue}, x::String) = COMMON.AnyValue(OneOf(:string_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::Bool) = COMMON.AnyValue(OneOf(:bool_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::Int) = COMMON.AnyValue(OneOf(:int_value, x))
Base.convert(::Type{COMMON.AnyValue}, x::Float64) = COMMON.AnyValue(OneOf(:double_value, x))
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
    COLL_LOGS.ExportLogsServiceRequest(LOGS.ResourceLogs[convert(LOGS.ResourceLogs, batch)])

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
    reinterpret(UInt8, [x.trace_id]),
    reinterpret(UInt8, [x.span_id]),
)

# Traces

Base.convert(::Type{COLL_TRACES.ExportTraceServiceRequest}, batch::AbstractVector) =
    COLL_TRACES.ExportTraceServiceRequest([convert(TRACES.ResourceSpans, batch)])

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
    attrs = API.attributes(x)
    evts = API.span_events(x)
    links = API.span_links(x)
    TRACES.Span(
        reinterpret(UInt8, [ctx.trace_id]),
        reinterpret(UInt8, [ctx.span_id]),
        string(ctx.trace_state),
        reinterpret(UInt8, [parent_ctx.span_id]),
        API.span_name(x),
        convert(TRACES.var"Span.SpanKind", API.span_kind(x)),
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

Base.convert(::Type{TRACES.var"Span.SpanKind"}, x::API.SpanKind) =
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
        reinterpret(UInt8, [ctx.trace_id]),
        reinterpret(UInt8, [ctx.span_id]),
        string(ctx.trace_state),
        convert(Vector{COMMON.KeyValue}, x.attributes),
        API.n_dropped(x.attributes),
    )
end

Base.convert(::Type{TRACES.Status}, x::API.SpanStatus) = TRACES.Status(
    something(x.description, ""),
    convert(TRACES.var"Status.StatusCode", x.code),
)

Base.convert(::Type{TRACES.var"Status.StatusCode"}, x::API.SpanStatusCode) =
    TRACES.var"Status.StatusCode".T(Int(x))
