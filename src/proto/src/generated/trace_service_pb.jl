# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

mutable struct ExportTraceServiceRequest <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExportTraceServiceRequest(; kwargs...)
        obj = new(meta(ExportTraceServiceRequest), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExportTraceServiceRequest
const __meta_ExportTraceServiceRequest = Ref{ProtoMeta}()
function meta(::Type{ExportTraceServiceRequest})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExportTraceServiceRequest)
            __meta_ExportTraceServiceRequest[] =
                target = ProtoMeta(ExportTraceServiceRequest)
            allflds = Pair{Symbol,Union{Type,String}}[:resource_spans=>Base.Vector{
                opentelemetry.proto.trace.v1.ResourceSpans,
            }]
            meta(
                target,
                ExportTraceServiceRequest,
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
        __meta_ExportTraceServiceRequest[]
    end
end
function Base.getproperty(obj::ExportTraceServiceRequest, name::Symbol)
    if name === :resource_spans
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.trace.v1.ResourceSpans,
        }
    else
        getfield(obj, name)
    end
end

mutable struct ExportTraceServiceResponse <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExportTraceServiceResponse(; kwargs...)
        obj = new(meta(ExportTraceServiceResponse), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExportTraceServiceResponse
const __meta_ExportTraceServiceResponse = Ref{ProtoMeta}()
function meta(::Type{ExportTraceServiceResponse})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExportTraceServiceResponse)
            __meta_ExportTraceServiceResponse[] =
                target = ProtoMeta(ExportTraceServiceResponse)
            allflds = Pair{Symbol,Union{Type,String}}[]
            meta(
                target,
                ExportTraceServiceResponse,
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
        __meta_ExportTraceServiceResponse[]
    end
end

# service methods for TraceService
const _TraceService_methods = MethodDescriptor[MethodDescriptor(
    "Export",
    1,
    ExportTraceServiceRequest,
    ExportTraceServiceResponse,
)] # const _TraceService_methods
const _TraceService_desc = ServiceDescriptor(
    "opentelemetry.proto.collector.trace.v1.TraceService",
    1,
    _TraceService_methods,
)

TraceService(impl::Module) = ProtoService(_TraceService_desc, impl)

mutable struct TraceServiceStub <: AbstractProtoServiceStub{false}
    impl::ProtoServiceStub
    TraceServiceStub(channel::ProtoRpcChannel) =
        new(ProtoServiceStub(_TraceService_desc, channel))
end # mutable struct TraceServiceStub

mutable struct TraceServiceBlockingStub <: AbstractProtoServiceStub{true}
    impl::ProtoServiceBlockingStub
    TraceServiceBlockingStub(channel::ProtoRpcChannel) =
        new(ProtoServiceBlockingStub(_TraceService_desc, channel))
end # mutable struct TraceServiceBlockingStub

Export(
    stub::TraceServiceStub,
    controller::ProtoRpcController,
    inp::ExportTraceServiceRequest,
    done::Function,
) = call_method(stub.impl, _TraceService_methods[1], controller, inp, done)
Export(
    stub::TraceServiceBlockingStub,
    controller::ProtoRpcController,
    inp::ExportTraceServiceRequest,
) = call_method(stub.impl, _TraceService_methods[1], controller, inp)

export ExportTraceServiceRequest,
    ExportTraceServiceResponse,
    TraceService,
    TraceServiceStub,
    TraceServiceBlockingStub,
    Export
