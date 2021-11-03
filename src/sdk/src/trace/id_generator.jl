export RandomIdGenerator

using Random

"""
Customized id generators must implement the following two methods:

  - `generate_span_id(::AbstractIdGenerator)`
  - `generate_trace_id(::AbstractIdGenerator)`
"""
abstract type AbstractIdGenerator end

"""
    RandomIdGenerator(rng=Random.GLOBAL_RNG)

Use the `rng` to generate a random trace id or span id.
"""
Base.@kwdef struct RandomIdGenerator{R} <: AbstractIdGenerator
    rng::R = Random.GLOBAL_RNG
end

generate_trace_id(rng::RandomIdGenerator) = rand(rng.rng, TraceIdType)
generate_span_id(rng::RandomIdGenerator) = rand(rng.rng, SpanIdType)
