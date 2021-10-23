export inject!, extract

abstract type AbstractPropagator end

struct CompositePropagator <: AbstractPropagator
    propagators::Vector
end

const GLOBAL_PROPAGATOR = CompositePropagator([])

Base.push!(cp::CompositePropagator, p::AbstractPropagator) = push!(cp.propagators, p)

"""
    inject(carrier, [global_propagator], [current_context])

Injects the value into a carrier. For example, into the headers of an HTTP request.
"""
function inject!(carrier, propagator::AbstractPropagator=GLOBAL_PROPAGATOR, ctx::Context=current_context()) end

function inject!(
    carrier,
    propagator::CompositePropagator,
    ctx::Context
)
    for p in propagator.propagators
        inject!(carrier, p, ctx)
    end
end

"""
    extract(carrier, [global_propagator], [current_context])

Extracts the value from an incoming request. For example, from the headers of an HTTP request.
"""
function extract(carrier, propagator::AbstractPropagator=global_propagator(), ctx::Context=current_context()) end

function extract(
    carrier,
    propagator::CompositePropagator,
    ctx::Context
)
    for p in propagator.propagators
        ctx = extract(carrier, p, ctx)
    end
    ctx
end