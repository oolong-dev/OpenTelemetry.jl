export Exemplar,
    SumAgg,
    LastValueAgg,
    HistogramAgg,
    DROP

using Base.Threads

const N_MAX_POINTS_PER_METRIC = 2_000

#####

Base.@kwdef struct Exemplar{T}
    value::T
    time_unix_nano::UInt
    filtered_attributes::StaticAttrs
    trace_id::TraceIdType
    span_id::SpanIdType
end

abstract type AbstractExemplarReservoir end

# TODO
struct SimpleFixedSizeExemplarReservoir <: AbstractExemplarReservoir end

# TODO
struct AlignedHistogramBucketExemplarReservoir <: AbstractExemplarReservoir end

#####

mutable struct DataPoint{T,E}
    @atomic value::T
    start_time_unix_nano::UInt
    time_unix_nano::UInt
    exemplar_reservoir::E
end

function DataPoint{T}(exemplar_reservoir=nothing) where {T}
    t = UInt(time() * 10^9)
    DataPoint(zero(T), t, t, exemplar_reservoir)
end

struct AggregationStore{D<:DataPoint}
    points::Dict{StaticAttrs,D}
    unique_points::Dict{StaticAttrs,D}
    n_max_points::UInt
    n_max_attrs::UInt
    lock::ReentrantLock
end

function AggregationStore{D}(
    ; n_max_points = N_MAX_POINTS_PER_METRIC,
    n_max_attrs = 2 * N_MAX_POINTS_PER_METRIC
) where {D}
    AggregationStore{D}(
        Dict{StaticAttrs,D}(),
        Dict{StaticAttrs,D}(),
        UInt(n_max_points),
        UInt(n_max_attrs),
        ReentrantLock()
    )
end

function Base.get!(f, agg::AggregationStore, attrs)
    point = get(agg.points, attrs, nothing)
    if isnothing(point)
        sorted_attrs = sort(attrs)
        point = get(agg.points, sorted_attrs, nothing)
        if isnothing(point)
            if length(agg.unique_points) < agg.n_max_points
                lock(agg.lock) do
                    if haskey(agg.points, attrs)
                        agg.points[attrs]
                    elseif haskey(agg.points, sorted_attrs)
                        agg.points[sorted_attrs]
                    else
                        p = f()
                        agg.points[attrs] = p
                        agg.points[sorted_attrs] = p
                        agg.unique_points[sorted_attrs] = p
                        p
                    end
                end
            else
                @warn "maximum number of attributes reached, dropped."
                nothing
            end
        else
            if length(agg.points) < agg.n_max_attrs
                agg.points[attrs] = point
            else
                @warn "maximum cached keys in agg store reached, please consider increase `n_max_points`"
            end
            point
        end
    else
        point
    end
end

#####

abstract type AbstractAggregation end

struct SumAgg{T,E,F} <: AbstractAggregation
    agg_store::AggregationStore{DataPoint{T,E}}
    exemplar_reservoir_factory::F
end

SumAgg{T}() where {T} = SumAgg(AggregationStore{DataPoint{T,Nothing}}(), () -> nothing)

function (agg::SumAgg{T,E})(e::Exemplar{<:Measurement}) where {T,E}
    point = get!(agg.agg_store, e.value.attributes) do
        DataPoint{T}(agg.exemplar_reservoir_factory())
    end
    if !isnothing(point)
        @atomic point.value += e.value.value
        point.time_unix_nano = e.time_unix_nano
    end
end

#####

struct LastValueAgg{T,E,F} <: AbstractAggregation
    agg_store::AggregationStore{DataPoint{T,E}}
    exemplar_reservoir_factory::F
end

LastValueAgg{T}() where {T} = LastValueAgg(AggregationStore{DataPoint{T,Nothing}}(), () -> nothing)

function (agg::LastValueAgg{T,E})(e::Exemplar{<:Measurement}) where {T,E}
    point = get!(agg.agg_store, e.value.attributes) do
        DataPoint{T}(agg.exemplar_reservoir_factory())
    end
    if !isnothing(point)
        @atomic point.value = e.value.value
    end
end

#####

const DEFAULT_HISTOGRAM_BOUNDARIES = (0.0, 5.0, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0, 500.0, 1000.0)

struct HistogramValue{T,M,N}
    boundaries::NTuple{M,Float64}
    counts::NTuple{N,UInt}
    sum::Union{T,Nothing}
    min::Union{T,Nothing}
    max::Union{T,Nothing}
end

function HistogramValue{T}(;
    boundaries = DEFAULT_HISTOGRAM_BOUNDARIES,
    is_record_sum = true,
    is_record_min = true,
    is_record_max = true
) where {T}
    M = length(boundaries)
    N = M + 1
    HistogramValue{T,M,N}(
        boundaries,
        ntuple(i -> UInt(0), N),
        is_record_sum ? zero(T) : nothing,
        is_record_min ? typemax(T) : nothing,
        is_record_max ? typemin(T) : nothing,
    )
end

function Base.:(+)(v::HistogramValue, x)
    n = 0
    for (i, b) in enumerate(v.boundaries)
        if x <= b
            n = i
            break
        end
    end
    if n == 0
        n = length(v.boundaries) + 1
    end

    HistogramValue(
        v.boundaries,
        (v.counts[1:n-1]..., v.counts[n] + UInt(1), v.counts[n+1:end]...),
        v.sum + x,
        isnothing(v.min) ? nothing : min(v.min, x),
        isnothing(v.max) ? nothing : max(v.max, x),
    )
end

struct HistogramAgg{T,E,F,M,N} <: AbstractAggregation
    boundaries::NTuple{M,Float64}
    is_record_min::Bool
    is_record_max::Bool
    agg_store::AggregationStore{DataPoint{HistogramValue{T,M,N},E}}
    exemplar_reservoir_factory::F
end

HistogramAgg{T}(
    ; boundaries = DEFAULT_HISTOGRAM_BOUNDARIES,
    is_record_min = true,
    is_record_max = true
) where {T} = HistogramAgg(
    boundaries,
    is_record_min,
    is_record_max,
    AggregationStore{DataPoint{HistogramValue{T,length(boundaries),length(boundaries) + 1},Nothing}}(),
    () -> nothing
)

function (agg::HistogramAgg{T,E})(e::Exemplar{<:Measurement}) where {T,E}
    point = get!(agg.agg_store, e.value.attributes) do
        t = UInt(time() * 10^9)
        DataPoint(
            HistogramValue{T}(
                ; boundaries = agg.boundaries,
                is_record_min = agg.is_record_min,
                is_record_max = agg.is_record_max
            ),
            t,
            t,
            agg.exemplar_reservoir_factory()
        )
    end
    if !isnothing(point)
        @atomic point.value += e.value.value
        point.time_unix_nano = e.time_unix_nano
    end
end

#####

struct Drop <: AbstractAggregation end

const DROP = Drop()

#####

default_aggregation(ins::Counter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::ObservableCounter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::UpDownCounter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::ObservableUpDownCounter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::ObservableGauge{T}) where {T} = LastValueAgg{T}()
default_aggregation(ins::Histogram{T}) where {T} = HistogramAgg{T}()