export AbstractExporter,
    InMemoryExporter,
    ConsoleExporter,
    SUCCESS,
    FAILURE,
    export!,
    shut_down!,
    force_flush!

using GarishPrint: pprint

@enum ExportResult begin
    SUCCESS
    FAILURE
end

abstract type AbstractExporter end

function export!(e::AbstractExporter, batch::AbstractVector)
    res = SUCCESS
    for x in batch
        r = export!(e, x)
        if r === FAILURE
            res = FAILURE
        end
    end
    res
end

function force_flush!(::AbstractExporter) end
function shut_down!(::AbstractExporter) end

#####

Base.@kwdef struct InMemoryExporter <: AbstractExporter
    finished_spans::Vector = []
    is_shut_down::Ref{Bool} = Ref(false)
end

Base.empty!(se::InMemoryExporter) = empty!(se.finished_spans)

shut_down!(se::InMemoryExporter) = se.is_shut_down[] = true

function export!(e::InMemoryExporter, x)
    if e.is_shut_down[]
        FAILURE
    else
        push!(e.finished_spans, x)
        SUCCESS
    end
end

#####

Base.@kwdef struct ConsoleExporter <: AbstractSpanExporter
    io::IO = stdout
end

function export!(ce::ConsoleExporter, x)
    pprint(ce.io, x)
    println(ce.io)
    SUCCESS
end
