Base.@kwdef struct Resource
    attributes::API.Attributes = API.Attributes()
    schema_url::String = ""
end