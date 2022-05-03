# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

const AggregationTemporality = (;
    [
        Symbol("AGGREGATION_TEMPORALITY_UNSPECIFIED") => Int32(0),
        Symbol("AGGREGATION_TEMPORALITY_DELTA") => Int32(1),
        Symbol("AGGREGATION_TEMPORALITY_CUMULATIVE") => Int32(2),
    ]...
)

const DataPointFlags =
    (; [Symbol("FLAG_NONE") => Int32(0), Symbol("FLAG_NO_RECORDED_VALUE") => Int32(1)]...)

mutable struct SummaryDataPoint_ValueAtQuantile <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function SummaryDataPoint_ValueAtQuantile(; kwargs...)
        obj = new(meta(SummaryDataPoint_ValueAtQuantile), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct SummaryDataPoint_ValueAtQuantile
const __meta_SummaryDataPoint_ValueAtQuantile = Ref{ProtoMeta}()
function meta(::Type{SummaryDataPoint_ValueAtQuantile})
    ProtoBuf.metalock() do
        if !isassigned(__meta_SummaryDataPoint_ValueAtQuantile)
            __meta_SummaryDataPoint_ValueAtQuantile[] =
                target = ProtoMeta(SummaryDataPoint_ValueAtQuantile)
            allflds = Pair{Symbol,Union{Type,String}}[:quantile=>Float64, :value=>Float64]
            meta(
                target,
                SummaryDataPoint_ValueAtQuantile,
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
        __meta_SummaryDataPoint_ValueAtQuantile[]
    end
end
function Base.getproperty(obj::SummaryDataPoint_ValueAtQuantile, name::Symbol)
    if name === :quantile
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :value
        return (obj.__protobuf_jl_internal_values[name])::Float64
    else
        getfield(obj, name)
    end
end

mutable struct SummaryDataPoint <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function SummaryDataPoint(; kwargs...)
        obj = new(meta(SummaryDataPoint), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct SummaryDataPoint
const __meta_SummaryDataPoint = Ref{ProtoMeta}()
function meta(::Type{SummaryDataPoint})
    ProtoBuf.metalock() do
        if !isassigned(__meta_SummaryDataPoint)
            __meta_SummaryDataPoint[] = target = ProtoMeta(SummaryDataPoint)
            fnum = Int[7, 2, 3, 4, 5, 6, 8]
            wtype = Dict(
                :start_time_unix_nano => :fixed64,
                :time_unix_nano => :fixed64,
                :count => :fixed64,
            )
            allflds = Pair{Symbol,Union{Type,String}}[
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :start_time_unix_nano=>UInt64,
                :time_unix_nano=>UInt64,
                :count=>UInt64,
                :sum=>Float64,
                :quantile_values=>Base.Vector{SummaryDataPoint_ValueAtQuantile},
                :flags=>UInt32,
            ]
            meta(
                target,
                SummaryDataPoint,
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
        __meta_SummaryDataPoint[]
    end
end
function Base.getproperty(obj::SummaryDataPoint, name::Symbol)
    if name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :start_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :count
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :sum
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :quantile_values
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            SummaryDataPoint_ValueAtQuantile,
        }
    elseif name === :flags
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    else
        getfield(obj, name)
    end
end

mutable struct Summary <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Summary(; kwargs...)
        obj = new(meta(Summary), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Summary
const __meta_Summary = Ref{ProtoMeta}()
function meta(::Type{Summary})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Summary)
            __meta_Summary[] = target = ProtoMeta(Summary)
            allflds =
                Pair{Symbol,Union{Type,String}}[:data_points=>Base.Vector{SummaryDataPoint}]
            meta(
                target,
                Summary,
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
        __meta_Summary[]
    end
end
function Base.getproperty(obj::Summary, name::Symbol)
    if name === :data_points
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{SummaryDataPoint}
    else
        getfield(obj, name)
    end
end

mutable struct Exemplar <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Exemplar(; kwargs...)
        obj = new(meta(Exemplar), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Exemplar
const __meta_Exemplar = Ref{ProtoMeta}()
function meta(::Type{Exemplar})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Exemplar)
            __meta_Exemplar[] = target = ProtoMeta(Exemplar)
            fnum = Int[7, 2, 3, 6, 4, 5]
            wtype = Dict(:time_unix_nano => :fixed64, :as_int => :sfixed64)
            allflds = Pair{Symbol,Union{Type,String}}[
                :filtered_attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :time_unix_nano=>UInt64,
                :as_double=>Float64,
                :as_int=>Int64,
                :span_id=>Vector{UInt8},
                :trace_id=>Vector{UInt8},
            ]
            oneofs = Int[0, 0, 1, 1, 0, 0]
            oneof_names = Symbol[Symbol("value")]
            meta(
                target,
                Exemplar,
                allflds,
                ProtoBuf.DEF_REQ,
                fnum,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                wtype,
                oneofs,
                oneof_names,
            )
        end
        __meta_Exemplar[]
    end
end
function Base.getproperty(obj::Exemplar, name::Symbol)
    if name === :filtered_attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :as_double
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :as_int
        return (obj.__protobuf_jl_internal_values[name])::Int64
    elseif name === :span_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :trace_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    else
        getfield(obj, name)
    end
end

mutable struct NumberDataPoint <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function NumberDataPoint(; kwargs...)
        obj = new(meta(NumberDataPoint), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct NumberDataPoint
const __meta_NumberDataPoint = Ref{ProtoMeta}()
function meta(::Type{NumberDataPoint})
    ProtoBuf.metalock() do
        if !isassigned(__meta_NumberDataPoint)
            __meta_NumberDataPoint[] = target = ProtoMeta(NumberDataPoint)
            fnum = Int[7, 2, 3, 4, 6, 5, 8]
            wtype = Dict(
                :start_time_unix_nano => :fixed64,
                :time_unix_nano => :fixed64,
                :as_int => :sfixed64,
            )
            allflds = Pair{Symbol,Union{Type,String}}[
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :start_time_unix_nano=>UInt64,
                :time_unix_nano=>UInt64,
                :as_double=>Float64,
                :as_int=>Int64,
                :exemplars=>Base.Vector{Exemplar},
                :flags=>UInt32,
            ]
            oneofs = Int[0, 0, 0, 1, 1, 0, 0]
            oneof_names = Symbol[Symbol("value")]
            meta(
                target,
                NumberDataPoint,
                allflds,
                ProtoBuf.DEF_REQ,
                fnum,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                wtype,
                oneofs,
                oneof_names,
            )
        end
        __meta_NumberDataPoint[]
    end
end
function Base.getproperty(obj::NumberDataPoint, name::Symbol)
    if name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :start_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :as_double
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :as_int
        return (obj.__protobuf_jl_internal_values[name])::Int64
    elseif name === :exemplars
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Exemplar}
    elseif name === :flags
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    else
        getfield(obj, name)
    end
end

mutable struct ExponentialHistogramDataPoint_Buckets <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExponentialHistogramDataPoint_Buckets(; kwargs...)
        obj = new(
            meta(ExponentialHistogramDataPoint_Buckets),
            Dict{Symbol,Any}(),
            Set{Symbol}(),
        )
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
end # mutable struct ExponentialHistogramDataPoint_Buckets
const __meta_ExponentialHistogramDataPoint_Buckets = Ref{ProtoMeta}()
function meta(::Type{ExponentialHistogramDataPoint_Buckets})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExponentialHistogramDataPoint_Buckets)
            __meta_ExponentialHistogramDataPoint_Buckets[] =
                target = ProtoMeta(ExponentialHistogramDataPoint_Buckets)
            pack = Symbol[:bucket_counts]
            wtype = Dict(:offset => :sint32)
            allflds = Pair{Symbol,Union{Type,String}}[
                :offset=>Int32,
                :bucket_counts=>Base.Vector{UInt64},
            ]
            meta(
                target,
                ExponentialHistogramDataPoint_Buckets,
                allflds,
                ProtoBuf.DEF_REQ,
                ProtoBuf.DEF_FNUM,
                ProtoBuf.DEF_VAL,
                pack,
                wtype,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_ExponentialHistogramDataPoint_Buckets[]
    end
end
function Base.getproperty(obj::ExponentialHistogramDataPoint_Buckets, name::Symbol)
    if name === :offset
        return (obj.__protobuf_jl_internal_values[name])::Int32
    elseif name === :bucket_counts
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{UInt64}
    else
        getfield(obj, name)
    end
end

mutable struct ExponentialHistogramDataPoint <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExponentialHistogramDataPoint(; kwargs...)
        obj = new(meta(ExponentialHistogramDataPoint), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExponentialHistogramDataPoint
const __meta_ExponentialHistogramDataPoint = Ref{ProtoMeta}()
function meta(::Type{ExponentialHistogramDataPoint})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExponentialHistogramDataPoint)
            __meta_ExponentialHistogramDataPoint[] =
                target = ProtoMeta(ExponentialHistogramDataPoint)
            wtype = Dict(
                :start_time_unix_nano => :fixed64,
                :time_unix_nano => :fixed64,
                :count => :fixed64,
                :scale => :sint32,
                :zero_count => :fixed64,
            )
            allflds = Pair{Symbol,Union{Type,String}}[
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :start_time_unix_nano=>UInt64,
                :time_unix_nano=>UInt64,
                :count=>UInt64,
                :sum=>Float64,
                :scale=>Int32,
                :zero_count=>UInt64,
                :positive=>ExponentialHistogramDataPoint_Buckets,
                :negative=>ExponentialHistogramDataPoint_Buckets,
                :flags=>UInt32,
                :exemplars=>Base.Vector{Exemplar},
            ]
            meta(
                target,
                ExponentialHistogramDataPoint,
                allflds,
                ProtoBuf.DEF_REQ,
                ProtoBuf.DEF_FNUM,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                wtype,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_ExponentialHistogramDataPoint[]
    end
end
function Base.getproperty(obj::ExponentialHistogramDataPoint, name::Symbol)
    if name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :start_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :count
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :sum
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :scale
        return (obj.__protobuf_jl_internal_values[name])::Int32
    elseif name === :zero_count
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :positive
        return (obj.__protobuf_jl_internal_values[name])::ExponentialHistogramDataPoint_Buckets
    elseif name === :negative
        return (obj.__protobuf_jl_internal_values[name])::ExponentialHistogramDataPoint_Buckets
    elseif name === :flags
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    elseif name === :exemplars
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Exemplar}
    else
        getfield(obj, name)
    end
end

mutable struct HistogramDataPoint <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function HistogramDataPoint(; kwargs...)
        obj = new(meta(HistogramDataPoint), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct HistogramDataPoint
const __meta_HistogramDataPoint = Ref{ProtoMeta}()
function meta(::Type{HistogramDataPoint})
    ProtoBuf.metalock() do
        if !isassigned(__meta_HistogramDataPoint)
            __meta_HistogramDataPoint[] = target = ProtoMeta(HistogramDataPoint)
            fnum = Int[9, 2, 3, 4, 5, 6, 7, 8, 10]
            pack = Symbol[:bucket_counts, :explicit_bounds]
            wtype = Dict(
                :start_time_unix_nano => :fixed64,
                :time_unix_nano => :fixed64,
                :count => :fixed64,
                :bucket_counts => :fixed64,
            )
            allflds = Pair{Symbol,Union{Type,String}}[
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :start_time_unix_nano=>UInt64,
                :time_unix_nano=>UInt64,
                :count=>UInt64,
                :sum=>Float64,
                :bucket_counts=>Base.Vector{UInt64},
                :explicit_bounds=>Base.Vector{Float64},
                :exemplars=>Base.Vector{Exemplar},
                :flags=>UInt32,
            ]
            meta(
                target,
                HistogramDataPoint,
                allflds,
                ProtoBuf.DEF_REQ,
                fnum,
                ProtoBuf.DEF_VAL,
                pack,
                wtype,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_HistogramDataPoint[]
    end
end
function Base.getproperty(obj::HistogramDataPoint, name::Symbol)
    if name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :start_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :count
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :sum
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :bucket_counts
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{UInt64}
    elseif name === :explicit_bounds
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Float64}
    elseif name === :exemplars
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Exemplar}
    elseif name === :flags
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    else
        getfield(obj, name)
    end
end

mutable struct Sum <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Sum(; kwargs...)
        obj = new(meta(Sum), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Sum
const __meta_Sum = Ref{ProtoMeta}()
function meta(::Type{Sum})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Sum)
            __meta_Sum[] = target = ProtoMeta(Sum)
            allflds = Pair{Symbol,Union{Type,String}}[
                :data_points=>Base.Vector{NumberDataPoint},
                :aggregation_temporality=>Int32,
                :is_monotonic=>Bool,
            ]
            meta(
                target,
                Sum,
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
        __meta_Sum[]
    end
end
function Base.getproperty(obj::Sum, name::Symbol)
    if name === :data_points
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{NumberDataPoint}
    elseif name === :aggregation_temporality
        return (obj.__protobuf_jl_internal_values[name])::Int32
    elseif name === :is_monotonic
        return (obj.__protobuf_jl_internal_values[name])::Bool
    else
        getfield(obj, name)
    end
end

mutable struct Gauge <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Gauge(; kwargs...)
        obj = new(meta(Gauge), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Gauge
const __meta_Gauge = Ref{ProtoMeta}()
function meta(::Type{Gauge})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Gauge)
            __meta_Gauge[] = target = ProtoMeta(Gauge)
            allflds =
                Pair{Symbol,Union{Type,String}}[:data_points=>Base.Vector{NumberDataPoint}]
            meta(
                target,
                Gauge,
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
        __meta_Gauge[]
    end
end
function Base.getproperty(obj::Gauge, name::Symbol)
    if name === :data_points
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{NumberDataPoint}
    else
        getfield(obj, name)
    end
end

mutable struct ExponentialHistogram <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExponentialHistogram(; kwargs...)
        obj = new(meta(ExponentialHistogram), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExponentialHistogram
const __meta_ExponentialHistogram = Ref{ProtoMeta}()
function meta(::Type{ExponentialHistogram})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExponentialHistogram)
            __meta_ExponentialHistogram[] = target = ProtoMeta(ExponentialHistogram)
            allflds = Pair{Symbol,Union{Type,String}}[
                :data_points=>Base.Vector{ExponentialHistogramDataPoint},
                :aggregation_temporality=>Int32,
            ]
            meta(
                target,
                ExponentialHistogram,
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
        __meta_ExponentialHistogram[]
    end
end
function Base.getproperty(obj::ExponentialHistogram, name::Symbol)
    if name === :data_points
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            ExponentialHistogramDataPoint,
        }
    elseif name === :aggregation_temporality
        return (obj.__protobuf_jl_internal_values[name])::Int32
    else
        getfield(obj, name)
    end
end

mutable struct Histogram <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Histogram(; kwargs...)
        obj = new(meta(Histogram), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Histogram
const __meta_Histogram = Ref{ProtoMeta}()
function meta(::Type{Histogram})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Histogram)
            __meta_Histogram[] = target = ProtoMeta(Histogram)
            allflds = Pair{Symbol,Union{Type,String}}[
                :data_points=>Base.Vector{HistogramDataPoint},
                :aggregation_temporality=>Int32,
            ]
            meta(
                target,
                Histogram,
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
        __meta_Histogram[]
    end
end
function Base.getproperty(obj::Histogram, name::Symbol)
    if name === :data_points
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{HistogramDataPoint}
    elseif name === :aggregation_temporality
        return (obj.__protobuf_jl_internal_values[name])::Int32
    else
        getfield(obj, name)
    end
end

mutable struct Metric <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Metric(; kwargs...)
        obj = new(meta(Metric), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Metric
const __meta_Metric = Ref{ProtoMeta}()
function meta(::Type{Metric})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Metric)
            __meta_Metric[] = target = ProtoMeta(Metric)
            fnum = Int[1, 2, 3, 5, 7, 9, 10, 11]
            allflds = Pair{Symbol,Union{Type,String}}[
                :name=>AbstractString,
                :description=>AbstractString,
                :unit=>AbstractString,
                :gauge=>Gauge,
                :sum=>Sum,
                :histogram=>Histogram,
                :exponential_histogram=>ExponentialHistogram,
                :summary=>Summary,
            ]
            oneofs = Int[0, 0, 0, 1, 1, 1, 1, 1]
            oneof_names = Symbol[Symbol("data")]
            meta(
                target,
                Metric,
                allflds,
                ProtoBuf.DEF_REQ,
                fnum,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                ProtoBuf.DEF_WTYPES,
                oneofs,
                oneof_names,
            )
        end
        __meta_Metric[]
    end
end
function Base.getproperty(obj::Metric, name::Symbol)
    if name === :name
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :description
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :unit
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :gauge
        return (obj.__protobuf_jl_internal_values[name])::Gauge
    elseif name === :sum
        return (obj.__protobuf_jl_internal_values[name])::Sum
    elseif name === :histogram
        return (obj.__protobuf_jl_internal_values[name])::Histogram
    elseif name === :exponential_histogram
        return (obj.__protobuf_jl_internal_values[name])::ExponentialHistogram
    elseif name === :summary
        return (obj.__protobuf_jl_internal_values[name])::Summary
    else
        getfield(obj, name)
    end
end

mutable struct InstrumentationLibraryMetrics <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function InstrumentationLibraryMetrics(; kwargs...)
        obj = new(meta(InstrumentationLibraryMetrics), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct InstrumentationLibraryMetrics
const __meta_InstrumentationLibraryMetrics = Ref{ProtoMeta}()
function meta(::Type{InstrumentationLibraryMetrics})
    ProtoBuf.metalock() do
        if !isassigned(__meta_InstrumentationLibraryMetrics)
            __meta_InstrumentationLibraryMetrics[] =
                target = ProtoMeta(InstrumentationLibraryMetrics)
            allflds = Pair{Symbol,Union{Type,String}}[
                :instrumentation_library=>opentelemetry.proto.common.v1.InstrumentationLibrary,
                :metrics=>Base.Vector{Metric},
                :schema_url=>AbstractString,
            ]
            meta(
                target,
                InstrumentationLibraryMetrics,
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
        __meta_InstrumentationLibraryMetrics[]
    end
end
function Base.getproperty(obj::InstrumentationLibraryMetrics, name::Symbol)
    if name === :instrumentation_library
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.common.v1.InstrumentationLibrary
    elseif name === :metrics
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Metric}
    elseif name === :schema_url
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct ResourceMetrics <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ResourceMetrics(; kwargs...)
        obj = new(meta(ResourceMetrics), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ResourceMetrics
const __meta_ResourceMetrics = Ref{ProtoMeta}()
function meta(::Type{ResourceMetrics})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ResourceMetrics)
            __meta_ResourceMetrics[] = target = ProtoMeta(ResourceMetrics)
            allflds = Pair{Symbol,Union{Type,String}}[
                :resource=>opentelemetry.proto.resource.v1.Resource,
                :instrumentation_library_metrics=>Base.Vector{
                    InstrumentationLibraryMetrics,
                },
                :schema_url=>AbstractString,
            ]
            meta(
                target,
                ResourceMetrics,
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
        __meta_ResourceMetrics[]
    end
end
function Base.getproperty(obj::ResourceMetrics, name::Symbol)
    if name === :resource
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.resource.v1.Resource
    elseif name === :instrumentation_library_metrics
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            InstrumentationLibraryMetrics,
        }
    elseif name === :schema_url
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct MetricsData <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function MetricsData(; kwargs...)
        obj = new(meta(MetricsData), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct MetricsData
const __meta_MetricsData = Ref{ProtoMeta}()
function meta(::Type{MetricsData})
    ProtoBuf.metalock() do
        if !isassigned(__meta_MetricsData)
            __meta_MetricsData[] = target = ProtoMeta(MetricsData)
            allflds = Pair{Symbol,Union{Type,String}}[:resource_metrics=>Base.Vector{
                ResourceMetrics,
            }]
            meta(
                target,
                MetricsData,
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
        __meta_MetricsData[]
    end
end
function Base.getproperty(obj::MetricsData, name::Symbol)
    if name === :resource_metrics
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{ResourceMetrics}
    else
        getfield(obj, name)
    end
end

export AggregationTemporality,
    DataPointFlags,
    MetricsData,
    ResourceMetrics,
    InstrumentationLibraryMetrics,
    Metric,
    Gauge,
    Sum,
    Histogram,
    ExponentialHistogram,
    Summary,
    NumberDataPoint,
    HistogramDataPoint,
    ExponentialHistogramDataPoint_Buckets,
    ExponentialHistogramDataPoint,
    SummaryDataPoint_ValueAtQuantile,
    SummaryDataPoint,
    Exemplar
