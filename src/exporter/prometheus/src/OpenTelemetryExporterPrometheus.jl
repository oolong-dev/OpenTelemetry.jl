module OpenTelemetryExporterPrometheus

using OpenTelemetrySDK
using Sockets

mutable struct PrometheusExporter <: AbstractExporter
    server::Sockets.TCPServer
    provider::Union{MeterProvider,Nothing}
    function PrometheusExporter(; host = "127.0.0.1", port = 9966, kw...)
        server = Sockets.listen(Sockets.InetAddr(parse(IPAddr, host), port))
        exporter = new(server, nothing)
        @async HTTP.listen(host, port; server = server, kw...) do http
            HTTP.setstatus(http, 200)
            HTTP.setheader(http, "Content-Type" => "text/plain")

            for ins in r.provider.async_instruments
                ins()
            end
            if isnothing(exporter.provider)
                write(http, "MeterProvider is not set yet!!!")
            else
                text_based_format(http, provider)
            end
        end
        exporter
    end
end

function (r::MetricReader{<:MeterProvider,<:PrometheusExporter})()
    if isnothing(r.exporter.provider)
        r.exporter.provider = r.provider
    else
        @info "The prometheus exporter is already properly set!"
    end
end

# TODO: support exemplars
function text_based_format(io, provider::MeterProvider)
    for m in values(provider.metrics)
        write(io, "# HELP $(m.name) $(m.description)")
        write(io, "# TYPE $(m.name) $(prometheus_type(m.aggregation))")
        for (attrs, point) in m.aggregation.agg_store.unique_points
            if point isa DataPoint{<:OpenTelemetrySDK.HistogramValue}
                val = point.value
                for (i, c) in enumerate(Iterators.accumulate(+, val.counts))
                    if i == length(val.counts)
                        write(io, "$(m.name)_bucket{le=\"+Inf\"} $c")
                        write(io, "$(m.name)_count $c")
                    else
                        write(io, "$(m.name)_bucket{le=\"$(point.boundaries[i])\"} $c")
                    end
                end
                # ???
                if !isnothing(point.sum)
                    write(io, "$(m.name)_sum $(point.sum)")
                end
            else
                write(io, "$(m.name){")
                # TODO: escape
                join(io, ("$k=\"$v\"" for (k, v) in pairs(attrs)), ",")
                write(io, "} $(point.value) $(point.time_unix_nano) \n")
            end
        end
        write(io, "\n")
    end
end

prometheus_type(::SumAgg) = "counter"
prometheus_type(::LastValueAgg) = "gauge"
prometheus_type(::HistogramAgg) = "histogram"

end # module
