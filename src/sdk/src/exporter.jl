export AbstractExporter,
    InMemoryExporter,
    ConsoleExporter,
    EXPORT_SUCCESS,
    EXPORT_FAILURE,
    export!,
    shut_down!,
    force_flush!

using GarishPrint: pprint

@enum ExportResult begin
    EXPORT_SUCCESS
    EXPORT_FAILURE
end

abstract type AbstractExporter end

function export!(e::AbstractExporter, batch::AbstractVector)
    res = EXPORT_SUCCESS
    for x in batch
        r = export!(e, x)
        if r === EXPORT_FAILURE
            res = EXPORT_FAILURE
        end
    end
    res
end

function force_flush!(::AbstractExporter) true end

shut_down!(e::AbstractExporter) = force_flush!(e)

#####

Base.@kwdef struct InMemoryExporter <: AbstractExporter
    pool::Vector = []
    is_shut_down::Ref{Bool} = Ref(false)
end

Base.empty!(se::InMemoryExporter) = empty!(se.pool)

function force_flush!(se::InMemoryExporter)
    empty!(se)
    true
end

function shut_down!(se::InMemoryExporter)
    force_flush!(se)
    se.is_shut_down[] = true
    true
end

function export!(e::InMemoryExporter, x)
    if e.is_shut_down[]
        EXPORT_FAILURE
    else
        push!(e.pool, x)
        EXPORT_SUCCESS
    end
end

#####

Base.@kwdef struct ConsoleExporter <: AbstractExporter
    io::IO = stdout
end

function export!(ce::ConsoleExporter, x)
    pprint(ce.io, x)
    println(ce.io)
    EXPORT_SUCCESS
end
