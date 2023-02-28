export AbstractMetricReader, CompositMetricReader, MetricReader, PeriodicMetricReader

"""
All metric readers should implement `close(::AbstractMetricReader)` and `(r::AbstractMetricReader)()`.

Builtin readers:

  - [`CompositMetricReader`](@ref)
  - [`MetricReader`](@ref)
  - [`PeriodicMetricReader`](@ref)
"""
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

function Base.close(r::CompositMetricReader)
    for x in r.readers
        close(x)
    end
end

#####

"""
    MetricReader([global_meter_provider()], [ConsoleExporter()])

Note that all metrics will be read on initialization.
"""
struct MetricReader{P,E} <: AbstractMetricReader
    provider::P
    exporter::E
    function MetricReader(
        provider::P,
        exporter::E,
    ) where {P<:OpenTelemetryAPI.AbstractMeterProvider,E<:AbstractExporter}
        r = new{P,E}(provider, exporter)
        r()
        r
    end
end

MetricReader(p::OpenTelemetryAPI.AbstractMeterProvider) = MetricReader(p, ConsoleExporter())
MetricReader(e::AbstractExporter) = MetricReader(global_meter_provider(), e)
MetricReader() = MetricReader(global_meter_provider(), ConsoleExporter())

"""
    (r::MetricReader)()

For async instruments in `r`, their callbacks will be executed first before reading all the metrics.
"""
function (r::MetricReader)()
    for ins in r.provider.async_instruments
        ins()
    end
    export!(r.exporter, metrics(r.provider))
end

# ??? close provider?
Base.close(r::MetricReader) = close(r.exporter)

#####

"""
    PeriodicMetricReader(reader; export_interval_seconds = 60, export_timeout_seconds = 30)

Periodically call the `reader` in the background.
"""
struct PeriodicMetricReader{R<:AbstractMetricReader} <: AbstractMetricReader
    reader::R
    export_interval_seconds::Int
    export_timeout_seconds::Int
    timer::Timer
    function PeriodicMetricReader(
        reader;
        export_interval_seconds = 60,
        export_timeout_seconds = 30,
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

        new{typeof(reader)}(reader, export_interval_seconds, export_timeout_seconds, timer)
    end
end

"""
For `PeriodicMetricReader`, there's no need to call this method since the read
operation will be done periodically in the background.
"""
function (r::PeriodicMetricReader)() end

function Base.close(r::PeriodicMetricReader)
    close(r.timer)
    close(r.reader)
end
