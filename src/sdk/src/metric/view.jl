abstract type AbstractAggregation end

struct Reservoir{T,R}
    pool::Vector{T}
    size::Int
    rng::R
end
