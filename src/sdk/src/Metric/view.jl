abstract type AbstractAggregation end

struct Reservoir{T,R}
    pool::Vector{T}
    size::Int
    rng::R
end

struct Criteria
    instrument_type::Union{DataType,Nothing}
    instrument_name::Union{Regex,Nothing}
    meter_name::Union{Regex, Nothing}
    meter_version_bound::Union{Tuple{VersionNumber,VersionNumber}, Nothing}
    meter_schema_url::Union{Regex, Nothing}
end

struct ViewConfig{A<:AbstractAggregation}
    name::String
    description::String
    criteria::Criteria
    attribute_keys::Tuple{Vararg{String}}
    extra_dimensions::Attributes
    aggregation::A
    # TODO
    # exemplar_reservoir::
end
