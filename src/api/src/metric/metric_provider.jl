export global_meter_provider, global_meter_provider, Meter, provider, resource

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

resource(::DummyMeterProvider) = Resource()

const GLOBAL_METER_PROVIDER = Ref{AbstractMeterProvider}(DummyMeterProvider())

"""
    global_meter_provider()

Get the global meter provider.
"""
global_meter_provider() = GLOBAL_METER_PROVIDER[]

"""
    global_meter_provider(p)

Set the global meter provider to `p`.
"""
global_meter_provider(p) = GLOBAL_METER_PROVIDER[] = p

"""
`AbstractInstrument`` is the super type of all instruments, which are used to report [`Measurement`](@ref)s.

Each concrete subtype should at least have the following fields:

  - `name`
  - `description`
  - `unit`
  - `meter`, the associated [`Meter`](@ref)

See also [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#instrument):
"""
abstract type AbstractInstrument{T} end

provider(ins::AbstractInstrument) = provider(ins.meter)
resource(ins::AbstractInstrument) = resource(ins.meter)

"""
    Meter(name::String;kw...)

Meter is responsible for creating instruments.

## Keyword Arguments:

  - `provider::P = global_meter_provider()`
  - `instrumentation_scope = InstrumentationScope()`
"""
struct Meter{P<:AbstractMeterProvider}
    name::String
    provider::P
    instrumentation_scope::InstrumentationScope
    instruments::Vector{AbstractInstrument}
    function Meter(
        name::String;
        provider::P = global_meter_provider(),
        instrumentation_scope = InstrumentationScope(),
    ) where {P<:AbstractMeterProvider}
        m = new{P}(name, provider, instrumentation_scope, AbstractInstrument[])
        push!(provider, m)
        m
    end
end

function Base.push!(m::Meter, ins::AbstractInstrument)
    push!(m.instruments, ins)
    push!(m.provider, ins)
end

Base.push!(m::Meter, ms::Pair{<:AbstractInstrument}) = push!(m.provider, ms)

provider(m::Meter) = m.provider

resource(m::Meter) = resource(provider(m))
