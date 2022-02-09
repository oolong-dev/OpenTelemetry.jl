export AbstractExporter,
    InMemoryExporter,
    ConsoleExporter,
    EXPORT_SUCCESS,
    EXPORT_FAILURE,
    export!,
    shut_down!,
    force_flush!

@enum ExportResult begin
    EXPORT_SUCCESS
    EXPORT_FAILURE
end

"""
An `AbstractExporter` is to export a collection of [`AbstractSpan`](@ref)s and
(or) [`Metric`](@ref)s. Each method should have the following interfaces
implemented:

  - [`force_flush!(::AbstractExporter)`](@ref)
  - [`shut_down!(::AbstractExporter)`](@ref)
  - [`export!(::AbstractExporter, collection)`](@ref)
"""
abstract type AbstractExporter end

force_flush!(::AbstractExporter) = true

shut_down!(e::AbstractExporter) = force_flush!(e)

#####

"""
    InMemoryExporter(;pool=[], is_shut_down=Ref(false))

Simply store all `export!`ed elements into the `pool`.
"""
Base.@kwdef struct InMemoryExporter <: AbstractExporter
    pool::Vector = []
    is_shut_down::Ref{Bool} = Ref(false)
end

Base.show(io::IO, e::InMemoryExporter) =
    print(io, "InMemoryExporter with $(length(e.pool)) elements")
Base.empty!(se::InMemoryExporter) = empty!(se.pool)
Base.length(se::InMemoryExporter) = length(se.pool)
Base.iterate(e::InMemoryExporter, args...) = iterate(e.pool, args...)

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
        append!(e.pool, x)
        EXPORT_SUCCESS
    end
end

#####

"""
    ConsoleExporter(;io=stdout)

Print [`Span`](@ref) or [`Metric`](@ref) into `io`.
"""
Base.@kwdef struct ConsoleExporter <: AbstractExporter
    io::IO = stdout
end

function export!(ce::ConsoleExporter, batch)
    for x in batch
        pprint(ce.io, x)
        println(ce.io)
        print(ce.io, repeat("-", displaysize(ce.io)[2]))
        println(ce.io)
    end
    EXPORT_SUCCESS
end
