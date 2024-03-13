module OpenTelemetryExporterPrometheus

export PrometheusExporter

using OpenTelemetrySDK
using HTTP

function handler(io, provider::Ref{MeterProvider}, resource_to_telemetry_conversion)
    for ins in provider[].async_instruments
        ins()
    end
    HTTP.setstatus(io, 200)
    HTTP.setheader(io, "Content-Type" => "text/plain")
    HTTP.startwrite(io)
    text_based_format(io, provider[], resource_to_telemetry_conversion)
    nothing
end

"""
    PrometheusExporter(; kw...)

## Keyword arguments

  - `host`, the default value is read from the `OTEL_EXPORTER_PROMETHEUS_HOST` environment variable.
  - `port`, the default value is read from the `OTEL_EXPORTER_PROMETHEUS_PORT` environment variable.
  - `resource_to_telemetry_conversion=false`, if enabled, all the resource attributes will be converted to metric labels by default.
  - `path="/metrics"`, the default url path.

## Usage

```julia
r = MetricReader(PrometheusExporter())
```

Note that `PrometheusExporter` is a pull based exporter. There's no need to execute `r()` to update the metrics.
"""
mutable struct PrometheusExporter <: OpenTelemetrySDK.AbstractExporter
    server::HTTP.Servers.Server
    provider::Ref{MeterProvider}
    function PrometheusExporter(;
        host = OTEL_EXPORTER_PROMETHEUS_HOST(),
        port = OTEL_EXPORTER_PROMETHEUS_PORT(),
        resource_to_telemetry_conversion = false,
        path = "/metrics",
        kw...,
    )
        provider = Ref{MeterProvider}()

        router = HTTP.Router()
        HTTP.register!(
            router,
            "GET",
            path,
            io -> handler(io, provider, resource_to_telemetry_conversion),
        )
        server = HTTP.serve!(router, host, port; stream = true, kw...)

        new(server, provider)
    end
end

Base.close(r::PrometheusExporter) = close(r.server)

function (r::MetricReader{<:MeterProvider,<:PrometheusExporter})()
    if isassigned(r.exporter.provider)
        @info "The prometheus exporter is already properly set!"
    else
        r.exporter.provider[] = r.provider
    end
end

#####

export PrometheusPushgatewayExporter

using URIs
using Base64

struct PrometheusPushgatewayExporter <: OpenTelemetrySDK.AbstractExporter
    headers::HTTP.Headers
    endpoint::URI
    resource_to_telemetry_conversion::Bool
end

# https://prometheus.io/docs/prometheus/latest/storage/#overview
function PrometheusPushgatewayExporter(;
    scheme = "http",
    host = "localhost",
    port = 9091,
    headers = HTTP.Headers[],
    resource_to_telemetry_conversion = false,
)
    endpoint = URI(; scheme, host, port)
    PrometheusPushgatewayExporter(headers, endpoint, resource_to_telemetry_conversion)
end

function (r::MetricReader{<:MeterProvider,<:PrometheusPushgatewayExporter})()
    job_name = OTEL_SERVICE_NAME()
    path = "metrics/job/$(job_name)"

    if r.exporter.resource_to_telemetry_conversion
        for (k, v) in pairs(OTEL_RESOURCE_ATTRIBUTES())
            k = sanitize(k)
            if isempty(v)
                k = "$(k)@base64"
                v = "="
            elseif '/' in v
                k = "$(k)@base64"
                v = base64encode(v)
            end
            path = joinpath(path, "$k/$v")
        end
    end

    url = joinpath(r.exporter.endpoint, path)

    body = IOBuffer()
    text_based_format(body, r.provider, false; with_timestamp = false)
    seek(body, 0)

    HTTP.request("PUT", url, r.exporter.headers, body)
end
#####

# TODO: support exemplars
function text_based_format(
    io,
    provider::MeterProvider,
    resource_to_telemetry_conversion;
    with_timestamp = true,
)
    for m in metrics(provider)
        name = sanitize(m.name)
        write(io, "# HELP $name $(m.description)\n")
        write(io, "# TYPE $name $(prometheus_type(m.aggregation))\n")
        for (attrs, point) in m
            if resource_to_telemetry_conversion
                attrs = merge(attrs, resource(provider).attributes)
            end

            val = point.value
            time = point.time_unix_nano ÷ 10^6
            s_attrs = attrs2str(attrs)
            wrapped_s_attrs = length(attrs) == 0 ? "" : "{$s_attrs}"

            if point.value isa OpenTelemetrySDK.HistogramValue
                if !isempty(s_attrs)
                    s_attrs = "$s_attrs,"
                end
                for (i, c) in enumerate(Iterators.accumulate(+, val.counts))
                    if i < length(val.counts)
                        write(
                            io,
                            "$(name)_bucket{$(s_attrs)le=\"$(val.boundaries[i])\"} $c",
                        )
                        with_timestamp && write(io, " $time")
                        write(io, "\n")
                    else
                        write(io, "$(name)_bucket{$(s_attrs)le=\"+Inf\"} $c")
                        with_timestamp && write(io, " $time")
                        write(io, "\n")
                        write(io, "$(name)_count$wrapped_s_attrs $c")
                        with_timestamp && write(io, " $time")
                        write(io, "\n")
                    end
                end
                # ???
                if !isnothing(val.sum)
                    write(io, "$(name)_sum$wrapped_s_attrs $(val.sum)")
                    with_timestamp && write(io, " $time")
                    write(io, "\n")
                end
            else
                write(io, "$name$wrapped_s_attrs $val")
                with_timestamp && write(io, " $time")
                write(io, "\n")
            end
        end
        write(io, "\n")
    end
end

prometheus_type(::SumAgg) = "counter"
prometheus_type(::LastValueAgg) = "gauge"
prometheus_type(::HistogramAgg) = "histogram"

sanitize(s::Symbol) = sanitize(string(s))
sanitize(s) = replace(s, r"[^\w]" => "_")

attrs2str(attrs) = join(("$(sanitize(k))=\"$v\"" for (k, v) in pairs(attrs)), ",")

end # module
