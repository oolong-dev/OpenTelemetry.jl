export AbstractAsyncInstrument,
    AbstractSyncInstrument,
    Measurement,
    Counter,
    ObservableCounter,
    Histogram,
    ObservableGauge,
    UpDownCounter,
    ObservableUpDownCounter

struct Measurement{V,T<:StaticAttrs}
    value::V
    attributes::T
end

Measurement(v) = Measurement(v, StaticAttrs())

abstract type AbstractSyncInstrument{T} <: AbstractInstrument{T} end
abstract type AbstractAsyncInstrument{T} <: AbstractInstrument{T} end

function examine_instrument(
    ins::AbstractInstrument;
    max_unit_length = 63,
    max_description_length = 1024,
)
    !isnothing(match(r"[a-zA-Z][_0-9a-zA-Z\\.\\-]{0,62}$", ins.name)) ||
        throw(ArgumentError("invalid name: $(ins.name)"))
    length(ins.unit) <= max_unit_length ||
        throw(ArgumentError("length of unit should be no more than $max_unit_length"))
    length(ins.description) <= max_description_length || throw(
        ArgumentError(
            "length of description should be no more than $max_description_length",
        ),
    )
end

(ins::AbstractSyncInstrument)(amount; kw...) =
    ins(Measurement(amount, StaticAttrs(values(kw))))
(ins::AbstractSyncInstrument)(m::Measurement) = push!(ins.meter.provider, ins => m)

(ins::AbstractAsyncInstrument)() = push!(ins.meter.provider, ins => ins.callback())

#####

struct Counter{T} <: AbstractSyncInstrument{T}
    meter::Meter
    name::String
    unit::String
    description::String
    function Counter{T}(name, meter; unit = "", description = "") where {T}
        c = new{T}(meter, name, unit, description)
        examine_instrument(c)
        push!(meter.provider, c)
        c
    end
end

(c::Counter{T})(; kw...) where {T} = c(one(T); kw...)

function (c::Counter)(m::Measurement)
    if m.value < 0
        throw(ArgumentError("amount must be non-negative, got $(m.value)"))
    end
    push!(c.meter.provider, c => m)
end

struct ObservableCounter{T,F} <: AbstractAsyncInstrument{T}
    callback::F
    meter::Meter
    name::String
    unit::String
    description::String
    function ObservableCounter{T}(
        callback::F,
        name,
        meter;
        unit = "",
        description = "",
    ) where {T,F}
        c = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(c)
        push!(meter.provider, c)
        c
    end
end

struct Histogram{T} <: AbstractSyncInstrument{T}
    meter::Meter
    name::String
    unit::String
    description::String
    function Histogram{T}(name, meter; unit = "", description = "") where {T}
        h = new{T}(meter, name, unit, description)
        examine_instrument(h)
        push!(meter.provider, h)
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
        callback::F,
        name,
        meter;
        unit = "",
        description = "",
    ) where {T,F}
        g = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(g)
        push!(meter.provider, g)
        g
    end
end

struct UpDownCounter{T} <: AbstractSyncInstrument{T}
    meter::Meter
    name::String
    unit::String
    description::String
    function UpDownCounter{T}(name, meter; unit = "", description = "") where {T}
        c = new{T}(meter, name, unit, description)
        examine_instrument(c)
        push!(meter.provider, c)
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
        callback::F,
        name,
        meter;
        unit = "",
        description = "",
    ) where {T,F}
        c = new{T,F}(callback, meter, name, unit, description)
        examine_instrument(c)
        push!(meter.provider, c)
        c
    end
end
