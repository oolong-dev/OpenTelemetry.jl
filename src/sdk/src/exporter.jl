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
    max_queue_size::Int
    start::Int
    count::Int
    batch_size::Int
    lock::ReentrantLock
end

function BatchContainer{T}(max_queue_size::Int, batch_size::Int) where T
    return BatchContainer{T}(
        Vector{T}(undef, max_queue_size), 
        max_queue_size, 
        1, 
        0, 
        batch_size,  
        ReentrantLock()
    )
end

function Base.put!(c::BatchContainer{T}, x::T) where {T}
    lock(c.lock) do
        if c.count < c.max_queue_size
            c.count += 1
            i = mod1(c.start + c.count - 1, c.max_queue_size)
            c.container[i] = x
        else
            # dropped
        end
        return c.count >= c.batch_size 
        # returns condition to export: queue contains at least maxExportBatchSize elements
    end
end

function Base.take!(c::BatchContainer)
    lock(c.lock) do
        n = min(c.batch_size, c.count)
        batch = similar(c.container, n)
        for i in 1:n
            ii = mod1(c.start + i - 1, c.max_queue_size)
            batch[i] = c.container[ii]
        end
        c.start = mod1(c.start + n, c.max_queue_size)
        c.count -= n
        return batch
    end
end
