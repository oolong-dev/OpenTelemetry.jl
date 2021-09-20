using Base.Threads
using Dates: now

struct Tracer{
    S<:AbstractSampler,
    SP<:AbstractSpanProcessor,
    G<:AbstractIdGenerator
} <: API.AbstractTracer
    sampler::S
    resource::Resource
    span_processor::SP
    id_generator::G
end

function API.create_span(
    t::Tracer,
    name::String;
    parent_context=API.current_context(),
    kind=API.INTERNAL,
    attributes=API.Attributes(),
    links=[],
    start_time=now(),
    record_exception=true,
    set_status_on_exception=true,
    end_on_exit=true,
)
    parent_span_ctx = parent_context |> current_span |> get_context
    if parent_span_ctx === INVALID_SPAN_CONTEXT
        trace_id = generate_trace_id(t.id_generator)
    else
        trace_id = parent_span_ctx.trace_id
    end

    sampling_result = should_sample(t.sampler, parent_context, trace_id, name, kind, attributes, links, parent_span_ctx.trace_state)
    trace_flag = is_sampled(sampling_result) ? API.TraceFlag(API.SAMPLED_TRACE) : API.TraceFlag(API.NO_SAMPLED_TRACE)
    span_ctx = API.SpanContext(
        trace_id = trace_id,
        span_id = generate_span_id(t.sampler),
        is_remote=false,
        trace_flag = trace_flag,
        trace_state=sampling_result.trace_state
    )

    if is_recording(sampling_result)
        Span(
            ;name=name,
            span_context=span_ctx,
            parent_context=parent_context,
            kind=kind,
            attributes=attributes,
            links=links,
            start_time=start_time
        )
    else
        API.NonRecordingSpan(span_ctx)
    end
end

#####
# TracerProvider
#####

struct TracerProvider{
    S<:AbstractSampler,
    IDG<:AbstractIdGenerator
} <: API.AbstractTracerProvider
    sampler::S
    resource::Resource
    span_processor::MultiSpanProcessor
    id_generator::IDG
    shutdown_on_exit::Bool
    function TracerProvider()
        p = new{}()
        finalizer(shut_down!, p)
        p
    end
end

shut_down!(p::TracerProvider) = shut_down!(p.span_processor)

force_flush!(p::TracerProvider, args...) = force_flush!(p.span_processor, args...)

function API.get_tracer(p::TracerProvider)
    Tracer(
        p.sampler,
        p.resource,
        p.span_processor,
        p.id_generator,
    )
end
