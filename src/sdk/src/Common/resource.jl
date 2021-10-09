export Resource

using OpenTelemetryAPI

Base.@kwdef struct Resource
    attributes::Attributes = Attributes()
    schema_url::String = ""
end