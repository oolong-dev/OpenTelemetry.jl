export Resource, InstrumentationInfo

"""
    Resource(;attributes=nothing, schema_url="")

Quoted from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#resources):

> Resource captures information about the entity for which telemetry is recorded. For example, metrics exposed by a Kubernetes container can be linked to a resource that specifies the cluster, namespace, pod, and container name.
> 
> Resource may capture an entire hierarchy of entity identification. It may describe the host in the cloud and specific container or an application running in the process.

!!! note
    Based on the specification on [Exempt Entities](https://opentelemetry.io/docs/reference/specification/common/#exempt-entities) of resource attributes, the type of `attributes` in `Resource` is limited to `NamedTuple` instead of [`BoundedAttributes`](@ref).
"""
Base.@kwdef struct Resource{A<:NamedTuple}
    attributes::A = OTEL_RESOURCE_ATTRIBUTES()
    schema_url::String = ""
end

#####

"""
    InstrumentationInfo(;name="Main", version=v"0.0.1-dev")

Usually used in an instrumentation package.
"""
Base.@kwdef struct InstrumentationInfo
    name::String = "OpenTelemetryAPI"
    version::VersionNumber = PKG_VERSION
    schema_url::String = ""
end
