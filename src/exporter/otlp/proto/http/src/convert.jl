Base.convert(
    ::Type{SDK.ExportResult},
    resp::Union{
        COLL_LOGS.ExportLogsServiceResponse,
        COLL_TRACES.ExportTracesServiceResponse,
        COLL_METRICS.ExportMetricsServiceResponse,
    },
) = isnothing(resp.partial_success) ? SDK.EXPORT_SUCCESS : SDK.EXPORT_FAILURE

# Resource

# !!! The dropped attributes of `Resource` is always 0
# !!! The attributes of `Resource` is a `NamedTuple` instead of `BoundedAttributes`
Base.convert(::Type{RESOURCE.Resource}, r::API.Resource) =
    RESOURCE.Resource(convert(Vector{COMMON.KeyValue}, r.attributes), 0)

Base.convert(::Type{Vector{COMMON.KeyValue}}, attrs) =
    map(x -> convert(COMMON.KeyValue, x), pairs(attrs))

Base.convert(::Type{COMMON.KeyValue}, x::Pair) =
    COMMON.KeyValue(string(first(x)), convert(COMMON.AnyValue, last(x)))

Base.convert(::Type{COMMON.AnyValue}, x::Union{String,Bool,Int64,Float64}) =
    COMMON.AnyValue(x)

Base.convert(
    ::Type{COMMON.AnyValue},
    x::AbstractArray{<:Union{String,Bool,Int64,Float64}},
) = COMMON.AnyValue(convert(COMMON.ArrayValue, x))

Base.convert(
    ::Type{COMMON.ArrayValue},
    x::AbstractArray{<:Union{String,Bool,Int64,Float64}},
) = COMMON.ArrayValue(x)

Base.convert(::Type{COMMON.AnyValue}, x::AbstractArray{<:Pair}) =
    COMMON.AnyValue(convert(COMMON.KeyValueList, x))

Base.convert(::Type{COMMON.KeyValueList}, x::AbstractArray{<:Pair}) =
    COMMON.KeyValueList(map(x -> convert(COMMON.KeyValue, x), x))

# InstrumentationScope

Base.convert(::Type{COMMON.InstrumentationScope}, ins::API.InstrumentationScope) =
    COMMON.InstrumentationScope(
        ins.name,
        string(ins.version),
        convert(Vector{COMMON.KeyValue}, ins.attributes),
        API.n_dropped(ins.attributes),
    )

# Logs

Base.convert(
    ::Type{COLL_LOGS.ExportLogsServiceRequest},
    batch::AbstractVector{API.LogRecord},
) = COLL_LOGS.ExportLogsServiceRequest(LOGS.ResourceLogs[convert(LOGS.ResourceLogs, batch)])

function Base.convert(::Type{LOGS.ResourceLogs}, batch)
    x = first(batch)  # we can safely assume the log records are from the same provider
    LOGS.ResourceLogs(
        convert(RESOURCE.Resource, x.resource),
        LOGS.ScopeLogs[convert(LOGS.ScopeLogs, batch)],
        x.instrumentation_scope.schema_url,
    )
end

function Base.convert(::Type{LOGS.ScopeLogs}, batch)
    x = first(batch)
    LOGS.ScopeLogs(
        convert(COMMON.InstrumentationScope, x.instrumentation_scope),
        map(x -> convert(LOGS.LogRecord, x), batch),
        x.instrumentation_scope.schema_url,
    )
end

Base.convert(::Type{LOGS.LogRecord}, x::API.LogRecord) = LOGS.LogRecord(
    x.timestamp,
    x.observed_timestamp,
    COMMON.SeverityNumber.T(x.severity_number),
    x.severity_text,
    convert(COMMON.AnyValue, x.body),
    convert(Vector{COMMON.KeyValue}, x.attributes),
    API.n_dropped(x.attributes),
    convert(UInt32, x.trace_flags.sampled),
    reinterpret(UInt8, [x.trace_id]),
    reinterpret(UInt8, [x.span_id]),
)