export TracerProvider

using Base.Threads
using Dates: time

Base.@kwdef struct LimitInfo
    span_attribute_count_limit::Int = 128
    span_attribute_value_length_limit::Int = typemax(Int)
    span_event_count_limit::Int = 128
    span_link_count_limit::Int = 128
end

struct Tracer{
    S<:AbstractSampler,
    SP<:AbstractSpanProcessor,
    G<:AbstractIdGenerator
} <: API.AbstractTracer
    sampler::S
    resource::Resource
    span_processor::SP
    id_generator::G
    instrumentation::InstrumentationInfo
    limit_info::LimitInfo
end

function API.create_span(
    name::String,
    t::Tracer;
    context=current_context(),
    kind=SPAN_KIND_INTERNAL,
    attributes=[],
    links=Link[],
    events=API.Event[],
    start_time=time()
)
    span_ctx = context |> current_span |> span_context
    if isnothing(span_ctx)
        trace_id = generate_trace_id(t.id_generator)
    else
        trace_id = span_ctx.trace_id
    end

    attributes = Attributes(
        attributes...;
        count_limit=t.limit_info.span_attribute_count_limit,
        value_length_limit=t.limit_info.span_attribute_value_length_limit,
        is_mutable=true
    )

    links = Limited(links, t.limit_info.span_link_count_limit)
    events = Limited(events, t.limit_info.span_event_count_limit)

    sampling_result = should_sample(
        t.sampler,
        context,
        trace_id,
        name,
        kind,
        attributes,
        links,
        isnothing(span_ctx) ? TraceState() : span_ctx.trace_state
    )

    span_ctx = SpanContext(
        trace_id = trace_id,
        span_id = generate_span_id(t.id_generator),
        is_remote=false,
        trace_flag = TraceFlag(sampled=is_sampled(sampling_result)),
        trace_state=sampling_result.trace_state
    )

    if is_recording(sampling_result)
        WrappedSpan(
            ;span_processor=t.span_processor,
            instrumentation_info=t.instrumentation,
            resource=t.resource,
            name=name,
            span_ctx=span_ctx,
            context=context,
            kind=kind,
            attributes=attributes,
            links=links,
            events=events,
            start_time=start_time
        )
    else
        NonRecordingSpan(span_ctx)
    end
end

#####
# TracerProvider
#####

Base.@kwdef struct TracerProvider{
    S<:AbstractSampler,
    IDG<:AbstractIdGenerator
} <: API.AbstractTracerProvider
    sampler::S=DEFAULT_ON
    resource::Resource=Resource()
    span_processor::MultiSpanProcessor=MultiSpanProcessor()
    id_generator::IDG=RandomIdGenerator()
    limit_info::LimitInfo=LimitInfo()
end

shut_down!(p::TracerProvider) = shut_down!(p.span_processor)

force_flush!(p::TracerProvider, args...) = force_flush!(p.span_processor, args...)

function API.get_tracer(p::TracerProvider, instrumentation_name, instrumentation_version=nothing)
    Tracer(
        p.sampler,
        p.resource,
        p.span_processor,
        p.id_generator,
        isnothing(instrumentation_version) ? InstrumentationInfo(instrumentation_name) : InstrumentationInfo(instrumentation_name, instrumentation_version),
        p.limit_info
    )
end
