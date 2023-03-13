export View

using Glob

struct Criteria
    instrument_type::Union{DataType,UnionAll,Nothing}
    instrument_name::Union{Glob.FilenameMatch{String},Nothing}
    meter_name::Union{String,Nothing}
    meter_version::Union{VersionNumber,Nothing}
    meter_schema_url::Union{String,Nothing}
end

function Base.occursin(ins::OpenTelemetryAPI.AbstractInstrument, c::Criteria)
    if !isnothing(c.instrument_type)
        if !(ins isa c.instrument_type)
            return false
        end
    end

    if !isnothing(c.instrument_name)
        if !occursin(c.instrument_name, ins.name)
            return false
        end
    end

    if !isnothing(c.meter_name)
        if ins.meter.name != c.meter_name
            return false
        end
    end

    if !isnothing(c.meter_version)
        if ins.meter.instrumentation_scope.version != c.meter_version
            return false
        end
    end

    if !isnothing(c.meter_schema_url)
        if ins.meter.instrumentation_scope.schema_url != c.meter_schema_url
            return false
        end
    end

    return true
end

struct View{A}
    name::Union{String,Nothing}
    description::Union{String,Nothing}
    criteria::Criteria
    attribute_keys::Union{Tuple{Vararg{String}},Nothing}
    extra_dimensions::StaticBoundedAttributes
    aggregation::A
end

"""
    View(name=nothing;kwargs...)

The `name` support wildcard.

See more details in [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/sdk.md#view).

## Keyword arguments

  - `description = nothing`,
  - `attribute_keys = nothing`,
  - `extra_dimensions = BoundedAttributes()`,
  - `aggregation = nothing`,
  - `instrument_name = nothing`,
  - `instrument_type = nothing`,
  - `meter_name = nothing`,
  - `meter_version = nothing`,
  - `meter_schema_url = nothing`,
"""
function View(
    name = nothing;
    description = nothing,
    attribute_keys = nothing,
    extra_dimensions = BoundedAttributes(),
    aggregation = nothing,
    # criteria
    instrument_name = nothing,
    instrument_type = nothing,
    meter_name = nothing,
    meter_version = nothing,
    meter_schema_url = nothing,
)
    if !isnothing(name)
        if isnothing(instrument_name)
            instrument_name = name
            if occursin(r"[*?\[\]]", name)
                # name contains wildcard
                name = nothing  # so that the name will be instrument name automatically
            end
        end
    end

    something(instrument_name, instrument_type, meter_name, meter_version, meter_schema_url)
    criteria = Criteria(
        instrument_type,
        isnothing(instrument_name) ? nothing : Glob.FilenameMatch(instrument_name),
        meter_name,
        meter_version,
        meter_schema_url,
    )
    View(name, description, criteria, attribute_keys, extra_dimensions, aggregation)
end
