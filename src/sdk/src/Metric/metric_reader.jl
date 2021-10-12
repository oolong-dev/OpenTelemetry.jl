export AbstractMetricReader,
    MultiMetricReader,
    collect

abstract type AbstractMetricReader end

struct MultiMetricReader <: AbstractMetricReader
    readers::Vector{Any}
    function MultiMetricReader(readers...)
        new([readers...])
    end
end

Base.push!(mr::MultiMetricReader, r::AbstractMetricReader) = push!(mr.readers, r)

function collect(r::MultiMetricReader)
    for x in r.readers
        collect(x)
    end
end

function shut_down!(r::MultiMetricReader)
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
