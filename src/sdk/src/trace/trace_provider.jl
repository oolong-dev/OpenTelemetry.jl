export TracerProvider

"""
    TracerProvider(;kw...)

# Keyword Arguments

  - `sampler`::[`AbstractSampler`](@ref)=[`DEFAULT_ON`](@ref)
  - `resource`=[`Resource`](@ref)()
  - `span_processor`::[`AbstractSpanProcessor`](@ref)=[`CompositSpanProcessor`](@ref)()
  - `id_generator`::[`AbstractIdGenerator`](@ref)=[`RandomIdGenerator`](@ref)()
  - `limit_info`=[`LimitInfo`](@ref)()

The following extra methods are provided beyond those defined in [`AbstractTracerProvider`](@ref):

  - [`force_flush!(p::TracerProvider)`](@ref)
  - [`shut_down!(p::TracerProvider)`](@ref)
  - [`Base.push!(p::TracerProvider, sp::AbstractSpanProcessor)`](@ref)
"""
Base.@kwdef struct TracerProvider{
    S<:AbstractSampler,
    R<:Resource,
    SP<:AbstractSpanProcessor,
    RNG,
} <: AbstractTracerProvider
    sampler::S = DEFAULT_ON
    resource::R = Resource()
    span_processor::SP = CompositSpanProcessor()
    id_generator::RNG = RandomIdGenerator()
    limit_info::LimitInfo = LimitInfo()
    is_shut_down::Ref{Bool} = Ref(false)
end

OpenTelemetryAPI.resource(p::TracerProvider) = p.resource

"""
    force_flush!(p::TracerProvider)

Shorthand to force flush inner span processors
"""
force_flush!(p::TracerProvider) = force_flush!(p.span_processor)

"""
    shut_down!(p::TracerProvider)

Shut down inner span processors and then mark itself as shut down.
"""
function shut_down!(p::TracerProvider)
    shut_down!(p.span_processor)
    p.is_shut_down[] = true
end

"""
    Base.push!(p::TracerProvider, sp::AbstractSpanProcessor)

Add an extra span processor `sp` into the [`TracerProvider`](@ref) p.
"""
Base.push!(p::TracerProvider, sp::AbstractSpanProcessor) = push!(p.span_processor, sp)
