export global_propagator

"""
    CompositePropagator(propagators::Vector)
"""
struct CompositePropagator <: AbstractPropagator
    propagators::Vector{AbstractPropagator}
end

function inject!(carrier, propagator::CompositePropagator, ctx::Context)
    for p in propagator.propagators
        inject!(carrier, p, ctx)
    end
    carrier
end

function extract(carrier, propagator::CompositePropagator, ctx::Context)
    for p in propagator.propagators
        ctx = extract(carrier, p, ctx)
    end
    ctx
end

#####

const GLOBAL_PROPAGATOR =
    CompositePropagator(AbstractPropagator[TraceContextTextMapPropagator()])

global_propagator() = GLOBAL_PROPAGATOR

Base.push!(cp::CompositePropagator, p::AbstractPropagator) = push!(cp.propagators, p)
Base.push!(p::AbstractPropagator) = push!(global_propagator(), p)
