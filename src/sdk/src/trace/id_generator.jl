export RandomIdGenerator

using Random

abstract type AbstractIdGenerator end

Base.@kwdef struct RandomIdGenerator{R} <: AbstractIdGenerator
    rng::R = Random.GLOBAL_RNG
end

Base.rand(g::RandomIdGenerator, T) = rand(g.rng, T)

generate_trace_id(rng::RandomIdGenerator) = rand(rng.rng, API.TraceIdType)
generate_span_id(rng::RandomIdGenerator) = rand(rng.rng, API.SpanIdType)
