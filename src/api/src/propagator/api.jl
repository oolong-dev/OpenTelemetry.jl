export inject!, extract

abstract type AbstractPropagator end

"""
    inject(carrier, [global_propagator], [current_context])

Injects the value into a carrier. For example, into the headers of an HTTP request.
"""
inject!(carrier) = inject!(carrier, global_propagator(), current_context())

"""
    extract(carrier, [global_propagator], [current_context])

Extracts the value from an incoming request. For example, from the headers of an HTTP request.
"""
extract(carrier) = extract(carrier, global_propagator(), current_context())
