module OpenTelemetryAPIHTTPExt

export otel_http_layer, otel_http_middleware

using OpenTelemetryAPI

if isdefined(Base, :get_extension)
    import HTTP
else
    import ..HTTP
end

# https://opentelemetry.io/docs/reference/specification/metrics/semantic_conventions/http-metrics/

struct HttpInstrument
    http_client_duration::Histogram{Float64}
    http_client_request_size::Histogram{Float64}
    http_client_response_size::Histogram{Float64}
    http_server_duration::Histogram{Float64}
    http_server_request_size::Histogram{Float64}
    http_server_response_size::Histogram{Float64}
    # TODO:  http.server.active_requests::UpDownCounter{Int}
end

function HttpInstrument()
    meter = Meter(
        "HTTP.jl";
        instrumentation_scope = InstrumentationScope(
            name = "HTTP.jl",
            version = get_pkg_version(HTTP),
            schema_url = "", # TODO: add link to doc
        ),
    )

    http_client_duration = Histogram{Float64}(
        "http.client.duration",
        meter;
        unit = "ms",
        description = "Measures the duration of outbound HTTP requests.",
    )

    http_client_request_size = Histogram{Float64}(
        "http.client.request.size",
        meter;
        unit = "By",
        description = "Measures the size of HTTP request messages (compressed).",
    )

    http_client_response_size = Histogram{Float64}(
        "http.client.response.size",
        meter;
        unit = "By",
        description = "Measures the size of HTTP response messages (compressed).",
    )

    http_server_duration = Histogram{Float64}(
        "http.server.duration",
        meter;
        unit = "ms",
        description = "Measures the duration of inbound HTTP requests.",
    )

    http_server_request_size = Histogram{Float64}(
        "http.server.request.size",
        meter;
        unit = "By",
        description = "Measures the size of HTTP request messages (compressed).",
    )

    http_server_response_size = Histogram{Float64}(
        "http.server.response.size",
        meter;
        unit = "By",
        description = "Measures the size of HTTP response messages (compressed).",
    )

    HttpInstrument(
        http_client_duration,
        http_client_request_size,
        http_client_response_size,
        http_server_duration,
        http_server_request_size,
        http_server_response_size,
    )
end

HTTP_INSTRUMENT = Ref{HttpInstrument}()

#####

extract_client_metric_attrs(req::HTTP.Request) = (;
    Symbol("http.flavor") => "$(req.version.major).$(req.version.minor)",
    Symbol("http.method") => req.method,
    Symbol("net.peer.name") => req.url.host,
    Symbol("net.peer.port") => req.url.port,
)

extract_server_metric_attrs(req::HTTP.Request) = (;
    Symbol("http.scheme") => req.url.scheme,
    Symbol("http.route") => something(HTTP.getroute(req), ""),
    Symbol("http.flavor") => "$(req.version.major).$(req.version.minor)",
    Symbol("http.method") => req.method,
    Symbol("net.host.name") => req.url.host,
    Symbol("net.host.port") => req.url.port,
)

extract_metric_attrs(resp::HTTP.Response) = (; Symbol("http.status_code") => resp.status)

extract_span_attrs_common(req::HTTP.Request) = (;
    Symbol("http.flavor") => "$(req.version.major).$(req.version.minor)",
    Symbol("http.method") => req.method,
    Symbol("user_agent.original") => HTTP.header(req.headers, "User-Agent", ""),
    Symbol("http.request_content_length") =>
        parse(Float64, HTTP.header(req.headers, "Content-Length", "0")),
)

extract_span_attrs_common(resp::HTTP.Response) = (;
    Symbol("http.status_code") => resp.status,
    Symbol("http.response_content_length") =>
        parse(Float64, HTTP.header(resp.headers, "Content-Length", "0")),
)

function otel_http_layer(h)
    function handler(req::HTTP.Request; kw...)
        if is_suppress_instrument()
            h(req; kw...)
        else
            ins = HTTP_INSTRUMENT[]
            ins.http_client_request_size(
                parse(Float64, HTTP.header(req.headers, "Content-Length", "0"));
                extract_client_metric_attrs(req)...,
            )
            duration = @elapsed resp = with_span(req.method; kind = SPAN_KIND_CLIENT) do
                s = current_span()
                s["http.url"] = string(req.url) # TODO: remove credentials
                s["net.peer.name"] = req.url.host
                s["net.peer.port"] = req.url.port
                # TODO: http.resend_count
                for (k, v) in pairs(extract_span_attrs_common(req))
                    s[string(k)] = v
                end
                inject_context!(req.headers)
                resp = h(req; kw...)
                for (k, v) in pairs(extract_span_attrs_common(resp))
                    s[string(k)] = v
                end
                resp
            end
            ins.http_client_duration(
                duration * 1000,  # the unit is ms
                merge(extract_client_metric_attrs(req), extract_metric_attrs(resp)),
            )
            ins.http_client_response_size(
                parse(Float64, HTTP.header(resp.headers, "Content-Length", "0")),
                merge(extract_client_metric_attrs(req), extract_metric_attrs(resp)),
            )
            resp
        end
    end
end

function otel_http_middleware(h)
    function handler(req::HTTP.Request; kw...)
        with_context(extract_context(req.headers)) do
            ins = HTTP_INSTRUMENT[]
            ins.http_server_request_size(
                parse(Float64, HTTP.header(req.headers, "Content-Length", "0")),
                extract_server_metric_attrs(req),
            )

            duration = @elapsed resp = with_span(req.method; kind = SPAN_KIND_SERVER) do
                s = current_span()
                s["http.route"] = something(HTTP.getroute(req), "")
                s["http.target"] = req.url.path
                s["http.scheme"] = req.url.scheme
                s["net.host.name"] = req.url.host # ??? https://opentelemetry.io/docs/reference/specification/trace/semantic_conventions/span-general/#nethostname
                s["net.host.port"] = req.url.port # ???
                # ??? s["http.client_ip"]
                for (k, v) in pairs(extract_span_attrs_common(req))
                    s[string(k)] = v
                end
                resp = h(req; kw...)
                for (k, v) in pairs(extract_span_attrs_common(resp))
                    s[string(k)] = v
                end
                resp
            end

            ins.http_server_duration(
                duration * 1000, # the unit is ms
                merge(extract_server_metric_attrs(req), extract_metric_attrs(resp)),
            )
            ins.http_server_response_size(
                parse(Float64, HTTP.header(resp.headers, "Content-Length", "0")),
                merge(extract_server_metric_attrs(req), extract_metric_attrs(resp)),
            )
            resp
        end
    end
end

function OpenTelemetryAPI.instrument!(::Val{:HTTP})
    uninstrument!(Val(:HTTP))  # !!! avoid repeated instrumentation
    HTTP_INSTRUMENT[] = HttpInstrument()
    HTTP.pushlayer!(otel_http_layer; request = true)
    otel_http_layer, otel_http_middleware
end

function OpenTelemetryAPI.uninstrument!(::Val{:HTTP})
    deleteat!(
        HTTP.REQUEST_LAYERS,
        [
            i for
            i in 1:length(HTTP.REQUEST_LAYERS) if HTTP.REQUEST_LAYERS[i] === otel_http_layer
        ],
    )
end

function __init__()
    println("$(@__MODULE__) is loaded!")
end

end