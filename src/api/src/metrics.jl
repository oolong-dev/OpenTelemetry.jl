export AbstractMeterProvider,
    AbstractInstrument,
    Meter,
    Measurement,
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

#####

abstract type AbstractMeterProvider end

#####

struct Meter
    name::String
    version::VersionNumber
    schema_url::String
    instruments::Vector{Any}
    instrumentation_info::InstrumentationInfo
    provider::Ref{AbstractMeterProvider}
end

struct DefaultMeterProvider <: AbstractMeterProvider
    meters::Dict{String, Meter}
end

Base.getindex(p::DefaultMeterProvider, m::String) = p.meters[m]
Base.push!(p::DefaultMeterProvider, m::Meter) = p.meters[m.name] = m
Base.put!(p::DefaultMeterProvider, x) = nothing

Base.bind(m::Meter, p::AbstracterProvider) = bind(p, m)
function Base.bind(p::AbstracterProvider, m::Meter)
    push!(p, m)
    m.provider[] = p
end

function Meter(
    name;
    version=v"0.0.1-dev",
    schema_url="",
    instrumentation_info=InstrumentationInfo(),
    provider=DefaultMeterProvider()
)
    m = Meter(name, version, schema_url, [], instrumentation_info, Ref(provider))
    bind(m, provider)
    m
end

Base.put!(m::Meter, x) = put!(m.provider[], x)

#####

abstract type AbstractInstrument{T} end
abstract type AbstractSyncInstrument{T} <: AbstractInstrument{T} end
abstract type AbstractAsyncInstrument{T} <: AbstractInstrument{T} end

function examine_instrument(ins::AbstractInstrument;max_unit_length=63, max_description_length=1024)
    !isnothing(match(r"[a-zA-Z][_0-9a-zA-Z\\.\\-]{0,62}$", ins.name)) || throw(ArgumentError("invalid name: $(ins.name)"))
    length(ins.unit) <= max_unit_length || throw(ArgumentError("length of unit should be no more than $max_unit_length"))
    length(ins.description) <= max_description_length || throw(ArgumentError("length of description should be no more than $max_description_length"))
end

(ins::AbstractSyncInstrument)(amount; kw...) = ins(Measurement(amount, Attributes(kw...)))
(ins::AbstractSyncInstrument)(amount, args...) = ins(Measurement(amount, Attributes(args...)))
(ins::AbstractSyncInstrument)(m::Measurement) = put!(ins.meter, m)

(ins::AbstractAsyncInstrument)() = put!(ins.meter, ins => ins.callback())

#####

struct Counter{T} <: AbstractSyncInstrument
    meter::Meter
    name::String
    unit::String
    description::String
    function Counter{T}(meter, name; unit="", description="") where {T}
        c = new{T}(meter, name, unit, description)
        examine_instrument(c)
        push!(meter.instruments, c)
        c
    end
end

function (c::Counter)(m::Measurement)
    if m.value < 0
        throw(ArgumentError("amount must be non-negative, got $amount"))
    end
    put!(c.meter, c => m)
end

struct ObservableCounter{T,F} <: AbstractAsyncInstrument
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableCounter{T}(callback::F, meter, name; unit="", description="") where {T,F}
        c = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(c)
        push!(meter.instruments, c)
        c
    end
end

struct Histogram{T} <: AbstractSyncInstrument
    meter::Meter
    name::String
    unit::String
    description::String
    function Histogram{T}(meter, name; unit="", description="") where T
        h = new{T}(meter, name, unit, description)
        examine_instrument(h)
        push!(meter.instruments, h)
        h
    end
end

struct ObservableGauge{T,F} <: AbstractAsyncInstrument
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableGauge{T}(callback::F, meter, name; unit="", description="") where {T,F}
        g = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(g)
        push!(meter.instruments, g)
        g
    end
end

struct UpDownCounter{T} <: AbstractSyncInstrument
    meter::Meter
    name::String
    unit::String
    description::String
    function UpDownCounter{T}(meter, name; unit="", description="") where T
        c = new{T}(meter, name, unit, description)
        examine_instrument(c)
        push!(meter.instruments, c)
        c
    end
end

struct ObservableUpDownCounter{T,F} <: AbstractAsyncInstrument
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableUpDownCounter{T}(callback::F, meter, name; unit="", description="") where {T, F}
        c = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(c)
        push!(meter.instruments, c)
        c
    end
end
