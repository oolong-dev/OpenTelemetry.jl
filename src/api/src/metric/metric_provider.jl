export AbstractMeterProvider,
    global_meter_provider,
    Meter

abstract type AbstractMeterProvider end

Base.@kwdef struct DummyMeterProvider <: AbstractMeterProvider
end

Base.push!(p::DummyMeterProvider, x) = nothing

const GLOBAL_METER_PROVIDER = Ref(DummyMeterProvider())
global_meter_provider() = GLOBAL_METER_PROVIDER[]
global_meter_provider(p) = GLOBAL_METER_PROVIDER[] = p

abstract type AbstractInstrument{T} end

struct Meter{P<:AbstractMeterProvider}
    name::String
    provider::P
    version::VersionNumber
    schema_url::String
    instruments::Vector{AbstractInstrument}
    instrumentation_info::InstrumentationInfo
    function Meter(
        name::String
        ;provider::P=global_meter_provider(),
        version=v"0.0.1-dev",
        schema_url="",
        instrumentation_info=InstrumentationInfo(),
    ) where P <: AbstractMeterProvider
        m = new{P}(
            name,
            provider,
            version,
            schema_url,
            instrumentation_info,
        )
        push!(provider, m)
        m
    end
end

Base.push!(m::Meter, measurement) = push!(m.provider, measurement)
