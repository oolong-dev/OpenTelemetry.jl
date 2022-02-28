OTLP_VERSION = v"0.13.0"

using Downloads
using CodecZlib
using Tar
using gRPCClient

download_url = "https://github.com/open-telemetry/opentelemetry-proto/archive/refs/tags/v$OTLP_VERSION.tar.gz"

open(Downloads.download(download_url)) do tar_gz
    tar = GzipDecompressorStream(tar_gz)
    dir = Tar.extract(tar)
    proto_dir = joinpath(dir, "opentelemetry-proto-$OTLP_VERSION")

    trace_proto_file = joinpath(
        proto_dir,
        "opentelemetry",
        "proto",
        "collector",
        "trace",
        "v1",
        "trace_service.proto",
    )

    trace_dir = joinpath(@__DIR__, "..", "src", "trace_generated")

    gRPCClient.generate(trace_proto_file; outdir = trace_dir, includes = [proto_dir])

    metrics_proto_file = joinpath(
        proto_dir,
        "opentelemetry",
        "proto",
        "collector",
        "metrics",
        "v1",
        "metrics_service.proto",
    )

    metrics_dir = joinpath(@__DIR__, "..", "src", "metrics_generated")

    gRPCClient.generate(metrics_proto_file; outdir = metrics_dir, includes = [proto_dir])

    logs_proto_file = joinpath(
        proto_dir,
        "opentelemetry",
        "proto",
        "collector",
        "logs",
        "v1",
        "logs_service.proto",
    )

    logs_dir = joinpath(@__DIR__, "..", "src", "logs_generated")

    gRPCClient.generate(logs_proto_file; outdir = logs_dir, includes = [proto_dir])

end
