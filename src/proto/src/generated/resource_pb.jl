# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

mutable struct Resource <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Resource(; kwargs...)
        obj = new(meta(Resource), Dict{Symbol,Any}(), Set{Symbol}())
        values = obj.__protobuf_jl_internal_values
        symdict = obj.__protobuf_jl_internal_meta.symdict
        for nv in kwargs
            fldname, fldval = nv
            fldtype = symdict[fldname].jtyp
            (fldname in keys(symdict)) || error(string(typeof(obj), " has no field with name ", fldname))
            if fldval !== nothing
                values[fldname] = isa(fldval, fldtype) ? fldval : convert(fldtype, fldval)
            end
        end
        obj
    end
end # mutable struct Resource
const __meta_Resource = Ref{ProtoMeta}()
function meta(::Type{Resource})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Resource)
            __meta_Resource[] = target = ProtoMeta(Resource)
            allflds = Pair{Symbol,Union{Type,String}}[:attributes => Base.Vector{opentelemetry.proto.common.v1.KeyValue}, :dropped_attributes_count => UInt32]
            meta(target, Resource, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_Resource[]
    end
end
function Base.getproperty(obj::Resource, name::Symbol)
    if name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{opentelemetry.proto.common.v1.KeyValue}
    elseif name === :dropped_attributes_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    else
        getfield(obj, name)
    end
end

export Resource
