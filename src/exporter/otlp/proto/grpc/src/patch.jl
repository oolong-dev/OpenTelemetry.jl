import ProtoBuf

wire_jl_type(s::Symbol, x) = wire_jl_type(Val(s), x)

wire_jl_type(::Val, x) = x

wire_jl_type(v::Val, xs::Array) = map(x -> wire_jl_type(v, x), xs)
wire_jl_type(::Val{:fixed32}, x::Number) = ProtoBuf.FixedSizeNumber(x)
wire_jl_type(::Val{:fixed64}, x::Number) = ProtoBuf.FixedSizeNumber(x)
wire_jl_type(::Val{:sfixed32}, x::Number) = ProtoBuf.FixedSizeNumber(x)
wire_jl_type(::Val{:sfixed64}, x::Number) = ProtoBuf.FixedSizeNumber(x)
wire_jl_type(::Val{:sint32}, x::Number) = ProtoBuf.SignedNumber(x)
wire_jl_type(::Val{:sint64}, x::Number) = ProtoBuf.SignedNumber(x)

wire_jl_type(::Val{:fixed32}, x::Type) = ProtoBuf.FixedSizeNumber{x}
wire_jl_type(::Val{:fixed64}, x::Type) = ProtoBuf.FixedSizeNumber{x}
wire_jl_type(::Val{:sfixed32}, x::Type) = ProtoBuf.FixedSizeNumber{x}
wire_jl_type(::Val{:sfixed64}, x::Type) = ProtoBuf.FixedSizeNumber{x}
wire_jl_type(::Val{:sint32}, x::Type) = ProtoBuf.SignedNumber{x}
wire_jl_type(::Val{:sint64}, x::Type) = ProtoBuf.SignedNumber{x}

function ProtoBuf.writeproto(io::IO, obj, meta::ProtoBuf.ProtoMeta=ProtoBuf.meta(typeof(obj)))
    n = 0
    @debug("writeproto writing an obj", meta)
    for attrib in meta.ordered
        fld = attrib.fld
        if hasproperty(obj, fld)
            @debug("writeproto", field=fld)
            n += ProtoBuf.writeproto(io, wire_jl_type(attrib.ptyp, getproperty(obj, fld)), attrib)
        else
            @debug("not set", field=fld)
            (attrib.occurrence == 1) && error("missing required field $fld (#$(attrib.fldnum))")
        end
    end
    n
end

function ProtoBuf.read_field(io, container, attrib::ProtoBuf.ProtoMetaAttribs, wiretyp, jtyp::Type{T}) where T<:ProtoBuf.ConcreteTypes
    return ProtoBuf._read_value(io, wire_jl_type(attrib.ptyp, jtyp))
end
