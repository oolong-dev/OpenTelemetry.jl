export MeterProvider, metrics

using Dates: time
using Base: IdSet

Base.@kwdef mutable struct Metric{A<:AbstractAggregation}
    name::String
    description::Union{String,Nothing}
    attribute_keys::Union{Tuple{Vararg{String}},Nothing}
    aggregation::A
    instrument::OpenTelemetryAPI.AbstractInstrument
end

Base.iterate(m::Metric, args...) = iterate(m.aggregation, args...)
Base.getindex(m::Metric, k...) = getindex(m.aggregation, k...)
Base.length(m::Metric) = length(m.aggregation)
OpenTelemetryAPI.resource(m::Metric) = resource(m.instrument)

function (metric::Metric)(m::Measurement)
    if isnothing(metric.attribute_keys)
        filtered_attributes = BoundedAttributes()
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

struct MeterProvider <: OpenTelemetryAPI.AbstractMeterProvider
    resource::Resource
    meters::IdSet{Meter}
    instrument_linked_metrics::IdDict{OpenTelemetryAPI.AbstractInstrument,IdSet{Metric}}
    async_instruments::IdSet{OpenTelemetryAPI.AbstractAsyncInstrument}
    views::Vector{View}
    named_view_linked_ins::IdDict{View,OpenTelemetryAPI.AbstractInstrument}
    metrics::IdSet{Metric}
    max_metrics::Int
end

OpenTelemetryAPI.resource(p::MeterProvider) = p.resource

"""
    metrics([global_meter_provider()])
"""
metrics() = metrics(global_meter_provider())

metrics(::OpenTelemetryAPI.DummyMeterProvider) = ()
metrics(p::MeterProvider) = p.metrics

"""
    MeterProvider(;resource = Resource(), views = View[], max_metrics = nothing)

If `views` is empty, a default one ([`View(;instrument_name="*")`](@ref)) will be added to enable all metrics.
"""
function MeterProvider(;
    resource = Resource(),
    views = View[],
    max_metrics = OTEL_JULIA_MAX_METRICS_APPROX_PER_PROVIDER(),
)
    if isempty(views)
        push!(views, View(; instrument_name = "*"))
    end

    MeterProvider(
        resource,
        IdSet{Meter}(),
        IdDict{OpenTelemetryAPI.AbstractInstrument,IdSet{Metric}}(),
        IdSet{OpenTelemetryAPI.AbstractAsyncInstrument}(),
        views,
        IdDict{View,OpenTelemetryAPI.AbstractInstrument}(),
        IdSet{Metric}(),
        max_metrics,
    )
end

# Registration
# Remember that this function is called on the initialization of `Meter`
function Base.push!(p::MeterProvider, m::Meter)
    push!(p.meters, m)
    for ins in m.instruments
        push!(p, ins)
    end
end

function Base.push!(p::MeterProvider, ins::OpenTelemetryAPI.AbstractInstrument)
    # 1. Register the meter that the `ins` belongs to
    push!(p.meters, ins.meter)

    # 2. Register the `ins`
    drop_views = (v for v in p.views if v.aggregation === DROP)
    valid_views = (v for v in p.views if v.aggregation !== DROP)

    is_drop = false
    for v in drop_views
        if occursin(ins, v.criteria)
            is_drop = true
            break
        end
    end

    # 2.1 Check if the `ins`` is configured to be dropped
    if is_drop
        @info "Metric won't be created since the view for the instrument [$(ins.name)] is configured to DROP."
    else
        for v in valid_views
            # 2.2 try to find the matching views
            if occursin(ins, v.criteria)
                # 2.2.1 for each valid ins => view pair, we're going to
                # create a metric for them So better to check if we've
                # reached the maximum number of metrics configured in the
                # provider
                if length(p.metrics) >= p.max_metrics
                    @warn "Maximum number of metrics [$(p.max_metrics)] reached. Instrument [$(ins.name)] related metrics are dropped!"
                else
                    metric = Metric(
                        name = something(v.name, ins.name),
                        description = something(v.description, ins.description),
                        attribute_keys = v.attribute_keys,
                        aggregation = something(v.aggregation, default_aggregation(ins)),
                        instrument = ins,
                    )

                    # https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/sdk.md#view
                    # > In order to avoid conflicts, views which specify
                    # > a name SHOULD have an instrument selector that
                    # > selects at most one instrument. For the
                    # > registration mechanism described above, where
                    # > selection is provided via configuration, the SDK
                    # > MUST NOT allow Views with a specified name to be
                    # > declared with instrument selectors that select
                    # > more than one instrument (e.g. wild card
                    # > instrument name).
                    if !isnothing(v.name)
                        if haskey(p.named_view_linked_ins, v)
                            @info "This named view [$(v.name)] is already registered with an instrument"
                            continue  # !!! important
                        else
                            p.named_view_linked_ins[v] = ins
                        end
                    end

                    push!(get!(p.instrument_linked_metrics, ins, IdSet{Metric}()), metric)
                    push!(p.metrics, metric)

                    if ins isa OpenTelemetryAPI.AbstractAsyncInstrument
                        push!(p.async_instruments, ins)
                    end
                end
            end
        end
    end
end

function Base.push!(
    p::MeterProvider,
    ins_m::Pair{<:OpenTelemetryAPI.AbstractInstrument,<:Measurement},
)
    instrument, measurement = ins_m
    if haskey(p.instrument_linked_metrics, instrument)
        for metric in p.instrument_linked_metrics[instrument]
            metric(measurement)
        end
    else
        @debug "Instrument [$(instrument.name)] is not registered in the meter provider."
    end
end

function Base.push!(p::MeterProvider, ins_m::Pair{<:OpenTelemetryAPI.AbstractInstrument})
    ins, m = ins_m
    push!(p, ins => Measurement(m))
end
