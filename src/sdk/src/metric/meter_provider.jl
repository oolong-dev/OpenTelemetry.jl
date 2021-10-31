export MeterProvider

using Glob
using Dates:time
using Base.Threads

const N_MAX_METRICS = 1_000
const N_MAX_POINTS_PER_METRIC = 2_000

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

abstract type AbstractTemporality end

struct Cumulative <: AbstractTemporality
end

const CUMULATIVE = Cumulative()

struct Delta <: AbstractTemporality
end

const DELTA = Delta()

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

struct Drop <: AbstractAggregation
end

const DROP = Drop()

function default_aggregation(ins::Counter{T}) where T
    SumAgg(;is_monotonic=true, temporality=CUMULATIVE)
end

#####

struct Criteria
    instrument_type::Union{DataType, Nothing}
    instrument_name::Union{Glob.FilenameMatch{String}, Nothing}
    meter_name::Union{String, Nothing}
    meter_version::Union{VersionNumber, Nothing}
    meter_schema_url::Union{String, Nothing}
end

function Base.occursin(ins::AbstractInstrument, c::Criteria)
    if !isnothing(c.instrument_type)
        if !(typeof(ins) isa c.instrument_type)
            return false
        end
    end

    if !isnothing(c.instrument_name)
        if !occursin(c.instrument_name, ins.name)
            return false
        end
    end

    if !isnothing(c.meter_name)
        if ins.meter.name != c.meter_name
            return false
        end
    end

    if !isnothing(c.meter_version)
        if ins.meter.version != c.meter_version
            return false
        end
    end

    if !isnothing(c.meter_schema_url)
        if ins.meter.schema_url != c.meter_schema_url
            return false
        end
    end

    return true
end

Base.@kwdef mutable struct Metric{A<:AbstractAggregation}
    name::String
    description::Union{String, Nothing}
    attribute_keys::Union{Tuple{Vararg{String}}, Nothing}
    aggregation::A
    criteria::Criteria
end

function (metric::Metric)(m::Measurement)
    if isnothing(metric.attribute_keys)
        filtered_attributes = StaticAttrs()
    else
        interested_keys = keys(m.attributes) ∩ metric.attribute_keys
        filtered_keys = setdiff(keys(m.attributes), interested_keys)
        m = Measurement(
            m.value,
            m.attributes[Tuple(interested_keys)]
        )
        filtered_attributes = m.attributes[Tuple(filtered_keys)]
    end

    span_ctx = span_context()
    if isnothing(span_ctx)
        trace_id = INVALID_TRACE_ID
        span_id = INVALID_SPAN_ID
    else
        trace_id = span_ctx.trace_id
        span_id = span_ctx.span_id
    end

    exemplar = Exemplar(;
        value = m,
        time_unix_nano = UInt(time() * 10 ^ 9),
        filtered_attributes = filtered_attributes,
        trace_id = trace_id,
        span_id = span_id
    )
    metric.aggregation(exemplar)
end

struct View{A}
    name::Union{String, Nothing}
    description::Union{String, Nothing}
    criteria::Criteria
    attribute_keys::Union{Tuple{Vararg{String}}, Nothing}
    extra_dimensions::StaticAttrs
    aggregation::A
end

function View(
    ;name = nothing,
    description = nothing,
    attribute_keys = nothing,
    extra_dimensions = StaticAttrs(),
    aggregation = nothing,
    # criteria
    instrument_name = nothing,
    instrument_type=nothing,
    meter_name = nothing,
    meter_version_bound = nothing,
    meter_schema_url = nothing
)
    something(
        instrument_name,
        instrument_type,
        meter_name,
        meter_version_bound,
        meter_schema_url
    )
    criteria = Criteria(
        instrument_type,
        isnothing(instrument_name) ? nothing : Glob.FilenameMatch(instrument_name),
        meter_name,
        meter_version_bound,
        meter_schema_url
    )
    View(
        name,
        description,
        criteria,
        attribute_keys,
        extra_dimensions,
        aggregation
    )
end

struct MeterProvider <: AbstractMeterProvider
    resource::Resource
    meters::IdDict{Meter, Nothing}
    instrument_associated_metric_names::IdDict{AbstractInstrument, Set{String}}
    views::Vector{View}
    metrics::Dict{String, Metric}
    n_max_metrics::UInt
end

function MeterProvider(
    resource=Resource(),
    views=View[],
    n_max_metrics = N_MAX_METRICS
)
    if isempty(views)
        push!(views, View(;instrument_name="*"))
    end

    MeterProvider(
        resource,
        Dict{String,Meter}(),
        IdDict{AbstractInstrument, Vector{String}}(),
        views,
        Dict{String,Metric}(),
        n_max_metrics
    )
end

function Base.push!(p::MeterProvider, m::Meter)
    p.meters[m] = nothing
    for ins in m.instruments
        push!(p, ins)
    end
end

function Base.push!(p::MeterProvider, ins::AbstractInstrument)
    if !haskey(p.meters, ins.meter)
        p.meters[ins.meter] = nothing
    end

    if !haskey(p.instrument_associated_metric_names, ins)
        for v in p.views
            if occursin(ins, v.criteria)
                if v.aggregation === DROP
                    @info "Metric won't be created since the view for the instrument [$(ins.name)] is configured to DROP."
                elseif length(p.metrics) >= p.n_max_metrics
                    @warn "Maximum number of metrics [$(p.n_max_metrics)] reached. Instrument [$(ins.name)] related metrics are dropped!"
                else
                    metric_name = something(v.name, ins.name)
                    if haskey(p.metrics, metric_name)
                        @info "Found a duplicate metric [$metric_name]. The original one will be reused."
                    else
                        p.metrics[metric_name] = Metric(
                            name = metric_name,
                            description = something(v.description, ins.description),
                            attribute_keys = v.attribute_keys,
                            aggregation = isnothing(v.aggregation) ? default_aggregation(ins) : v.aggregation,
                            criteria = v.criteria
                        )
                    end
                    push!(get!(p.instrument_associated_metric_names, ins, Set{String}()), metric_name)
                end
            end
        end
    end
end

function Base.push!(p::MeterProvider, (instrument, measurement))
    if haskey(p.instrument_associated_metric_names, instrument)
        for metric_name in p.instrument_associated_metric_names[instrument]
            metric = p.metrics[metric_name]
            metric(measurement)
        end
    else
        @debug "Instrument [$(instrument.name)] is not registered in the meter provider."
    end
end
