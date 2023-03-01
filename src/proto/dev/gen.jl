OTLP_VERSION = v"0.19.0"

using Downloads
using CodecZlib
using Tar
using ProtoBuf

download_url = "https://github.com/open-telemetry/opentelemetry-proto/archive/refs/tags/v$OTLP_VERSION.tar.gz"

open(Downloads.download(download_url)) do tar_gz
    tar = GzipDecompressorStream(tar_gz)
    dir = Tar.extract(tar)
    proto_dir = joinpath(dir, "opentelemetry-proto-$OTLP_VERSION")

    protojl(
        "opentelemetry/proto/collector/trace/v1/trace_service.proto",
        proto_dir,
        "../src",
    )

    protojl(
        "opentelemetry/proto/collector/metrics/v1/metrics_service.proto",
        proto_dir,
        "../src",
    )

    protojl("opentelemetry/proto/collector/logs/v1/logs_service.proto", proto_dir, "../src")
end

# TODO: Still need to manually merge these subpackages
