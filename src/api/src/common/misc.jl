export Resource, InstrumentationInfo

"""
    Resource(;attributes=StaticAttrs(), schema_url="")

Quoted from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#resources):

> Resource captures information about the entity for which telemetry is recorded. For example, metrics exposed by a Kubernetes container can be linked to a resource that specifies the cluster, namespace, pod, and container name.
> 
> Resource may capture an entire hierarchy of entity identification. It may describe the host in the cloud and specific container or an application running in the process.
"""
Base.@kwdef struct Resource{A<:StaticAttrs}
    attributes::A = StaticAttrs()
    schema_url::String = ""
end

#####

"""
    InstrumentationInfo(;name="Main", version=v"0.0.1-dev")

Usually used in an instrumentation package.
"""
Base.@kwdef struct InstrumentationInfo
    name::String = "Main"
    version::VersionNumber = v"0.0.1-dev"
    schema_url::String = ""
end
