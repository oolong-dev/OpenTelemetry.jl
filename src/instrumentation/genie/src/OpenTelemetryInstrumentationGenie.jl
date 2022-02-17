module OpenTelemetryInstrumentationGenie

using OpenTelemetryAPI
using Genie
using URIs
using TOML

const ACTION_BEFORE_INSTRUMENT = :ACTION_BEFORE_INSTRUMENT

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

const GENIE_TRACER = Ref{Tracer}()
const GENIE_METRICS = Ref{Counter{UInt}}()

function _instrument(req, resp, params, action) end

function instrument(req, resp, params)
    if Genie.PARAMS_ROUTE_KEY in params
        r = params[Genie.PARAMS_ROUTE_KEY]
        a = r.action
        r.action =
            () -> with_span(
                "Genie $(r.path)",
                GENIE_TRACER[];
                kind = SPAN_KIND_SERVER,
                attributes = Dict{String,TAttrVal}(
                    "http.method" => r.method,
                    "http.target" => req.resource,
                    "http.request_content_length" => length(req.data),
                    "http.route" => r.path,
                ),
            ) do
                res = a() |> Genie.to_response
                s = current_span()
                s["http.status_code"] = string(res.status)
                s["http.response_content_length"] = length(res.data)
                GENIE_METRICS[](; route = r.path, status = res.status)
                r.action = a  # recover action
                res
            end
    end
    req, resp, params
end

"""
## Metrics

| Meter Name | Instrument Name | Instrument Type | Unit | Dimensions        | Description         |
|:---------- |:--------------- |:--------------- |:---- |:----------------- |:------------------- |
| `http`     | `request`       | `Counter{UInt}` |      | `route`, `status` | Number of requests. |

## Spans

We try to follow [semantic conventions for HTTP
spans](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/semantic_conventions/http.md)
here.

The following attributes are added on span creation:

  - `http.method`
  - `http.target`
  - `http.request_content_length`
  - `http_route`

The following attributes are added when response is received:

  - `http.status_code`
  - `http.response_content_length`
"""
function init(;
    tracer_provider = global_tracer_provider(),
    meter_provider = global_meter_provider(),
)
    if any(h isa InstrumentHook for h in Genie.Router.content_negotiation_hooks)
        # already initialized
    else
        push!(
            Genie.Router.content_negotiation_hooks,
            InstrumentHook(tracer_provider, meter_provider),
        )
    end

    GENIE_METRICS[] = Counter{UInt}(
        "Genie",
        Meter(
            "request";
            provider = meter_provider,
            version = PKG_VERSION,
            schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationGenie/",
        );
        unit = "",
        description = "Number of requests received.",
    )
    GENIE_TRACER[] = Tracer("Geni", PKG_VERSION; provider = tracer_provider)
end

function __init__()
    init()
end

end # module
