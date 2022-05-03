# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

const Status_StatusCode = (;
    [
        Symbol("STATUS_CODE_UNSET") => Int32(0),
        Symbol("STATUS_CODE_OK") => Int32(1),
        Symbol("STATUS_CODE_ERROR") => Int32(2),
    ]...
)

mutable struct Status <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Status(; kwargs...)
        obj = new(meta(Status), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Status
const __meta_Status = Ref{ProtoMeta}()
function meta(::Type{Status})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Status)
            __meta_Status[] = target = ProtoMeta(Status)
            fnum = Int[2, 3]
            allflds =
                Pair{Symbol,Union{Type,String}}[:message=>AbstractString, :code=>Int32]
            meta(
                target,
                Status,
                allflds,
                ProtoBuf.DEF_REQ,
                fnum,
                ProtoBuf.DEF_VAL,
                ProtoBuf.DEF_PACK,
                ProtoBuf.DEF_WTYPES,
                ProtoBuf.DEF_ONEOFS,
                ProtoBuf.DEF_ONEOF_NAMES,
            )
        end
        __meta_Status[]
    end
end
function Base.getproperty(obj::Status, name::Symbol)
    if name === :message
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :code
        return (obj.__protobuf_jl_internal_values[name])::Int32
    else
        getfield(obj, name)
    end
end

const Span_SpanKind = (;
    [
        Symbol("SPAN_KIND_UNSPECIFIED") => Int32(0),
        Symbol("SPAN_KIND_INTERNAL") => Int32(1),
        Symbol("SPAN_KIND_SERVER") => Int32(2),
        Symbol("SPAN_KIND_CLIENT") => Int32(3),
        Symbol("SPAN_KIND_PRODUCER") => Int32(4),
        Symbol("SPAN_KIND_CONSUMER") => Int32(5),
    ]...
)

