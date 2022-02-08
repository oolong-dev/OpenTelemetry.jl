export Resource, InstrumentationInfo

Base.@kwdef struct Resource{A<:StaticAttrs}
    attributes::A = StaticAttrs()
    schema_url::String = ""
end

#####

Base.@kwdef struct InstrumentationInfo
    name::String = "Main"
    version::VersionNumber = v"0.0.1-dev"
end
