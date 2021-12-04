export MeterProvider

using Dates: time

const N_MAX_METRICS = 1_000

Base.@kwdef mutable struct Metric{A<:AbstractAggregation}
    name::String
    description::Union{String,Nothing}
    attribute_keys::Union{Tuple{Vararg{String}},Nothing}
    aggregation::A
    criteria::Criteria
end

function (metric::Metric)(ms)
    for m in ms
        metric(m)
    end
end

Base.iterate(m::Metric, args...) = iterate(m.aggregation, args...)
Base.getindex(m::Metric, k) = getindex(m.aggregation, k)
Base.length(m::Metric) = length(m.aggregation)

function (metric::Metric)(m::Measurement)
    if isnothing(metric.attribute_keys)
        filtered_attributes = StaticAttrs()
    else
        interested_keys = keys(m.attributes) ∩ metric.attribute_keys
        filtered_keys = setdiff(keys(m.attributes), interested_keys)
        m = Measurement(m.value, m.attributes[Tuple(interested_keys)])
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
        time_unix_nano = UInt(time() * 10^9),
        filtered_attributes = filtered_attributes,
        trace_id = trace_id,
        span_id = span_id,
    )
    metric.aggregation(exemplar)
end

struct MeterProvider <: AbstractMeterProvider
    resource::Resource
    meters::IdDict{Meter,Nothing}
    instrument_associated_metric_names::IdDict{AbstractInstrument,Set{String}}
    async_instruments::IdDict{AbstractAsyncInstrument,Nothing}
    views::Vector{View}
    metrics::Dict{String,Metric}
    n_max_metrics::UInt
end

function MeterProvider(;
    resource = Resource(),
    views = View[],
    n_max_metrics = N_MAX_METRICS,
)
    if isempty(views)
        push!(views, View(; instrument_name = "*"))
    end

    MeterProvider(
        resource,
        Dict{String,Meter}(),
        IdDict{AbstractInstrument,Vector{String}}(),
        IdDict{AbstractAsyncInstrument,Nothing}(),
        views,
        Dict{String,Metric}(),
        n_max_metrics,
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
        drop_views = (v for v in p.views if v.aggregation === DROP)
        valid_views = (v for v in p.views if v.aggregation !== DROP)

        is_drop = false
        for v in drop_views
            if occursin(ins, v.criteria)
                is_drop = true
                break
            end
        end

        if is_drop
            @info "Metric won't be created since the view for the instrument [$(ins.name)] is configured to DROP."
        else
            for v in valid_views
                if occursin(ins, v.criteria)
                    if length(p.metrics) >= p.n_max_metrics
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
                                aggregation = if isnothing(v.aggregation)
                                    default_aggregation(ins)
                                else
                                    v.aggregation
                                end,
                                criteria = v.criteria,
                            )
                        end
                        push!(
                            get!(p.instrument_associated_metric_names, ins, Set{String}()),
                            metric_name,
                        )

                        if ins isa AbstractAsyncInstrument
                            p.async_instruments[ins] = nothing
                        end
                    end
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
