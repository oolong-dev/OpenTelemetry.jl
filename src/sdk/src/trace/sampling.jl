export ALWAYS_ON,
    ALWAYS_OFF,
    DEFAULT_ON,
    DEFAULT_OFF

abstract type AbstractSampler end

@enum Decision begin
    DECISION_DROP
    DECISION_RECORD_ONLY
    DECISION_RECORD_AND_SAMPLE
end

is_sampled(d::Decision) = d === DECISION_RECORD_AND_SAMPLE
is_recording(d::Decision) = d === DECISION_RECORD_ONLY || d === DECISION_RECORD_AND_SAMPLE

struct SamplingResult{A<:StaticAttrs, T<:TraceState}
    decision::Decision
    attributes::A
    trace_state::T
end

is_sampled(r::SamplingResult) = is_sampled(r.decision)
is_recording(r::SamplingResult) = is_recording(r.decision)

struct StaticSampler <: AbstractSampler
    decision::Decision
end

const ALWAYS_ON = StaticSampler(DECISION_RECORD_AND_SAMPLE)
const ALWAYS_OFF = StaticSampler(DECISION_DROP)

function Base.show(io::IO, s::StaticSampler)
    if s.decision === DECISION_DROP
        print(io, "AlwaysOffSampler")
    else
        print(io, "AlwaysOnSampler")
    end
end

function should_sample(
    s::StaticSampler,
    parent_context,
    trace_id,
    name,
    kind=SPAN_KIND_INTERNAL,
    attributes=StaticAttrs(),
    links=[],
    trace_state=TraceState(),
)
    if s.decision === DECISION_DROP
        attributes = Attributes()
    end
    SamplingResult(
        s.decision,
        attributes,
        trace_state
    )
end

struct TraceIdRatioBased <: AbstractSampler
    ratio::Float64
    bound::UInt128
    function TraceIdRatioBased(ratio)
        0 <= ratio <= 1 || throw(ArgumentError("ratio should be in range [0,1]"))
        new(ratio, round(UInt128, typemax(UInt128) * ratio))
    end
end

function should_sample(
    s::TraceIdRatioBased,
    parent_context,
    trace_id,
    name,
    kind=SPAN_KIND_INTERNAL,
    attributes=StaticAttrs(),
    links=[],
    trace_state=TraceState(),
)
    decision = DECISION_DROP
    if trace_id < s.bound
        decision = DECISION_RECORD_AND_SAMPLE
    end
    if decision === DECISION_DROP
        attributes = StaticAttrs()
    end
    SamplingResult(
        decision,
        attributes,
        trace_state
    )
end

Base.@kwdef struct ParentBasedSampler{R,T1,T2,T3,T4} <: AbstractSampler
    root_sampler::R
    remote_parent_sampled::T1 = ALWAYS_ON
    remote_parent_not_sampled::T2 = ALWAYS_OFF
    local_parent_sampled::T3 = ALWAYS_ON
    local_parent_not_sampled::T4 = ALWAYS_OFF
end

function should_sample(
    s::ParentBasedSampler,
    parent_context,
    trace_id,
    name,
    kind=SPAN_KIND_INTERNAL,
    attributes=StaticAttrs(),
    links=[],
    trace_state=TraceState(),
)
    parent_span_ctx = parent_context |> current_span |> span_context
    sampler = s.root_sampler
    if !isnothing(parent_span_ctx)
        if parent_span_ctx.is_remote
            if parent_span_ctx.trace_flag.sampled
                sampler = s.remote_parent_sampled
            else
                sampler = s.remote_parent_not_sampled
            end
        else
            if parent_span_ctx.trace_flag.sampled
                sampler = s.local_parent_sampled
            else
                sampler = s.local_parent_not_sampled
            end
        end
    end
    should_sample(sampler, parent_context, trace_id, name, kind, attributes, links, trace_state)
end

"""Sampler that respects its parent span's sampling decision, but otherwise never samples."""
DEFAULT_OFF = ParentBasedSampler(root_sampler=ALWAYS_OFF)

"""Sampler that respects its parent span's sampling decision, but otherwise always samples."""
DEFAULT_ON = ParentBasedSampler(root_sampler=ALWAYS_ON)