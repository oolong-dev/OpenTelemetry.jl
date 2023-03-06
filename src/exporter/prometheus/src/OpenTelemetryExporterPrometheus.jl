module OpenTelemetryExporterPrometheus

export PrometheusExporter

using OpenTelemetrySDK
using HTTP

"""
    PrometheusExporter(; host = "127.0.0.1", port = 9966, kw...)

It will setup a http server configured by `host` and `port` on initialization.
Here the extra keyword arguments `kw` will be forwarded to `HTTP.listen`.

## Usage

```julia
r = MetricReader(PrometheusExporter())
```

Note that `PrometheusExporter` is a pull based exporter. There's no need to execute `r()` to update the metrics.
"""
struct PrometheusExporter <: OpenTelemetrySDK.AbstractExporter
    server::HTTP.Servers.Server
    provider::Ref{MeterProvider}
    function PrometheusExporter(; host = nothing, port = nothing, kw...)
        host = something(host, OTEL_EXPORTER_PROMETHEUS_HOST())
        port = something(port, OTEL_EXPORTER_PROMETHEUS_PORT())
        provider = Ref{MeterProvider}()
        server = HTTP.serve!(host, port; stream = true, kw...) do io
            for ins in provider[].async_instruments
                ins()
            end
            text_based_format(io, provider[])
            HTTP.setstatus(io, 200)
            HTTP.setheader(io, "Content-Type" => "text/plain")
        end

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

attrs2str(attrs) = join(("$k=\"$v\"" for (k, v) in pairs(attrs)), ",")

# TODO: support exemplars
function text_based_format(io, provider::MeterProvider)
    for m in metrics(provider)
        write(io, "# HELP $(m.name) $(m.description)\n")
        write(io, "# TYPE $(m.name) $(prometheus_type(m.aggregation))\n")
        for (attrs, point) in m
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
                            "$(m.name)_bucket{$(s_attrs)le=\"$(val.boundaries[i])\"} $c $time",
                        )
                    else
                        println(io, "$(m.name)_bucket{$(s_attrs)le=\"+Inf\"} $c $time")
                        println(io, "$(m.name)_count$wrapped_s_attrs $c")
                    end
                end
                # ???
                if !isnothing(val.sum)
                    println(io, "$(m.name)_sum$wrapped_s_attrs $(val.sum) $time")
                end
            else
                println(io, "$(m.name)$(wrapped_s_attrs) $val $time")
            end
        end
        write(io, "\n")
    end
end

prometheus_type(::SumAgg) = "counter"
prometheus_type(::LastValueAgg) = "gauge"
prometheus_type(::HistogramAgg) = "histogram"

end # module
