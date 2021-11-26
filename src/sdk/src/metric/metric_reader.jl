export AbstractMetricReader,
    CompositMetricReader,
    MetricReader

abstract type AbstractMetricReader end

struct CompositMetricReader <: AbstractMetricReader
    readers::Vector{Any}
    function CompositMetricReader(readers...)
        new([readers...])
    end
end

Base.push!(mr::CompositMetricReader, r::AbstractMetricReader) = push!(mr.readers, r)

function (r::CompositMetricReader)()
    for x in r.readers
        x()
    end
end

function shut_down!(r::CompositMetricReader)
    for x in r.readers
        shut_down!(x)
    end
end

#####

Base.@kwdef struct MetricReader{P<:MeterProvider,E} <: AbstractMetricReader
    provider::P
    exporter::E
end

function (r::MetricReader)()
    for ins in r.provider.async_instruments
        ins()
    end
    export!(r.exporter, (d for m in values(r.provider.metrics) for d in m.aggregation.agg_store.unique_points))
end

#####

struct PeriodicMetricReader <: AbstractMetricReader
    reader::MetricReader
    export_interval_seconds::Int
    export_timeout_seconds::Int
    timer::Timer
    function PeriodicMetricReader(
        reader;
        export_interval_seconds = 60,
        export_timeout_seconds = 30,
    )
        timer = Timer(0;interval=export_interval_seconds) do t
            res = timedwait(export_timeout_seconds;pollint=1) do
                reader()
                true
            end
            if res == :timed_out
                @warn "timed out when exporting metrics"
                # how to stop exporting?
            end
        end

        new(
            reader,
            export_interval_seconds,
            export_timeout_seconds,
            timer,
        )
    end
end
