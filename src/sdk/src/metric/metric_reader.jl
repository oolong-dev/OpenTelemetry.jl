export AbstractMetricReader,
    CompositMetricReader,
    collect

abstract type AbstractMetricReader end

struct CompositMetricReader <: AbstractMetricReader
    readers::Vector{Any}
    function CompositMetricReader(readers...)
        new([readers...])
    end
end

Base.push!(mr::CompositMetricReader, r::AbstractMetricReader) = push!(mr.readers, r)

function collect(r::CompositMetricReader)
    for x in r.readers
        collect(x)
    end
end

function shut_down!(r::CompositMetricReader)
    for x in r.readers
        shut_down!(x)
    end
end

#####

struct PeriodicExportingMetricReader{E<:AbstractExporter}
    exporter::E
    export_interval_milliseconds::Int
    export_timeout_milliseconds::Int
end

PeriodicExportingMetricReader(
    e;
    export_interval_milliseconds=60_000,
    export_timeout_milliseconds=30_000
) = PeriodicExportingMetricReader(
    e,
    export_interval_milliseconds,
    export_timeout_milliseconds
)
