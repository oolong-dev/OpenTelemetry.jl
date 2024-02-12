export TracerProvider

"""
    TracerProvider(;kw...)

# Keyword Arguments

  - `sampler`::[`AbstractSampler`](@ref)=[`DEFAULT_ON`](@ref)
  - `resource`=[`Resource`](@ref)()
  - `span_processor`::[`AbstractSpanProcessor`](@ref)=[`SimpleSpanProcessor`](@ref)([`ConsoleExporter`](@ref))
  - `id_generator`::[`AbstractIdGenerator`](@ref)=[`RandomIdGenerator`](@ref)()
  - `limit_info`=[`LimitInfo`](@ref)()

The following extra methods are provided beyond those defined in [`AbstractTracerProvider`](@ref):

  - [`flush(p::TracerProvider)`](@ref)
  - [`close(p::TracerProvider)`](@ref)
  - [`Base.push!(p::TracerProvider, sp::AbstractSpanProcessor)`](@ref)
"""
Base.@kwdef mutable struct TracerProvider{
    S<:AbstractSampler,
    R<:Resource,
    SP<:AbstractSpanProcessor,
    RNG<:AbstractIdGenerator,
} <: OpenTelemetryAPI.AbstractTracerProvider
    sampler::S = get_default_trace_sampler()
    resource::R = Resource()
    span_processor::SP = SimpleSpanProcessor(ConsoleExporter())
    id_generator::RNG = RandomIdGenerator()
    limit_info::LimitInfo = LimitInfo()
    is_closed::Bool = false # mutable
end

OpenTelemetryAPI.resource(p::TracerProvider) = p.resource

"""
    flush(p::TracerProvider)

Shorthand to force flush inner span processors
"""
Base.flush(p::TracerProvider) = flush(p.span_processor)

"""
    close(p::TracerProvider)

Shut down inner span processors and then mark itself as shut down.
"""
function Base.close(p::TracerProvider)
    close(p.span_processor)
    p.is_closed = true
end

"""
    Base.push!([p::TracerProvider], sp::AbstractSpanProcessor)

Add an extra span processor `sp` into the [`TracerProvider`](@ref) p.
"""
Base.push!(sp::AbstractSpanProcessor) = push!(global_tracer_provider(), sp)
Base.push!(p::TracerProvider, sp::AbstractSpanProcessor) = push!(p.span_processor, sp)
