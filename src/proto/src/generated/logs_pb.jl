# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

const SeverityNumber = (;
    [
        Symbol("SEVERITY_NUMBER_UNSPECIFIED") => Int32(0),
        Symbol("SEVERITY_NUMBER_TRACE") => Int32(1),
        Symbol("SEVERITY_NUMBER_TRACE2") => Int32(2),
        Symbol("SEVERITY_NUMBER_TRACE3") => Int32(3),
        Symbol("SEVERITY_NUMBER_TRACE4") => Int32(4),
        Symbol("SEVERITY_NUMBER_DEBUG") => Int32(5),
        Symbol("SEVERITY_NUMBER_DEBUG2") => Int32(6),
        Symbol("SEVERITY_NUMBER_DEBUG3") => Int32(7),
        Symbol("SEVERITY_NUMBER_DEBUG4") => Int32(8),
        Symbol("SEVERITY_NUMBER_INFO") => Int32(9),
        Symbol("SEVERITY_NUMBER_INFO2") => Int32(10),
        Symbol("SEVERITY_NUMBER_INFO3") => Int32(11),
        Symbol("SEVERITY_NUMBER_INFO4") => Int32(12),
        Symbol("SEVERITY_NUMBER_WARN") => Int32(13),
        Symbol("SEVERITY_NUMBER_WARN2") => Int32(14),
        Symbol("SEVERITY_NUMBER_WARN3") => Int32(15),
        Symbol("SEVERITY_NUMBER_WARN4") => Int32(16),
        Symbol("SEVERITY_NUMBER_ERROR") => Int32(17),
        Symbol("SEVERITY_NUMBER_ERROR2") => Int32(18),
        Symbol("SEVERITY_NUMBER_ERROR3") => Int32(19),
        Symbol("SEVERITY_NUMBER_ERROR4") => Int32(20),
        Symbol("SEVERITY_NUMBER_FATAL") => Int32(21),
        Symbol("SEVERITY_NUMBER_FATAL2") => Int32(22),
        Symbol("SEVERITY_NUMBER_FATAL3") => Int32(23),
        Symbol("SEVERITY_NUMBER_FATAL4") => Int32(24),
    ]...
)

const LogRecordFlags = (;
    [
        Symbol("LOG_RECORD_FLAG_UNSPECIFIED") => Int32(0),
        Symbol("LOG_RECORD_FLAG_TRACE_FLAGS_MASK") => Int32(255),
    ]...
)

mutable struct LogRecord <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function LogRecord(; kwargs...)
        obj = new(meta(LogRecord), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) ||
                error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct LogRecord
const __meta_LogRecord = Ref{ProtoMeta}()
function meta(::Type{LogRecord})
    ProtoBuf.metalock() do
        if !isassigned(__meta_LogRecord)
            __meta_LogRecord[] = target = ProtoMeta(LogRecord)
            fnum = Int[1, 11, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            wtype = Dict(
                :time_unix_nano => :fixed64,
                :observed_time_unix_nano => :fixed64,
                :flags => :fixed32,
            )
            allflds = Pair{Symbol,Union{Type,String}}[
                :time_unix_nano=>UInt64,
                :observed_time_unix_nano=>UInt64,
                :severity_number=>Int32,
                :severity_text=>AbstractString,
                :name=>AbstractString,
                :body=>opentelemetry.proto.common.v1.AnyValue,
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :dropped_attributes_count=>UInt32,
                :flags=>UInt32,
                :trace_id=>Vector{UInt8},
                :span_id=>Vector{UInt8},
            ]
            meta(
                target,
                LogRecord,
                allflds,
                ProtoBuf.DEF_REQ,
                fnum,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                wtype,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_LogRecord[]
    end
end
function Base.getproperty(obj::LogRecord, name::Symbol)
    if name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :observed_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :severity_number
        return (obj.__protobuf_jl_internal_values[name])::Int32
    elseif name === :severity_text
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :name
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :body
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.common.v1.AnyValue
    elseif name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :dropped_attributes_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    elseif name === :flags
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    elseif name === :trace_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :span_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    else
        getfield(obj, name)
    end
end

mutable struct InstrumentationLibraryLogs <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function InstrumentationLibraryLogs(; kwargs...)
        obj = new(meta(InstrumentationLibraryLogs), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) ||
                error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct InstrumentationLibraryLogs
const __meta_InstrumentationLibraryLogs = Ref{ProtoMeta}()
function meta(::Type{InstrumentationLibraryLogs})
    ProtoBuf.metalock() do
        if !isassigned(__meta_InstrumentationLibraryLogs)
            __meta_InstrumentationLibraryLogs[] =
                target = ProtoMeta(InstrumentationLibraryLogs)
            allflds = Pair{Symbol,Union{Type,String}}[
                :instrumentation_library=>opentelemetry.proto.common.v1.InstrumentationLibrary,
                :log_records=>Base.Vector{LogRecord},
                :schema_url=>AbstractString,
            ]
            meta(
                target,
                InstrumentationLibraryLogs,
                allflds,
                ProtoBuf.DEF_REQ,
                ProtoBuf.DEF_FNUM,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                ProtoBuf.DEF_WTYPES,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_InstrumentationLibraryLogs[]
    end
end
function Base.getproperty(obj::InstrumentationLibraryLogs, name::Symbol)
    if name === :instrumentation_library
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.common.v1.InstrumentationLibrary
    elseif name === :log_records
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{LogRecord}
    elseif name === :schema_url
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct ResourceLogs <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ResourceLogs(; kwargs...)
        obj = new(meta(ResourceLogs), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) ||
                error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct ResourceLogs
const __meta_ResourceLogs = Ref{ProtoMeta}()
function meta(::Type{ResourceLogs})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ResourceLogs)
            __meta_ResourceLogs[] = target = ProtoMeta(ResourceLogs)
            allflds = Pair{Symbol,Union{Type,String}}[
                :resource=>opentelemetry.proto.resource.v1.Resource,
                :instrumentation_library_logs=>Base.Vector{InstrumentationLibraryLogs},
                :schema_url=>AbstractString,
            ]
            meta(
                target,
                ResourceLogs,
                allflds,
                ProtoBuf.DEF_REQ,
                ProtoBuf.DEF_FNUM,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                ProtoBuf.DEF_WTYPES,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_ResourceLogs[]
    end
end
function Base.getproperty(obj::ResourceLogs, name::Symbol)
    if name === :resource
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.resource.v1.Resource
    elseif name === :instrumentation_library_logs
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            InstrumentationLibraryLogs,
        }
    elseif name === :schema_url
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct LogsData <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function LogsData(; kwargs...)
        obj = new(meta(LogsData), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) ||
                error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct LogsData
const __meta_LogsData = Ref{ProtoMeta}()
function meta(::Type{LogsData})
    ProtoBuf.metalock() do
        if !isassigned(__meta_LogsData)
            __meta_LogsData[] = target = ProtoMeta(LogsData)
            allflds =
                Pair{Symbol,Union{Type,String}}[:resource_logs=>Base.Vector{ResourceLogs}]
            meta(
                target,
                LogsData,
                allflds,
                ProtoBuf.DEF_REQ,
                ProtoBuf.DEF_FNUM,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                ProtoBuf.DEF_WTYPES,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_LogsData[]
    end
end
function Base.getproperty(obj::LogsData, name::Symbol)
    if name === :resource_logs
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{ResourceLogs}
    else
        getfield(obj, name)
    end
end

export SeverityNumber,
    LogRecordFlags, LogsData, ResourceLogs, InstrumentationLibraryLogs, LogRecord
