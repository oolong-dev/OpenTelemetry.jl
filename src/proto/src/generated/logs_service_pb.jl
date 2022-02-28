# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

mutable struct ExportLogsServiceRequest <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExportLogsServiceRequest(; kwargs...)
        obj = new(meta(ExportLogsServiceRequest), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExportLogsServiceRequest
const __meta_ExportLogsServiceRequest = Ref{ProtoMeta}()
function meta(::Type{ExportLogsServiceRequest})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExportLogsServiceRequest)
            __meta_ExportLogsServiceRequest[] = target = ProtoMeta(ExportLogsServiceRequest)
            allflds = Pair{Symbol,Union{Type,String}}[:resource_logs=>Base.Vector{
                opentelemetry.proto.logs.v1.ResourceLogs,
            }]
            meta(
                target,
                ExportLogsServiceRequest,
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
        __meta_ExportLogsServiceRequest[]
    end
end
function Base.getproperty(obj::ExportLogsServiceRequest, name::Symbol)
    if name === :resource_logs
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.logs.v1.ResourceLogs,
        }
    else
        getfield(obj, name)
    end
end

mutable struct ExportLogsServiceResponse <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExportLogsServiceResponse(; kwargs...)
        obj = new(meta(ExportLogsServiceResponse), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExportLogsServiceResponse
const __meta_ExportLogsServiceResponse = Ref{ProtoMeta}()
function meta(::Type{ExportLogsServiceResponse})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExportLogsServiceResponse)
            __meta_ExportLogsServiceResponse[] =
                target = ProtoMeta(ExportLogsServiceResponse)
            allflds = Pair{Symbol,Union{Type,String}}[]
            meta(
                target,
                ExportLogsServiceResponse,
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
        __meta_ExportLogsServiceResponse[]
    end
end

# service methods for LogsService
const _LogsService_methods = MethodDescriptor[MethodDescriptor(
    "Export",
    1,
    ExportLogsServiceRequest,
    ExportLogsServiceResponse,
)] # const _LogsService_methods
const _LogsService_desc = ServiceDescriptor(
    "opentelemetry.proto.collector.logs.v1.LogsService",
    1,
    _LogsService_methods,
)

LogsService(impl::Module) = ProtoService(_LogsService_desc, impl)

mutable struct LogsServiceStub <: AbstractProtoServiceStub{false}
    impl::ProtoServiceStub
    LogsServiceStub(channel::ProtoRpcChannel) =
        new(ProtoServiceStub(_LogsService_desc, channel))
end # mutable struct LogsServiceStub

mutable struct LogsServiceBlockingStub <: AbstractProtoServiceStub{true}
    impl::ProtoServiceBlockingStub
    LogsServiceBlockingStub(channel::ProtoRpcChannel) =
        new(ProtoServiceBlockingStub(_LogsService_desc, channel))
end # mutable struct LogsServiceBlockingStub

Export(
    stub::LogsServiceStub,
    controller::ProtoRpcController,
    inp::ExportLogsServiceRequest,
    done::Function,
) = call_method(stub.impl, _LogsService_methods[1], controller, inp, done)
Export(
    stub::LogsServiceBlockingStub,
    controller::ProtoRpcController,
    inp::ExportLogsServiceRequest,
) = call_method(stub.impl, _LogsService_methods[1], controller, inp)

export ExportLogsServiceRequest,
    ExportLogsServiceResponse, LogsService, LogsServiceStub, LogsServiceBlockingStub, Export
