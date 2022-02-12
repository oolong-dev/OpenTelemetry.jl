export AbstractMeterProvider,
    AbstractInstrument, global_meter_provider, global_meter_provider!, Meter

"""
A meter provider defines how to collect and update [`Measurement`](@ref)s. Each
meter provider should have the following interfaces implemented:

  - `Base.push!(provider, m::Meter)`, register a meter.
  - `Base.push!(provider, ins::AbstractInstrument)`, register an instrument.
  - `Base.push!(provider, (ins::AbstractInstrument, m::Measurement))`, update a measurement.
"""
abstract type AbstractMeterProvider end

Base.@kwdef struct DummyMeterProvider <: AbstractMeterProvider end

Base.push!(p::DummyMeterProvider, x) = nothing

const GLOBAL_METER_PROVIDER = Ref{AbstractMeterProvider}(DummyMeterProvider())

"""
    global_meter_provider()

Get the global meter provider.
"""
global_meter_provider() = GLOBAL_METER_PROVIDER[]

"""
    global_meter_provider!(p)

Set the global meter provider to `p`.
"""
global_meter_provider!(p) = GLOBAL_METER_PROVIDER[] = p

"""
`AbstractInstrument`` is the super type of all instruments, which are used to report [`Measurement`](@ref)s.

See also [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument):
"""
abstract type AbstractInstrument{T} end

"""
    Meter(name::String;kw...)

Meter is responsible for creating instruments.

## Keyword Arguments:

  - `provider::P = global_meter_provider()`
  - `version = v"0.0.1-dev"`
  - `schema_url = ""`
"""
struct Meter{P<:AbstractMeterProvider}
    name::String
    provider::P
    version::VersionNumber
    schema_url::String
    instruments::Vector{AbstractInstrument}
    function Meter(
        name::String;
        provider::P = global_meter_provider(),
        version = v"0.0.1-dev",
        schema_url = "",
    ) where {P<:AbstractMeterProvider}
        m = new{P}(name, provider, version, schema_url, AbstractInstrument[])
        push!(provider, m)
        m
    end
end
