export MeterProvider

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

struct MeterProvider <: AbstractMeterProvider
    resource::Resource
    instrumentation_info::InstrumentationInfo
    is_shut_down::Ref{Bool}
    meters::IdDict{Meter, Nothing}
    messages::Channel{Pair{Meter,Measurement}}
    views::Vector{MeterView}
    metrics::Vector{Metric}

    function MeterProvider(
        resource=Resource(),
        instrumentation_info=InstrumentationInfo(),
    )
        is_shut_down = Ref(false)
        new(
            resource,
            instrumentation_info,
            is_shut_down,
        )
    end
end

function API.create_meter(p::MeterProvider, name, version, schema_url)
    m = Meter(p, name, version, schema_url, [])
    p.meters[m] = nothing
    m
end

Base.put!(p::MeterProvider, msg) = put!(p.messages, msg)
