export AbstractMeterProvider,
    global_meter_provider,
    Meter,
    Counter,
    ObservableCounter,
    Histogram,
    ObservableGauge,
    UpDownCounter,
    ObservableUpDownCounter

struct Measurement{V}
    value::V
    attributes::Attributes
end

abstract type AbstractMeterProvider end

const GLOBAL_METER_PROVIDER = Ref{AbstractMeterProvider}(DefaultMeterProvider())
global_meter_provider() = GLOBAL_METER_PROVIDER[]
global_meter_provider(p::AbstractMeterProvider) = GLOBAL_METER_PROVIDER[] = p

#####

struct DefaultMeterProvider <: AbstractMeterProvider
end

create_meter(p::DefaultMeterProvider, name, version, schema_url) = Meter(p, name, version, schema_url, [])

function Base.put!(p::DefaultMeterProvider, measurement) end

#####

struct Meter{P<:AbstractMeterProvider}
    provider::P
    name::String
    version::VersionNumber
    schema_url::String
    instruments::Vector{Any}
end

Meter(name, version=v"0.0.1-dev", schema_url="") = create_meter(global_meter_provider(), name, version, schema_url)

Base.put!(meter::Meter, measurement) = put!(meter.provider, measurement)

#####

abstract type AbstractInstrument end
abstract type AbstractSyncInstrument <: AbstractInstrument end
abstract type AbstractAsyncInstrument <: AbstractInstrument end

is_sync_instrument(i::AbstractSyncInstrument) = true
is_sync_instrument(i::AbstractAsyncInstrument) = false

function examine_instrument(ins::AbstractInstrument;max_unit_length=63, max_description_length=1024)
    !isnothing(match(r"[a-zA-Z][_0-9a-zA-Z\\.\\-]{0,62}$", ins.name)) || throw(ArgumentError("invalid name: $(ins.name)"))
    length(ins.unit) <= max_unit_length || throw(ArgumentError("length of unit should be no more than $max_unit_length"))
    length(ins.description) <= max_description_length || throw(ArgumentError("length of description should be no more than $max_description_length"))
end

Base.put!(m::Meter, i::AbstractInstrument) = push!(m.instruments, i)

(ins::AbstractSyncInstrument)(amount; kw...) = ins(Measurement(amount, Attributes(kw...)))
(ins::AbstractSyncInstrument)(amount, args...) = ins(Measurement(amount, Attributes(args...)))
(ins::AbstractSyncInstrument)(m::Measurement) = put!(ins.meter, m)

(ins::AbstractAsyncInstrument)() = put!(ins.meter, ins => ins.callback())

#####

struct Counter{P<:AbstractMeterProvider} <: AbstractSyncInstrument
    meter::Meter{P}
    name::String
    unit::String
    description::String
    function Counter(meter, name; unit="", description="")
        c = new(meter, name, unit, description)
        examine_instrument(c)
        put!(meter, c)
        c
    end
end

function (c::Counter)(m::Measurement)
    if m.value < 0
        throw(ArgumentError("amount must be non-negative, got $amount"))
    end
    put!(c.meter, c => m)
end

struct ObservableCounter{F, P<:AbstractMeterProvider} <: AbstractAsyncInstrument
    callback::F
    meter::Meter{P}
    name::String
    unit::String
    description::String
    function ObservableCounter(callback, meter, name; unit="", description="")
        c = new(callback, meter, name, unit, description)
        examine_instrument(c)
        put!(meter, c)
        c
    end
end

struct Histogram{P<:AbstractMeterProvider} <: AbstractSyncInstrument
    meter::Meter{P}
    name::String
    unit::String
    description::String
    function Histogram(meter, name; unit="", description="")
        h = new(meter, name, unit, description)
        examine_instrument(h)
        put!(meter, h)
        h
    end
end

struct ObservableGauge{F, P<:AbstractMeterProvider} <: AbstractAsyncInstrument
    callback::F
    meter::Meter{P}
    name::String
    unit::String
    description::String
    function ObservableGauge(callback, meter, name; unit="", description="")
        g = new(callback, meter, name, unit, description)
        examine_instrument(g)
        put!(meter, g)
        g
    end
end

struct UpDownCounter{P<:AbstractMeterProvider} <: AbstractSyncInstrument
    meter::Meter{P}
    name::String
    unit::String
    description::String
    function UpDownCounter(meter, name; unit="", description="")
        c = new(meter, name, unit, description)
        examine_instrument(c)
        put!(meter, c)
        c
    end
end

struct ObservableUpDownCounter{F, P<:AbstractMeterProvider} <: AbstractAsyncInstrument
    callback::F
    meter::Meter{P}
    name::String
    unit::String
    description::String
    function ObservableUpDownCounter(callback, meter, name; unit="", description="")
        c = new(callback, meter, name, unit, description)
        examine_instrument(c)
        put!(meter, c)
        c
    end
end
