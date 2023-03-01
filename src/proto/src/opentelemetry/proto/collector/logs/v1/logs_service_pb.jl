# Autogenerated using ProtoBuf.jl v1.0.9 on 2023-03-01T12:24:55.830
# original file: /home/tj/workspace/git/OpenTelemetry.jl/src/proto/dev/opentelemetry-proto-0.19.0/opentelemetry/proto/collector/logs/v1/logs_service.proto (proto3 syntax)

import ProtoBuf as PB
using ProtoBuf: OneOf
using ProtoBuf.EnumX: @enumx

export ExportLogsServiceRequest, ExportLogsPartialSuccess, ExportLogsServiceResponse
export LogsService

struct ExportLogsServiceRequest
    resource_logs::Vector{opentelemetry.proto.logs.v1.ResourceLogs}
end
PB.default_values(::Type{ExportLogsServiceRequest}) = (;resource_logs = Vector{opentelemetry.proto.logs.v1.ResourceLogs}())
PB.field_numbers(::Type{ExportLogsServiceRequest}) = (;resource_logs = 1)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ExportLogsServiceRequest})
    resource_logs = PB.BufferedVector{opentelemetry.proto.logs.v1.ResourceLogs}()
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            PB.decode!(d, resource_logs)
        else
            PB.skip(d, wire_type)
        end
    end
    return ExportLogsServiceRequest(resource_logs[])
end

function PB.encode(e::PB.AbstractProtoEncoder, x::ExportLogsServiceRequest)
    initpos = position(e.io)
    !isempty(x.resource_logs) && PB.encode(e, 1, x.resource_logs)
    return position(e.io) - initpos
end
function PB._encoded_size(x::ExportLogsServiceRequest)
    encoded_size = 0
    !isempty(x.resource_logs) && (encoded_size += PB._encoded_size(x.resource_logs, 1))
    return encoded_size
end

struct ExportLogsPartialSuccess
    rejected_log_records::Int64
    error_message::String
end
PB.default_values(::Type{ExportLogsPartialSuccess}) = (;rejected_log_records = zero(Int64), error_message = "")
PB.field_numbers(::Type{ExportLogsPartialSuccess}) = (;rejected_log_records = 1, error_message = 2)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ExportLogsPartialSuccess})
    rejected_log_records = zero(Int64)
    error_message = ""
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            rejected_log_records = PB.decode(d, Int64)
        elseif field_number == 2
            error_message = PB.decode(d, String)
        else
            PB.skip(d, wire_type)
        end
    end
    return ExportLogsPartialSuccess(rejected_log_records, error_message)
end

function PB.encode(e::PB.AbstractProtoEncoder, x::ExportLogsPartialSuccess)
    initpos = position(e.io)
    x.rejected_log_records != zero(Int64) && PB.encode(e, 1, x.rejected_log_records)
    !isempty(x.error_message) && PB.encode(e, 2, x.error_message)
    return position(e.io) - initpos
end
function PB._encoded_size(x::ExportLogsPartialSuccess)
    encoded_size = 0
    x.rejected_log_records != zero(Int64) && (encoded_size += PB._encoded_size(x.rejected_log_records, 1))
    !isempty(x.error_message) && (encoded_size += PB._encoded_size(x.error_message, 2))
    return encoded_size
end

struct ExportLogsServiceResponse
    partial_success::Union{Nothing,ExportLogsPartialSuccess}
end
PB.default_values(::Type{ExportLogsServiceResponse}) = (;partial_success = nothing)
PB.field_numbers(::Type{ExportLogsServiceResponse}) = (;partial_success = 1)

function PB.decode(d::PB.AbstractProtoDecoder, ::Type{<:ExportLogsServiceResponse})
    partial_success = Ref{Union{Nothing,ExportLogsPartialSuccess}}(nothing)
    while !PB.message_done(d)
        field_number, wire_type = PB.decode_tag(d)
        if field_number == 1
            PB.decode!(d, partial_success)
        else
            PB.skip(d, wire_type)
        end
    end
    return ExportLogsServiceResponse(partial_success[])
end

function PB.encode(e::PB.AbstractProtoEncoder, x::ExportLogsServiceResponse)
    initpos = position(e.io)
    !isnothing(x.partial_success) && PB.encode(e, 1, x.partial_success)
    return position(e.io) - initpos
end
function PB._encoded_size(x::ExportLogsServiceResponse)
    encoded_size = 0
    !isnothing(x.partial_success) && (encoded_size += PB._encoded_size(x.partial_success, 1))
    return encoded_size
end

# TODO: SERVICE
#    LogsService
