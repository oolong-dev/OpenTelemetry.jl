module OpenTelemetryExporterPrometheus

export PrometheusExporter

using OpenTelemetrySDK
using HTTP

function handler(io, provider_ref::Ref{MeterProvider}, resource_to_telemetry_conversion)
    for ins in provider_ref[].async_instruments
        ins()
    end
    HTTP.setstatus(io, 200)
    HTTP.setheader(io, "Content-Type" => "text/plain")
    HTTP.startwrite(io)
    text_based_format(io, provider_ref[], resource_to_telemetry_conversion)
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
struct PrometheusExporter <: OpenTelemetrySDK.AbstractExporter
    server::HTTP.Servers.Server
    provider::Ref{MeterProvider}
    function PrometheusExporter(;
        host = nothing,
        port = nothing,
        resource_to_telemetry_conversion = false,
        path = "/metrics",
        kw...,
    )
        provider_ref = Ref{MeterProvider}()

        host = something(host, OTEL_EXPORTER_PROMETHEUS_HOST())
        port = something(port, OTEL_EXPORTER_PROMETHEUS_PORT())
        router = HTTP.Router()
        HTTP.register!(
            router,
            "GET",
            path,
            io -> handler(io, provider_ref, resource_to_telemetry_conversion),
        )
        server = HTTP.serve!(router, host, port; stream = true, kw...)

        new(server, provider_ref)
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

# TODO: support exemplars
function text_based_format(io, provider::MeterProvider, resource_to_telemetry_conversion)
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
                        println(
                            io,
                            "$(name)_bucket{$(s_attrs)le=\"$(val.boundaries[i])\"} $c $time",
                        )
                    else
                        println(io, "$(name)_bucket{$(s_attrs)le=\"+Inf\"} $c $time")
                        println(io, "$(name)_count$wrapped_s_attrs $c")
                    end
                end
                # ???
                if !isnothing(val.sum)
                    println(io, "$(name)_sum$wrapped_s_attrs $(val.sum) $time")
                end
            else
                println(io, "$name$wrapped_s_attrs $val $time")
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
