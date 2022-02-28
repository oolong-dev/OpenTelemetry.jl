# syntax: proto3
using ProtoBuf
import ProtoBuf.meta
import ._ProtoBuf_Top_.opentelemetry

mutable struct ExportMetricsServiceRequest <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExportMetricsServiceRequest(; kwargs...)
        obj = new(meta(ExportMetricsServiceRequest), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExportMetricsServiceRequest
const __meta_ExportMetricsServiceRequest = Ref{ProtoMeta}()
function meta(::Type{ExportMetricsServiceRequest})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExportMetricsServiceRequest)
            __meta_ExportMetricsServiceRequest[] =
                target = ProtoMeta(ExportMetricsServiceRequest)
            allflds = Pair{Symbol,Union{Type,String}}[:resource_metrics=>Base.Vector{
                opentelemetry.proto.metrics.v1.ResourceMetrics,
            }]
            meta(
                target,
                ExportMetricsServiceRequest,
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
        __meta_ExportMetricsServiceRequest[]
    end
end
function Base.getproperty(obj::ExportMetricsServiceRequest, name::Symbol)
    if name === :resource_metrics
        return (obj.__protobuf_jl_internal_values[name])::Base.Vector{
            opentelemetry.proto.metrics.v1.ResourceMetrics,
        }
    else
        getfield(obj, name)
    end
end

mutable struct ExportMetricsServiceResponse <: ProtoType
    __protobuf_jl_internal_meta::ProtoMeta
    __protobuf_jl_internal_values::Dict{Symbol,Any}
    __protobuf_jl_internal_defaultset::Set{Symbol}

    function ExportMetricsServiceResponse(; kwargs...)
        obj = new(meta(ExportMetricsServiceResponse), Dict{Symbol,Any}(), Set{Symbol}())
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
end # mutable struct ExportMetricsServiceResponse
const __meta_ExportMetricsServiceResponse = Ref{ProtoMeta}()
function meta(::Type{ExportMetricsServiceResponse})
    ProtoBuf.metalock() do
        if !isassigned(__meta_ExportMetricsServiceResponse)
            __meta_ExportMetricsServiceResponse[] =
                target = ProtoMeta(ExportMetricsServiceResponse)
            allflds = Pair{Symbol,Union{Type,String}}[]
            meta(
                target,
                ExportMetricsServiceResponse,
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
        __meta_ExportMetricsServiceResponse[]
    end
end

# service methods for MetricsService
const _MetricsService_methods = MethodDescriptor[MethodDescriptor(
    "Export",
    1,
    ExportMetricsServiceRequest,
    ExportMetricsServiceResponse,
)] # const _MetricsService_methods
const _MetricsService_desc = ServiceDescriptor(
    "opentelemetry.proto.collector.metrics.v1.MetricsService",
    1,
    _MetricsService_methods,
)

MetricsService(impl::Module) = ProtoService(_MetricsService_desc, impl)

mutable struct MetricsServiceStub <: AbstractProtoServiceStub{false}
    impl::ProtoServiceStub
    MetricsServiceStub(channel::ProtoRpcChannel) =
        new(ProtoServiceStub(_MetricsService_desc, channel))
end # mutable struct MetricsServiceStub

mutable struct MetricsServiceBlockingStub <: AbstractProtoServiceStub{true}
    impl::ProtoServiceBlockingStub
    MetricsServiceBlockingStub(channel::ProtoRpcChannel) =
        new(ProtoServiceBlockingStub(_MetricsService_desc, channel))
end # mutable struct MetricsServiceBlockingStub

Export(
    stub::MetricsServiceStub,
    controller::ProtoRpcController,
    inp::ExportMetricsServiceRequest,
    done::Function,
) = call_method(stub.impl, _MetricsService_methods[1], controller, inp, done)
Export(
    stub::MetricsServiceBlockingStub,
    controller::ProtoRpcController,
    inp::ExportMetricsServiceRequest,
) = call_method(stub.impl, _MetricsService_methods[1], controller, inp)

export ExportMetricsServiceRequest,
    ExportMetricsServiceResponse,
    MetricsService,
    MetricsServiceStub,
    MetricsServiceBlockingStub,
    Export
