module OpentelemetryClients
using gRPCClient

include("opentelemetry.jl")
using .opentelemetry.proto.collector.trace.v1
import Base: show

# begin service: opentelemetry.proto.collector.trace.v1.TraceService

export TraceServiceBlockingClient, TraceServiceClient

struct TraceServiceBlockingClient
    controller::gRPCController
    channel::gRPCChannel
    stub::TraceServiceBlockingStub

    function TraceServiceBlockingClient(api_base_url::String; kwargs...)
        controller = gRPCController(; kwargs...)
        channel = gRPCChannel(api_base_url)
        stub = TraceServiceBlockingStub(channel)
        new(controller, channel, stub)
    end
end

struct TraceServiceClient
    controller::gRPCController
    channel::gRPCChannel
    stub::TraceServiceStub

    function TraceServiceClient(api_base_url::String; kwargs...)
        controller = gRPCController(; kwargs...)
        channel = gRPCChannel(api_base_url)
        stub = TraceServiceStub(channel)
        new(controller, channel, stub)
    end
end

show(io::IO, client::TraceServiceBlockingClient) =
    print(io, "TraceServiceBlockingClient(", client.channel.baseurl, ")")
show(io::IO, client::TraceServiceClient) =
    print(io, "TraceServiceClient(", client.channel.baseurl, ")")

"""
    Export

  - input: opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest
  - output: opentelemetry.proto.collector.trace.v1.ExportTraceServiceResponse
"""
opentelemetry.proto.collector.trace.v1.Export(
    client::TraceServiceBlockingClient,
    inp::opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest,
) = opentelemetry.proto.collector.trace.v1.Export(client.stub, client.controller, inp)

opentelemetry.proto.collector.trace.v1.Export(
    client::TraceServiceClient,
    inp::opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest,
    done::Function,
) = opentelemetry.proto.collector.trace.v1.Export(client.stub, client.controller, inp, done)

# end service: opentelemetry.proto.collector.trace.v1.TraceService

using .opentelemetry.proto.collector.metrics.v1

# begin service: opentelemetry.proto.collector.metrics.v1.MetricsService

export MetricsServiceBlockingClient, MetricsServiceClient

struct MetricsServiceBlockingClient
    controller::gRPCController
    channel::gRPCChannel
    stub::MetricsServiceBlockingStub

    function MetricsServiceBlockingClient(api_base_url::String; kwargs...)
        controller = gRPCController(; kwargs...)
        channel = gRPCChannel(api_base_url)
        stub = MetricsServiceBlockingStub(channel)
        new(controller, channel, stub)
    end
end

struct MetricsServiceClient
    controller::gRPCController
    channel::gRPCChannel
    stub::MetricsServiceStub

    function MetricsServiceClient(api_base_url::String; kwargs...)
        controller = gRPCController(; kwargs...)
        channel = gRPCChannel(api_base_url)
        stub = MetricsServiceStub(channel)
        new(controller, channel, stub)
    end
end

show(io::IO, client::MetricsServiceBlockingClient) =
    print(io, "MetricsServiceBlockingClient(", client.channel.baseurl, ")")
show(io::IO, client::MetricsServiceClient) =
    print(io, "MetricsServiceClient(", client.channel.baseurl, ")")

"""
    Export

  - input: opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest
  - output: opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceResponse
"""
opentelemetry.proto.collector.metrics.v1.Export(
    client::MetricsServiceBlockingClient,
    inp::opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest,
) = opentelemetry.proto.collector.metrics.v1.Export(client.stub, client.controller, inp)
opentelemetry.proto.collector.metrics.v1.Export(
    client::MetricsServiceClient,
    inp::opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest,
    done::Function,
) = opentelemetry.proto.collector.metrics.v1.Export(client.stub, client.controller, inp, done)

# end service: opentelemetry.proto.collector.metrics.v1.MetricsService

using .opentelemetry.proto.collector.logs.v1

# begin service: opentelemetry.proto.collector.logs.v1.LogsService

export LogsServiceBlockingClient, LogsServiceClient

struct LogsServiceBlockingClient
    controller::gRPCController
    channel::gRPCChannel
    stub::LogsServiceBlockingStub

    function LogsServiceBlockingClient(api_base_url::String; kwargs...)
        controller = gRPCController(; kwargs...)
        channel = gRPCChannel(api_base_url)
        stub = LogsServiceBlockingStub(channel)
        new(controller, channel, stub)
    end
end

struct LogsServiceClient
    controller::gRPCController
    channel::gRPCChannel
    stub::LogsServiceStub

    function LogsServiceClient(api_base_url::String; kwargs...)
        controller = gRPCController(; kwargs...)
        channel = gRPCChannel(api_base_url)
        stub = LogsServiceStub(channel)
        new(controller, channel, stub)
    end
end

show(io::IO, client::LogsServiceBlockingClient) =
    print(io, "LogsServiceBlockingClient(", client.channel.baseurl, ")")
show(io::IO, client::LogsServiceClient) =
    print(io, "LogsServiceClient(", client.channel.baseurl, ")")

"""
    Export

  - input: opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest
  - output: opentelemetry.proto.collector.logs.v1.ExportLogsServiceResponse
"""
opentelemetry.proto.collector.logs.v1.Export(
    client::LogsServiceBlockingClient,
    inp::opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest,
) = opentelemetry.proto.collector.logs.v1.Export(client.stub, client.controller, inp)
opentelemetry.proto.collector.logs.v1.Export(
    client::LogsServiceClient,
    inp::opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest,
    done::Function,
) = opentelemetry.proto.collector.logs.v1.Export(client.stub, client.controller, inp, done)

# end service: opentelemetry.proto.collector.logs.v1.LogsService

end # module OpentelemetryClients
