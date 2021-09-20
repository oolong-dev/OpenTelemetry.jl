abstract type AbstractSampler end

@enum Decision begin
    DROP
    RECORD_ONLY
    RECORD_AND_SAMPLE
end

is_sampled(d::Decision) = d === RECORD_AND_SAMPLE
is_recording(d::Decision) = d === RECORD_ONLY || d === RECORD_AND_SAMPLE

struct SamplingResult
    decision::Decision
    attributes::API.Attributes
    trace_state::API.TraceState
end

struct StaticSampler <: AbstractSampler
    decision::Decision
end

const ALWAYS_ON = StaticSampler(RECORD_AND_SAMPLE)
const ALWAYS_OFF = StaticSampler(DROP)

function Base.show(io::IO, s::StaticSampler)
    if s.decision === DROP
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
    kind=nothing,
    attributes=nothing,
    links=nothing,
    trace_state=nothing,
)
    if s.decision === DROP
        attributes = API.Attributes()
    end
    parent_span_ctx = parent_context |> current_span |> get_context
    SamplingResult(
        s.decision,
        attributes,
        parent_span_ctx.trace_state
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
    kind=nothing,
    attributes=nothing,
    links=nothing,
    trace_state=nothing,
)
    decision = DROP
    if trace_id < s.bound
        decision = RECORD_AND_SAMPLE
    end
    if decision === DROP
        attributes = API.Attributes()
    end
    parent_span_ctx = parent_context |> current_span |> get_context
    SamplingResult(
        decision,
        attributes,
        parent_span_ctx.trace_state
    )
end

Base.@kwdef struct ParentBasedSampler{R,T1,T2,T3,T4} <: AbstractSampler
    root::R
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
    kind=nothing,
    attributes=nothing,
    links=nothing,
    trace_state=nothing,
)
    parent_span_ctx = parent_context |> current_span |> get_context
    sampler = s.root
    if parent_span_ctx !== API.INVALID_SPAN_CONTEXT
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
    should_sample(sampler, parent_span_ctx, trace_id, name, kind, attributes, links, trace_state)
end

"""Sampler that respects its parent span's sampling decision, but otherwise never samples."""
DEFAULT_OFF = ParentBased(root=ALWAYS_OFF)

"""Sampler that respects its parent span's sampling decision, but otherwise always samples."""
DEFAULT_ON = ParentBased(root=ALWAYS_ON)