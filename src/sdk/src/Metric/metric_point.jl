@enum Temporality begin
    CUMULATIVE
    DELTA
end

abstract type AbstractAggregation end

struct DefaultAgg <: AbstractAggregation
end

struct DropAgg <: AbstractAggregation
end

struct SumAgg <: AbstractAggregation
end

struct LastValueAgg <: AbstractAggregation
end

struct HistogramAgg <: AbstractAggregation
end

struct Metric{A<:AbstractAggregation, T, Ins<:AbstractInstrument{T}}
    instrument::Ins
    points::Dict{Attributes, T}
    aggregation::A
end

#####