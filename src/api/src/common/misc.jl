export Resource, InstrumentationScope

"""
    Resource(;attributes=nothing, schema_url="")

Quoted from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/overview.md#resources):

> Resource captures information about the entity for which telemetry is recorded. For example, metrics exposed by a Kubernetes container can be linked to a resource that specifies the cluster, namespace, pod, and container name.
> 
> Resource may capture an entire hierarchy of entity identification. It may describe the host in the cloud and specific container or an application running in the process.
"""
struct Resource
    attributes::BoundedAttributes
    schema_url::String
end

Resource(
    attrs::NamedTuple = NamedTuple();
    schema_url = "",
    default_attributes = OTEL_RESOURCE_ATTRIBUTES(),
) = Resource(
    # ref: https://opentelemetry.io/docs/reference/specification/common/#exempt-entities
    BoundedAttributes(
        merge(default_attributes, attrs);
        count_limit = typemax(Int),
        value_length_limit = typemax(Int),
    ),
    schema_url,
)

function Base.merge(r1::Resource, r2::Resource)
    schema_url = if isempty(r1.schema_url)
        r2.schema_url
    elseif isempty(r2.schema_url)
        r1.schema_url
    else
        if r2.schema_url != r1.schema_url
            @warn "Conflict resource schema url: old -> $(r1.schema_url), new -> $(r2.schema_url). The later is used!"
        end
        r2.schema_url
    end
    Resource(merge(r1.attributes, r2.attributes), schema_url)
end

Base.:(==)(r1::Resource, r2::Resource) =
    r1.attributes == r2.attributes && r1.schema_url == r2.schema_url

#####

"""
    InstrumentationScope(;name="OpenTelemetryAPI", version=<default>, schema_url="", attributes=BoundedAttributes())

Usually used in an instrumentation package.
"""
Base.@kwdef struct InstrumentationScope
    name::String = "OpenTelemetryAPI"
    version::VersionNumber = PKG_VERSION
    schema_url::String = ""
    attributes::BoundedAttributes = BoundedAttributes()
end
