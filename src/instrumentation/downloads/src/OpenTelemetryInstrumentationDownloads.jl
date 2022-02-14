module OpenTelemetryInstrumentationDownloads

using OpenTelemetryAPI

using ArgTools
using Downloads
using Downloads.Curl

using TOML

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

const download = Downloads.download

const DOWNLOAD_METRICS = Ref{Counter{UInt}}()
const DOWNLOAD_TRACER = Ref{Tracer}()

if VERSION <= v"1.7.2"
    function Downloads.download(
        url::AbstractString,
        output::Union{ArgWrite,Nothing} = nothing;
        method::Union{AbstractString,Nothing} = nothing,
        headers::Union{AbstractVector,AbstractDict} = Pair{String,String}[],
        timeout::Real = Inf,
        progress::Union{Function,Nothing} = nothing,
        verbose::Bool = false,
        downloader::Union{Downloader,Nothing} = nothing,
    )::ArgWrite
        with_span("download", DOWNLOAD_TRACER[]) do
            arg_write(output) do output
                response = request(
                    url,
                    output = output,
                    method = method,
                    headers = inject!(headers, TraceContextTextMapPropagator()),
                    timeout = timeout,
                    progress = progress,
                    verbose = verbose,
                    downloader = downloader,
                )::Response
                DOWNLOAD_METRICS[](; proto = response.proto, status = response.status)
                s = current_span()
                s["proto"] = response.proto
                s["status"] = response.status
                status_ok(response.proto, response.status) && return output
                throw(RequestError(url, Curl.CURLE_OK, "", response))
            end
        end
    end
end

"""
## Schema

| Meter Name  | Instrument Name | Instrument Type | Unit | Description          |
|:----------- |:--------------- |:--------------- |:---- |:-------------------- |
| `Downloads` | `download`      | `Counter{UInt}` |      | Number of downloads. |
"""
function init(;
    meter_provider = global_meter_provider(),
    tracer_provider = global_tracer_provider(),
)
    DOWNLOAD_METRICS[] = Counter{UInt}(
        "download",
        Meter(
            "Downloads";
            provider = meter_provider,
            version = PKG_VERSION,
            schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationDownloads/",
        );
        unit = "",
        description = "Number of downloads.",
    )

    DOWNLOAD_TRACER[] = Tracer("Downloads", PKG_VERSION; provider = tracer_provider)
end

function __init__()
    init()
end

end # module
