module OpenTelemetryInstrumentationDownloads

using OpenTelemetryAPI

using ArgTools
using Downloads
using Downloads.Curl

using TOML

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])
const instrumentation_scope = InstrumentationScope(
    name = string(@__MODULE__),
    version = PKG_VERSION,
    schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationDownloads/",
)

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
        with_span(
            "Downloads $method",
            DOWNLOAD_TRACER[];
            kind = SPAN_KIND_CLIENT,
            attributes = Dict{String,TAttrVal}(
                "http.method" => isnothing(method) ? "" : method,
                "http.url" => url,
            ),
        ) do
            s = current_span()
            arg_write(output) do output
                response = request(
                    url,
                    output = output,
                    method = method,
                    headers = inject_context!(headers),
                    timeout = timeout,
                    progress = progress,
                    verbose = verbose,
                    downloader = downloader,
                )::Response
                DOWNLOAD_METRICS[](; proto = response.proto, status = response.status)
                s["http.scheme"] = response.proto
                s["http.status_code"] = response.status
                status_ok(response.proto, response.status) && return output
                throw(RequestError(url, Curl.CURLE_OK, "", response))
            end
        end
    end
end

"""
## Metrics

| Meter Name  | Instrument Name | Instrument Type | Unit | Description          |
|:----------- |:--------------- |:--------------- |:---- |:-------------------- |
| `Downloads` | `download`      | `Counter{UInt}` |      | Number of downloads. |

## Spans

We try to follow [semantic conventions for HTTP
spans](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/semantic_conventions/http.md)
here.

The following attributes are added on span creation:

  - `http.method`
  - `http.url`

The following attributes are added when response is received:

  - `http.scheme`
  - `http.status_code`
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
            instrumentation_scope = instrumentation_scope,
        );
        unit = "",
        description = "Number of downloads.",
    )

    DOWNLOAD_TRACER[] =
        Tracer(; provider = tracer_provider, instrumentation_scope = instrumentation_scope)
end

function __init__()
    init()
end

end # module
