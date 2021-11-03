OTLP_VERSION = v"0.10.0"

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
    gRPCClient.generate(
        trace_proto_file;
        outdir = joinpath(@__DIR__, "..", "src", "generated"),
        includes = [proto_dir],
    )
end
