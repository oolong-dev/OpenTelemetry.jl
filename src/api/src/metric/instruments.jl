export Measurement,
    Counter,
    ObservableCounter,
    Histogram,
    ObservableGauge,
    UpDownCounter,
    ObservableUpDownCounter

struct Measurement{V,T}
    value::V
    attributes::Attributes{T}
end

abstract type AbstractSyncInstrument{T} <: AbstractInstrument{T} end
abstract type AbstractAsyncInstrument{T} <: AbstractInstrument{T} end

function examine_instrument(
    ins::AbstractInstrument; max_unit_length=63, max_description_length=1024
)
    !isnothing(match(r"[a-zA-Z][_0-9a-zA-Z\\.\\-]{0,62}$", ins.name)) ||
        throw(ArgumentError("invalid name: $(ins.name)"))
    length(ins.unit) <= max_unit_length ||
        throw(ArgumentError("length of unit should be no more than $max_unit_length"))
    length(ins.description) <= max_description_length || throw(
        ArgumentError(
            "length of description should be no more than $max_description_length"
        ),
    )
end

(ins::AbstractSyncInstrument)(amount, args...) = ins(Measurement(amount, Attributes(args...)))
(ins::AbstractSyncInstrument)(m::Measurement) = push!(ins.meter, m)
(ins::AbstractAsyncInstrument)() = push!(ins.meter, ins => ins.callback())

#####

struct Counter{T} <: AbstractSyncInstrument{T}
    meter::Meter
    name::String
    unit::String
    description::String
    function Counter{T}(meter, name; unit="", description="") where {T}
        c = new{T}(meter, name, unit, description)
        examine_instrument(c)
        push!(meter, c)
        c
    end
end

function (c::Counter)(m::Measurement)
    if m.value < 0
        throw(ArgumentError("amount must be non-negative, got $amount"))
    end
    push!(c.meter, c => m)
end

struct ObservableCounter{T,F} <: AbstractAsyncInstrument{T}
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableCounter{T}(
        callback::F, meter, name; unit="", description=""
    ) where {T,F}
        c = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(c)
        push!(meter, c)
        c
    end
end

struct Histogram{T} <: AbstractSyncInstrument{T}
    meter::Meter
    name::String
    unit::String
    description::String
    function Histogram{T}(meter, name; unit="", description="") where {T}
        h = new{T}(meter, name, unit, description)
        examine_instrument(h)
        push!(meter, h)
        h
    end
end

struct ObservableGauge{T,F} <: AbstractAsyncInstrument{T}
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableGauge{T}(
        callback::F, meter, name; unit="", description=""
    ) where {T,F}
        g = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(g)
        push!(meter, g)
        g
    end
end

struct UpDownCounter{T} <: AbstractSyncInstrument{T}
    meter::Meter
    name::String
    unit::String
    description::String
    function UpDownCounter{T}(meter, name; unit="", description="") where {T}
        c = new{T}(meter, name, unit, description)
        examine_instrument(c)
        push!(meter, c)
        c
    end
end

struct ObservableUpDownCounter{T,F} <: AbstractAsyncInstrument{T}
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableUpDownCounter{T}(
        callback::F, meter, name; unit="", description=""
    ) where {T,F}
        c = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(c)
        push!(meter, c)
        c
    end
end
