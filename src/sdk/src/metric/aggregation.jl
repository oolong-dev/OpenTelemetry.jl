export Exemplar, SumAgg, LastValueAgg, HistogramAgg, DROP

const N_MAX_POINTS_PER_METRIC = 2_000

#####

"""
    Exemplar(;kw...)

Exemplars are example data points for aggregated data. Read [the
specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/sdk.md#exemplar)
to understand its relation to trace and metric.

## Keyword arguments:

  - `value`
  - `time_unix_nano`
  - `filtered_attributes`::[`StaticAttrs`](@ref), extra attributes of a
    [`Measurement`](@ref) that are not included in a [`Metric`](@ref)'s
    `:attribute_keys` field.
  - `trace_id`, the `trace_id` in the span context when the measurement happens.
  - `span_id`, the `span_id` in the span context when the measurement happens.
"""
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

if VERSION >= v"1.7.0"
    include("datapoint_atomic.jl")
else
    include("datapoint_lock.jl")
end

struct AggregationStore{D<:DataPoint}
    points::Dict{StaticAttrs,D}
    unique_points::Dict{StaticAttrs,D}
    n_max_points::UInt
    n_max_attrs::UInt
    lock::ReentrantLock
end

"""
    AggregationStore{D}(;kw...) where D<:DataPoint

The `AggregationStore` holds all the aggregated datapoints in a
[`Metric`](@ref).

## Keyword arguments

  - `n_max_points = N_MAX_POINTS_PER_METRIC`, the maximum number of data points.
  - `n_max_attrs = 2 * N_MAX_POINTS_PER_METRIC`, the maximum number of allowed
    attributes. Note that each datapoint may have several attributes pointing to
    them. (Those attributes have the same key-value pair but with different
    order)
"""
function AggregationStore{D}(;
    n_max_points = N_MAX_POINTS_PER_METRIC,
    n_max_attrs = 2 * N_MAX_POINTS_PER_METRIC
) where {D<:DataPoint}
    AggregationStore{D}(
        Dict{StaticAttrs,D}(),
        Dict{StaticAttrs,D}(),
        UInt(n_max_points),
        UInt(n_max_attrs),
        ReentrantLock(),
    )
end

Base.iterate(a::AggregationStore, args...) = iterate(a.unique_points, args...)
Base.length(m::AggregationStore) = length(m.unique_points)

function Base.getindex(m::AggregationStore, k)
    v = get(m.points, k, nothing)
    if isnothing(v)
        k_sorted = sort(k)
        get(m.points, k_sorted)
    else
        v
    end
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

Base.iterate(a::AbstractAggregation, args...) = iterate(a.agg_store, args...)
Base.getindex(m::AbstractAggregation, k) = getindex(m.agg_store, k)
Base.length(m::AbstractAggregation) = length(m.agg_store)

"""
    SumAgg(agg_store::AggregationStore, exemplar_reservoir_factory)

When `exemplar_reservoir_factory` set to `nothing`, no exemplar will be stored.
See more details in [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/sdk.md#sum-aggregation).
"""
struct SumAgg{T,E,F} <: AbstractAggregation
    agg_store::AggregationStore{DataPoint{T,E}}
    exemplar_reservoir_factory::F
end

"""
    SumAgg{T}()
"""
SumAgg{T}() where {T} = SumAgg(AggregationStore{DataPoint{T,Nothing}}(), () -> nothing)

function (agg::SumAgg{T,E})(e::Exemplar{<:Measurement}) where {T,E}
    point = get!(agg.agg_store, e.value.attributes) do
        DataPoint{T}(agg.exemplar_reservoir_factory())
    end
    if !isnothing(point)
        _add_to_datapoint!(point, e.value.value, e.time_unix_nano)
    end
end

#####

"""
    LastValueAgg(agg_store::AggregationStore, exemplar_reservoir_factory)

When `exemplar_reservoir_factory` set to `nothing`, no exemplar will be stored.

See more details in [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/sdk.md#last-value-aggregation).
"""
struct LastValueAgg{T,E,F} <: AbstractAggregation
    agg_store::AggregationStore{DataPoint{T,E}}
    exemplar_reservoir_factory::F
end

"""
    LastValueAgg{T}()
"""
LastValueAgg{T}() where {T} =
    LastValueAgg(AggregationStore{DataPoint{T,Nothing}}(), () -> nothing)

function (agg::LastValueAgg{T,E})(e::Exemplar{<:Measurement}) where {T,E}
    point = get!(agg.agg_store, e.value.attributes) do
        DataPoint{T}(agg.exemplar_reservoir_factory())
    end
    if !isnothing(point)
        _update_to_datapoint!(point, e.value.value, e.time_unix_nano)
    end
end

#####

const DEFAULT_HISTOGRAM_BOUNDARIES =
    (0.0, 5.0, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0, 500.0, 1000.0)

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

"""
    HistogramAgg(args...)

## Arguments:

  - `boundaries::NTuple{M, Float64} where M`, the boundaries to calculate
    histogram buckets. Note that `-Inf` and `Inf` shouldn't be included.
  - `is_record_min`
  - `is_record_max`
  - `agg_store`
  - `exemplar_reservoir_factory`, when set to `nothing`, no exemplar will be stored.
"""
struct HistogramAgg{T,E,F,M,N} <: AbstractAggregation
    boundaries::NTuple{M,Float64}
    is_record_min::Bool
    is_record_max::Bool
    agg_store::AggregationStore{DataPoint{HistogramValue{T,M,N},E}}
    exemplar_reservoir_factory::F
end

"""
    HistogramAgg{T}(;boundaries = DEFAULT_HISTOGRAM_BOUNDARIES, is_record_min = true, is_record_max = true)
"""
HistogramAgg{T}(;
    boundaries = DEFAULT_HISTOGRAM_BOUNDARIES,
    is_record_min = true,
    is_record_max = true
) where {T} = HistogramAgg(
    boundaries,
    is_record_min,
    is_record_max,
    AggregationStore{
        DataPoint{HistogramValue{T,length(boundaries),length(boundaries) + 1},Nothing},
    }(),
    () -> nothing,
)

function (agg::HistogramAgg{T,E})(e::Exemplar{<:Measurement}) where {T,E}
    point = get!(agg.agg_store, e.value.attributes) do
        t = UInt(time() * 10^9)
        DataPoint(
            HistogramValue{T}(;
                boundaries = agg.boundaries,
                is_record_min = agg.is_record_min,
                is_record_max = agg.is_record_max
            ),
            t,
            t,
            agg.exemplar_reservoir_factory(),
        )
    end
    if !isnothing(point)
        _add_to_datapoint!(point, e.value.value, e.time_unix_nano)
    end
end

#####

struct Drop <: AbstractAggregation end

"""
All measurement will be dropped.
"""
const DROP = Drop()

#####

default_aggregation(ins::Counter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::ObservableCounter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::UpDownCounter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::ObservableUpDownCounter{T}) where {T} = SumAgg{T}()
default_aggregation(ins::ObservableGauge{T}) where {T} = LastValueAgg{T}()
default_aggregation(ins::Histogram{T}) where {T} = HistogramAgg{T}()
