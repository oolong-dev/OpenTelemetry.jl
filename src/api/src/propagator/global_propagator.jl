export global_propagator

"""
    CompositePropagator(propagators::Vector)
"""
struct CompositePropagator <: AbstractPropagator
    propagators::Vector{AbstractPropagator}
end

function inject_context!(carrier, propagator::CompositePropagator, ctx::Context)
    for p in propagator.propagators
        inject_context!(carrier, p, ctx)
    end
    carrier
end

function extract_context(carrier, propagator::CompositePropagator, ctx::Context)
    for p in propagator.propagators
        ctx = extract_context(carrier, p, ctx)
    end
    ctx
end

#####

const GLOBAL_PROPAGATOR = CompositePropagator(AbstractPropagator[])

global_propagator() = GLOBAL_PROPAGATOR

function Base.push!(cp::CompositePropagator, p::AbstractPropagator)
    for x in cp.propagators
        if x == p
            return
        end
    end
    push!(cp.propagators, p)
end

Base.push!(p::AbstractPropagator) = push!(global_propagator(), p)
