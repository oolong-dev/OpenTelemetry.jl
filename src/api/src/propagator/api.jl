export inject_context!, extract_context

abstract type AbstractPropagator end

"""
    inject(carrier, [global_propagator], [current_context])

Injects the value into a carrier. For example, into the headers of an HTTP request.
"""
inject_context!(carrier) = inject_context!(carrier, global_propagator(), current_context())

"""
    extract_context(carrier, [global_propagator], [current_context])

Extracts the value from an incoming request. For example, from the headers of an HTTP request.
"""
extract_context(carrier) = extract_context(carrier, global_propagator(), current_context())
