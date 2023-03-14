Base.convert(
    ::Type{SDK.ExportResult},
    resp::Union{
        COLL_LOGS.ExportLogsServiceResponse,
        COLL_TRACES.ExportTraceServiceResponse,
        COLL_METRICS.ExportMetricsServiceResponse,
    },
) = if isnothing(resp.partial_success)
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

Base.convert(
    ::Type{Vector{COMMON.KeyValue}},
    attrs::Union{NamedTuple,API.BoundedAttributes},
) = [convert(COMMON.KeyValue, kv) for kv in pairs(attrs)]

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
    LOGS.ResourceLogs(
        convert(RESOURCE.Resource, x.resource),
        LOGS.ScopeLogs[convert(LOGS.ScopeLogs, batch)],
        x.instrumentation_scope.schema_url,
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