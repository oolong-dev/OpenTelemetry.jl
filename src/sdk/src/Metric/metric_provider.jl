struct MeterProvider <: API.AbstractMeterProvider
    resource::Resource
    instrumentation_info::InstrumentationInfo
    is_shut_down::Ref{Bool}
end

struct Meter
    name::String
    version::VersionNumber
    schema_url::String
end

Base.nameof(m::Meter) = m.name
API.version(m::Meter) = m.version
API.schema_url(m::Meter) = m.schema_url

struct Instrument
end

function API.get_meter(p::MeterProvider, name::String; version=v"0.0.1-dev", schema_url="")
    Meter(name,version,schema_url)
end