mutable struct Span_Event <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Span_Event(; kwargs...)
        obj = new(meta(Span_Event), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Span_Event
const __meta_Span_Event = Ref{ProtoMeta}()
function meta(::Type{Span_Event})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Span_Event)
            __meta_Span_Event[] = target = ProtoMeta(Span_Event)
            wtype = Dict(:time_unix_nano => :fixed64)
            allflds = Pair{Symbol,Union{Type,String}}[
                :time_unix_nano=>UInt64,
                :name=>AbstractString,
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :dropped_attributes_count=>UInt32,
            ]
            meta(
                target,
                Span_Event,
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
        __meta_Span_Event[]
    end
end
function Base.getproperty(obj::Span_Event, name::Symbol)
    if name === :time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :name
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :dropped_attributes_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    else
        getfield(obj, name)
    end
end

mutable struct Span_Link <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Span_Link(; kwargs...)
        obj = new(meta(Span_Link), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Span_Link
const __meta_Span_Link = Ref{ProtoMeta}()
function meta(::Type{Span_Link})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Span_Link)
            __meta_Span_Link[] = target = ProtoMeta(Span_Link)
            allflds = Pair{Symbol,Union{Type,String}}[
                :trace_id=>Vector{UInt8},
                :span_id=>Vector{UInt8},
                :trace_state=>AbstractString,
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :dropped_attributes_count=>UInt32,
            ]
            meta(
                target,
                Span_Link,
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
        __meta_Span_Link[]
    end
end
function Base.getproperty(obj::Span_Link, name::Symbol)
    if name === :trace_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :span_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :trace_state
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :dropped_attributes_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    else
        getfield(obj, name)
    end
end

mutable struct Span <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function Span(; kwargs...)
        obj = new(meta(Span), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct Span
const __meta_Span = Ref{ProtoMeta}()
function meta(::Type{Span})
    ProtoBuf.metalock() do
        if !isassigned(__meta_Span)
            __meta_Span[] = target = ProtoMeta(Span)
            wtype = Dict(:start_time_unix_nano => :fixed64, :end_time_unix_nano => :fixed64)
            allflds = Pair{Symbol,Union{Type,String}}[
                :trace_id=>Vector{UInt8},
                :span_id=>Vector{UInt8},
                :trace_state=>AbstractString,
                :parent_span_id=>Vector{UInt8},
                :name=>AbstractString,
                :kind=>Int32,
                :start_time_unix_nano=>UInt64,
                :end_time_unix_nano=>UInt64,
                :attributes=>Base.Vector{opentelemetry.proto.common.v1.KeyValue},
                :dropped_attributes_count=>UInt32,
                :events=>Base.Vector{Span_Event},
                :dropped_events_count=>UInt32,
                :links=>Base.Vector{Span_Link},
                :dropped_links_count=>UInt32,
                :status=>Status,
            ]
            meta(
                target,
                Span,
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
        __meta_Span[]
    end
end
function Base.getproperty(obj::Span, name::Symbol)
    if name === :trace_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :span_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :trace_state
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :parent_span_id
        return (obj.__protobuf_jl_internal_values[name])::Vector{UInt8}
    elseif name === :name
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    elseif name === :kind
        return (obj.__protobuf_jl_internal_values[name])::Int32
    elseif name === :start_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :end_time_unix_nano
        return (obj.__protobuf_jl_internal_values[name])::UInt64
    elseif name === :attributes
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.common.v1.KeyValue,
        }
    elseif name === :dropped_attributes_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    elseif name === :events
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Span_Event}
    elseif name === :dropped_events_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    elseif name === :links
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Span_Link}
    elseif name === :dropped_links_count
        return (obj.__protobuf_jl_internal_values[name])::UInt32
    elseif name === :status
        return (obj.__protobuf_jl_internal_values[name])::Status
    else
        getfield(obj, name)
    end
end

mutable struct InstrumentationLibrarySpans <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function InstrumentationLibrarySpans(; kwargs...)
        obj = new(meta(InstrumentationLibrarySpans), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct InstrumentationLibrarySpans
const __meta_InstrumentationLibrarySpans = Ref{ProtoMeta}()
function meta(::Type{InstrumentationLibrarySpans})
    ProtoBuf.metalock() do
        if !isassigned(__meta_InstrumentationLibrarySpans)
            __meta_InstrumentationLibrarySpans[] =
                target = ProtoMeta(InstrumentationLibrarySpans)
            allflds = Pair{Symbol,Union{Type,String}}[
                :instrumentation_library=>opentelemetry.proto.common.v1.InstrumentationLibrary,
                :spans=>Base.Vector{Span},
                :schema_url=>AbstractString,
            ]
            meta(
                target,
                InstrumentationLibrarySpans,
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
        __meta_InstrumentationLibrarySpans[]
    end
end
function Base.getproperty(obj::InstrumentationLibrarySpans, name::Symbol)
    if name === :instrumentation_library
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.common.v1.InstrumentationLibrary
    elseif name === :spans
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{Span}
    elseif name === :schema_url
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct ResourceSpans <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ResourceSpans(; kwargs...)
        obj = new(meta(ResourceSpans), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ResourceSpans
const __meta_ResourceSpans = Ref{ProtoMeta}()
function meta(::Type{ResourceSpans})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ResourceSpans)
            __meta_ResourceSpans[] = target = ProtoMeta(ResourceSpans)
            allflds = Pair{Symbol,Union{Type,String}}[
                :resource=>opentelemetry.proto.resource.v1.Resource,
                :instrumentation_library_spans=>Base.Vector{InstrumentationLibrarySpans},
                :schema_url=>AbstractString,
            ]
            meta(
                target,
                ResourceSpans,
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
        __meta_ResourceSpans[]
    end
end
function Base.getproperty(obj::ResourceSpans, name::Symbol)
    if name === :resource
        return (obj.__protobuf_jl_internal_values[name])::opentelemetry.proto.resource.v1.Resource
    elseif name === :instrumentation_library_spans
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            InstrumentationLibrarySpans,
        }
    elseif name === :schema_url
        return (obj.__protobuf_jl_internal_values[name])::AbstractString
    else
        getfield(obj, name)
    end
end

mutable struct TracesData <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function TracesData(; kwargs...)
        obj = new(meta(TracesData), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct TracesData
const __meta_TracesData = Ref{ProtoMeta}()
function meta(::Type{TracesData})
    ProtoBuf.metalock() do
        if !isassigned(__meta_TracesData)
            __meta_TracesData[] = target = ProtoMeta(TracesData)
            allflds =
                Pair{Symbol,Union{Type,String}}[:resource_spans=>Base.Vector{ResourceSpans}]
            meta(
                target,
                TracesData,
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
        __meta_TracesData[]
    end
end
function Base.getproperty(obj::TracesData, name::Symbol)
    if name === :resource_spans
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{ResourceSpans}
    else
        getfield(obj, name)
    end
end

export TracesData,
    ResourceSpans,
    InstrumentationLibrarySpans,
    Span_SpanKind,
    Span_Event,
    Span_Link,
    Span,
    Status_StatusCode,
    Status
