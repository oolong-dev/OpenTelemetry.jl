export DummyExporter,
    InMemoryExporter, ConsoleExporter, EXPORT_SUCCESS, EXPORT_FAILURE, export!

@enum ExportResult begin
    EXPORT_SUCCESS
    EXPORT_FAILURE
end

"""
An `AbstractExporter` is to export a collection of [`AbstractSpan`](@ref)s and
(or) [`Metric`](@ref)s. Each method should have the following interfaces
implemented:

  - [`flush(::AbstractExporter)`](@ref)
  - [`close(::AbstractExporter)`](@ref)
  - [`export!(::AbstractExporter, collection)`](@ref)
"""
abstract type AbstractExporter end

Base.flush(::AbstractExporter) = true

Base.close(e::AbstractExporter) = flush(e)

#####

struct DummyExporter <: AbstractExporter end
export!(e::DummyExporter, xs) = nothing

#####

"""
    InMemoryExporter(;pool=[], is_closed=false)

Simply store all `export!`ed elements into the `pool`.
"""
Base.@kwdef mutable struct InMemoryExporter <: AbstractExporter
    pool::Vector = []
    is_closed::Bool = false # mutable
end

Base.show(io::IO, e::InMemoryExporter) =
    print(io, "InMemoryExporter with $(length(e.pool)) elements")
Base.empty!(se::InMemoryExporter) = empty!(se.pool)
Base.length(se::InMemoryExporter) = length(se.pool)
Base.iterate(e::InMemoryExporter, args...) = iterate(e.pool, args...)

function Base.close(se::InMemoryExporter)
    flush(se)
    se.is_closed = true
    true
end

function export!(e::InMemoryExporter, xs)
    if e.is_closed
        EXPORT_FAILURE
    else
        append!(e.pool, xs)
        EXPORT_SUCCESS
    end
end

#####

"""
    ConsoleExporter(;io=stdout)

Print an [`AbstractSpan`](@ref) or [`Metric`](@ref) into `io`.
"""
Base.@kwdef struct ConsoleExporter <: AbstractExporter
    io::IO = stdout
end

function export!(ce::ConsoleExporter, batch)
    for x in batch
        print(ce.io, x)
    end
    EXPORT_SUCCESS
end

#####

mutable struct BatchContainer{T}
    container::Vector{T}
    start::Int
    count::Int
    batch_size::Int
end

BatchContainer(container, batch_size) =
    BatchContainer(container, 1, 0, batch_size)

function Base.put!(c::BatchContainer{T}, x::T) where {T}
    if c.count < length(c.container)
        c.count += 1
        i = mod1(c.start + c.count - 1, length(c.container))
        c.container[i] = x
    else
        # dropped
    end
    c.count >= c.batch_size
end

function Base.take!(c::BatchContainer)
    n = min(c.batch_size, c.count)
    batch = similar(c.container, n)
    for i in 1:n
        ii = mod1(c.start + i - 1, length(c.container))
        batch[i] = c.container[ii]
    end
    c.start = mod1(c.start + n, length(c.container))
    c.count -= n
    batch
end
