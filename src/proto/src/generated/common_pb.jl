# syntax: proto3
using ProtoBuf
import ProtoBuf.meta

mutable struct InstrumentationLibrary <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function InstrumentationLibrary(; kwargs...)
        obj = new(meta(InstrumentationLibrary), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct InstrumentationLibrary
const __meta_InstrumentationLibrary = Ref{ProtoMeta}()
function meta(::Type{InstrumentationLibrary})
    ProtoBuf.metalock() do
        if !isassigned(__meta_InstrumentationLibrary)
            __meta_InstrumentationLibrary[] = target = ProtoMeta(InstrumentationLibrary)
            allflds = Pair{Symbol,Union{Type,String}}[:name => AbstractString, :version => AbstractString]
            meta(target, InstrumentationLibrary, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_InstrumentationLibrary[]
    end
end
function Base.getproperty(obj::InstrumentationLibrary, name::Symbol)
    if name === :name
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :version
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct AnyValue <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function AnyValue(; kwargs...)
        obj = new(meta(AnyValue), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct AnyValue (has cyclic type dependency)
const __meta_AnyValue = Ref{ProtoMeta}()
function meta(::Type{AnyValue})
    ProtoBuf.metalock() do
        if !isassigned(__meta_AnyValue)
            __meta_AnyValue[] = target = ProtoMeta(AnyValue)
            allflds = Pair{Symbol,Union{Type,String}}[:string_value => AbstractString, :bool_value => Bool, :int_value => Int64, :double_value => Float64, :array_value => "ArrayValue", :kvlist_value => "KeyValueList", :bytes_value => Vector{UInt8}]
            oneofs = Int[1,1,1,1,1,1,1]
            oneof_names = Symbol[Symbol("value")]
            meta(target, AnyValue, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, oneofs, oneof_names)
        end
        __meta_AnyValue[]
    end
end
function Base.getproperty(obj::AnyValue, name::Symbol)
    if name === :string_value
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :bool_value
        return (obj.__protobuf_jl_internal_values[name])::Bool
    elseif name === :int_value
        return (obj.__protobuf_jl_internal_values[name])::Int64
    elseif name === :double_value
        return (obj.__protobuf_jl_internal_values[name])::Float64
    elseif name === :array_value
        return (obj.__protobuf_jl_internal_values[name])::Any
    elseif name === :kvlist_value
        return (obj.__protobuf_jl_internal_values[name])::Any
    elseif name === :bytes_value
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    else
        getfield(obj, name)
    end
end

mutable struct ArrayValue <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ArrayValue(; kwargs...)
        obj = new(meta(ArrayValue), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ArrayValue (has cyclic type dependency)
const __meta_ArrayValue = Ref{ProtoMeta}()
function meta(::Type{ArrayValue})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ArrayValue)
            __meta_ArrayValue[] = target = ProtoMeta(ArrayValue)
            allflds = Pair{Symbol,Union{Type,String}}[:values => Base.Vector{AnyValue}]
            meta(target, ArrayValue, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_ArrayValue[]
    end
end
function Base.getproperty(obj::ArrayValue, name::Symbol)
    if name === :values
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{AnyValue}
    else
        getfield(obj, name)
    end
end

mutable struct KeyValueList <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function KeyValueList(; kwargs...)
        obj = new(meta(KeyValueList), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct KeyValueList (has cyclic type dependency)
const __meta_KeyValueList = Ref{ProtoMeta}()
function meta(::Type{KeyValueList})
    ProtoBuf.metalock() do
        if !isassigned(__meta_KeyValueList)
            __meta_KeyValueList[] = target = ProtoMeta(KeyValueList)
            allflds = Pair{Symbol,Union{Type,String}}[:values => "Base.Vector{KeyValue}"]
            meta(target, KeyValueList, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_KeyValueList[]
    end
end
function Base.getproperty(obj::KeyValueList, name::Symbol)
    if name === :values
        return (obj.__protobuf_jl_internal_values[name])::Any
    else
        getfield(obj, name)
    end
end

mutable struct KeyValue <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function KeyValue(; kwargs...)
        obj = new(meta(KeyValue), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct KeyValue (has cyclic type dependency)
const __meta_KeyValue = Ref{ProtoMeta}()
function meta(::Type{KeyValue})
    ProtoBuf.metalock() do
        if !isassigned(__meta_KeyValue)
            __meta_KeyValue[] = target = ProtoMeta(KeyValue)
            allflds = Pair{Symbol,Union{Type,String}}[:key => AbstractString, :value => AnyValue]
            meta(target, KeyValue, allflds, ProtoBuf.DEF_REQ, ProtoBuf.DEF_FNUM, ProtoBuf.DEF_VAL, ProtoBuf.DEF_PACK, ProtoBuf.DEF_WTYPES, ProtoBuf.DEF_ONEOFS, ProtoBuf.DEF_ONEOF_NAMES)
        end
        __meta_KeyValue[]
    end
end
function Base.getproperty(obj::KeyValue, name::Symbol)
    if name === :key
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :value
        return (obj.__protobuf_jl_internal_values[name])::AnyValue
    else
        getfield(obj, name)
    end
end

export AnyValue, ArrayValue, KeyValueList, KeyValue, InstrumentationLibrary, AnyValue, ArrayValue, KeyValueList, KeyValue
