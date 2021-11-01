using Base.Threads

const N_MAX_POINTS_PER_METRIC = 2_000

#####

abstract type AbstractTemporality end

struct Cumulative <: AbstractTemporality
end

const CUMULATIVE = Cumulative()

struct Delta <: AbstractTemporality
end

const DELTA = Delta()

#####

Base.@kwdef struct Exemplar{T}
    value::T
    time_unix_nano::UInt
    filtered_attributes::StaticAttrs
    trace_id::TraceIdType
    span_id::SpanIdType
end

abstract type AbstractExemplarReservoir end

struct SimpleFixedSizeExemplarReservoir <: AbstractExemplarReservoir
end

struct AlignedHistogramBucketExemplarReservoir <: AbstractExemplarReservoir
end

#####

abstract type AbstractDataPoint end

Base.@kwdef struct SumDataPoint{T,V,E} <: AbstractDataPoint
    value::Atomic{V} = Atomic{UInt}()
    temporality::T = CUMULATIVE
    start_time_unix_nano::UInt = UInt(time() * 10^9)
    time_unix_nano::Ref{UInt} = Ref(start_time_unix_nano)
    exemplar_reservoir::E = nothing
end

function (p::SumDataPoint{Cumulative})(x::Exemplar{<:Measurement})
    atomic_add!(p.value, x.value.value)
    p.time_unix_nano[] = x.time_unix_nano
    if !isnothing(p.exemplar_reservoir)
        push!(p.exemplar_reservoir, x)
    end
end

#####

Base.@kwdef struct AggregationStore
    points::Dict{StaticAttrs, AbstractDataPoint} = Dict{StaticAttrs, AbstractDataPoint}()
    n_points::Atomic{Int}
    max_points::UInt = N_MAX_POINTS_PER_METRIC
    data_point_constructor::Any
end

function (agg_store::AggregationStore)(e::Exemplar{<:Measurement})
    attrs = e.value.attributes
    if haskey(agg_store.points, attrs)
        agg_store.points[attrs](e)
    else
        sorted_attrs = sort(attrs)
        if haskey(agg_store.points, sorted_attrs)
            p = agg_store[sorted_attrs]
            agg_store[attrs] = p
            p(e)
        else
            # ??? lock or atomic field in Julia@v1.7
            if agg_store.n_points[] >= agg_store.max_points
                @info "Maximum number of points in aggregation store reached. Dropped!"
            else
                atomic_add!(agg_store.n_points, 1)
                p = agg_store.data_point_constructor()
                p(e)
                agg_store.points[attrs] = p
                agg_store.points[sorted_attrs] = p
            end
        end
    end
end

function Base.push!(agg::AggregationStore, (attr, x)::Pair{StaticAttrs, Exemplar})
    if attr in agg.points
        agg.points[attr](x)
    else
        if length(agg.points) >= agg.max_points
            @warn "Max number ($(agg.max_points)) of points per aggregation reached. Dropped!"
        else
            p = agg.data_point_constructor()
            p(x)
            agg.points[attr] = p
        end
    end
end

#####

abstract type AbstractAggregation end

struct SumAgg <: AbstractAggregation
    is_monotonic::Bool
    aggregation_store::AggregationStore
end

function SumAgg(
    ;temporality=CUMULATIVE,
    is_monotonic=true,
    data_type=Int,
    exemplar_reservoir_constructor=()->nothing
)
    SumAgg(
        is_monotonic,
        AggregationStore(
            ;n_points = Atomic{Int}(),
            data_point_constructor = () -> SumDataPoint(
                ;value = Atomic{data_type}(),
                temporality = temporality,
                exemplar_reservoir = exemplar_reservoir_constructor()
            )
        )
    )
end

function (agg::SumAgg)(e::Exemplar{<:Measurement})
    if agg.is_monotonic && e.value.value < 0
        throw(ArgumentError("A negative exemplar is fed into a monotonic SumAgg"))
    end
    agg.aggregation_store(e)
end

#####

struct Drop <: AbstractAggregation
end

const DROP = Drop()

#####

function default_aggregation(ins::Counter{T}) where T
    SumAgg(;is_monotonic=true, temporality=CUMULATIVE)
end