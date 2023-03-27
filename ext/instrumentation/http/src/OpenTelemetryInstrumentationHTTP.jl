module OpenTelemetryInstrumentationHTTP

using OpenTelemetryAPI

using HTTP
using Sockets
using URIs

using TOML

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])
const instrumentation_scope = InstrumentationScope(
    name = string(@__MODULE__),
    version = PKG_VERSION,
    schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationHTTP/",
)

abstract type OpenTelemetryLayer{Next<:HTTP.Layer} <: HTTP.Layer{Next} end

const HTTP_TRACER = Ref{Tracer}()
const HTTP_METRICS = Ref{Counter{UInt}}()

function HTTP.request(
    ::Type{OpenTelemetryLayer{Next}},
    method,
    url::URI,
    headers,
    body;
    kw...,
)::HTTP.Response where {Next}
    with_span(
        "http $method",
        HTTP_TRACER[];
        kind = SPAN_KIND_CLIENT,
        attributes = Dict{String,TAttrVal}(
            "http.method" => method,
            "http.url" => string(
                URI(;
                    scheme = url.scheme,
                    userinfo = "",  # !!! ignore credentials
                    host = url.host,
                    port = url.port,
                    path = url.path,
                    query = url.query,
                    fragment = url.fragment,
                ),
            ),
            "http.target" => url.path * "?" * url.query,
            "http.host" => url.host |> string,
            "http.scheme" => url.scheme |> string,
            "net.peer.name" => url.host |> string,
            "net.peer.port" => parse(Int, url.port),
        ),
    ) do
        resp = HTTP.request(Next, method, url, inject_context!(headers), body; kw...)
        s = current_span()
        s["http.status_code"] = resp.status |> Int
        s["http.flavor"] = string(resp.version)
        s["http.response_content_length"] = length(resp.body)
        HTTP_METRICS[](; scheme = string(url.scheme), status = Int(resp.status))
        resp
    end
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
  - `http.flavor`
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
    HTTP_METRICS[] = Counter{UInt}(
        "http",
        Meter(
            "request";
            provider = meter_provider,
            instrumentation_scope = instrumentation_scope,
        );
        unit = "",
        description = "Number of requests received.",
    )
    HTTP_TRACER[] =
        Tracer(; provider = tracer_provider, instrumentation_scope = instrumentation_scope)
    top = HTTP.top_layer(stack())
    insert_default!(top, OpenTelemetryLayer)
end

function HTTP.serve(
    f,
    host::Union{IPAddr,String} = Sockets.localhost,
    port::Integer = 8081;
    stream::Bool = false,
    kw...,
)
    handler = if f isa HTTP.Handlers.Handler
        f
    elseif stream
        HTTP.StreamHandlerFunction(f)
    else
        HTTP.RequestHandlerFunction(f)
    end
    return HTTP.Servers.listen(x -> otel_handle(handler, x), host, port; kw...)
end

otel_handle(handler, x) = HTTP.handle(handler, x)

function otel_handle(r::HTTP.Router, http::HTTP.Stream)
    req::HTTP.Request = http.message
    req.body = read(http)
    closeread(http)

    # directly taken from https://github.com/JuliaWeb/HTTP.jl/blob/46687c8e594cbde40cdcfa63fe66123ebad1ea5c/src/Handlers.jl#L459-L468
    #
    # BEGIN
    # get the url/path of the request
    m = Val(Symbol(req.method))
    # get scheme, host, split path into strings and get Vals
    uri = URI(req.target)
    s = get(HTTP.Handlers.SCHEMES, uri.scheme, HTTP.Handlers.EMPTYVAL)
    h = Val(Symbol(uri.host))
    p = uri.path
    segments = split(p, '/'; keepempty = false)
    # dispatch to the most specific handler, given the path
    vals = (get(r.segments, s, Val(Symbol(s))) for s in segments)
    # END

    m_handler = which(
        HTTP.Handlers.gethandler,
        (typeof(r), typeof(m), typeof(s), typeof(h), map(typeof, vals)...),
    )

    handler = HTTP.Handlers.gethandler(r, m, s, h, vals...)

    name = if handler === r.default
        "DEFAULT ROUTE"
    else
        "/" * join(map(type2segment, m_handler.sig.parameters[6:end]), "/")
    end

    with_context(extract_context(req.headers)) do
        with_span(
            name,
            HTTP_TRACER[];
            kind = SPAN_KIND_SERVER,
            attributes = Dict{String,TAttrVal}(
                "http.method" => req.method,
                "http.target" => req.target,
                "http.flavor" => string(req.version),
                "http.request_content_length" => length(req.body),
                "http.route" => name,
            ),
        ) do
            s = current_span()
            resp = HTTP.Handlers.handle(handler, req)
            req.response::HTTP.Response = resp
            req.response.request = req
            startwrite(http)
            write(http, req.response.body)
            s["http.status_code"] = string(resp.status)
            s["http.response_content_length"] = length(resp.body)
            HTTP_METRICS[](; route = name, status = Int(resp.status))
        end
    end
    nothing
end

type2segment(x) = ""
type2segment(x::Type{Val{S}}) where {S} = S
type2segment(x::Type{Any}) = "*"

function __init__()
    init()
end

end # module
