export AbstractMetricReader,
    CompositMetricReader,
    MetricReader,
    PeriodicMetricReader

abstract type AbstractMetricReader end

struct CompositMetricReader <: AbstractMetricReader
    readers::Vector{Any}
    function CompositMetricReader(readers...)
        new([readers...])
    end
end

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

struct MetricReader{P,E} <: AbstractMetricReader
    provider::P
    exporter::E
    function MetricReader(; provider::P, exporter::E) where {P,E}
        r = new{P,E}(provider, exporter)
        r()
        r
    end
end

function (r::MetricReader)()
    for ins in keys(r.provider.async_instruments)
        ins()
    end
    export!(r.exporter, (m => d for m in values(r.provider.metrics) for d in m.aggregation.agg_store.unique_points))
end

# ??? shut_down! provider?
shut_down!(r::MetricReader) = shut_down!(r.exporter)

#####

struct PeriodicMetricReader{R<:AbstractMetricReader} <: AbstractMetricReader
    reader::R
    export_interval_seconds::Int
    export_timeout_seconds::Int
    timer::Timer
    function PeriodicMetricReader(
        reader;
        export_interval_seconds = 60,
        export_timeout_seconds = 30
    )
        timer = Timer(0; interval = export_interval_seconds) do t
            res = timedwait(export_timeout_seconds; pollint = 1) do
                reader()
                true
            end
            if res == :timed_out
                @warn "timed out when exporting metrics"
                # how to stop exporting?
            end
        end

        new{typeof(reader)}(
            reader,
            export_interval_seconds,
            export_timeout_seconds,
            timer,
        )
    end
end

function shut_down!(r::PeriodicMetricReader)
    close(r.timer)
    shut_down!(r.reader)
end