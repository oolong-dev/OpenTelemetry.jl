export inject!, extract

abstract type AbstractPropagator end

"""
    inject(carrier, [global_propagator], [current_context])

Injects the value into a carrier. For example, into the headers of an HTTP request.
"""
function inject!(
    carrier,
    propagator::AbstractPropagator = global_propagator(),
    ctx::Context = current_context(),
) end

"""
    extract(carrier, [global_propagator], [current_context])

Extracts the value from an incoming request. For example, from the headers of an HTTP request.
"""
function extract(
    carrier,
    propagator::AbstractPropagator = global_propagator(),
    ctx::Context = current_context(),
) end
