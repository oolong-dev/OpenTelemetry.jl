export AbstractAsyncInstrument,
    AbstractSyncInstrument,
    Measurement,
    Counter,
    ObservableCounter,
    Histogram,
    ObservableGauge,
    UpDownCounter,
    ObservableUpDownCounter

"""
    Measurement(value, [attributes=StaticAttrs()])

This is to follow [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#measurement)

See also [StaticAttrs](@ref)
"""
struct Measurement{V,T<:StaticAttrs}
    value::V
    attributes::T
end

Measurement(v) = Measurement(v, StaticAttrs())

"""
Sync instrument usually pass its measurement immediately.
"""
abstract type AbstractSyncInstrument{T} <: AbstractInstrument{T} end

"""
Async instrument usually has a callback function (which is named *Observable* in
OpenTelemetry) to get its measurement.

!!! note
    
    If the return of the callback function is not a [`Measurement`](@ref),
    it will be converted into a `Measurement` with an empty
    [`StaticAttrs`](@ref) implicitly when being uploaded to the associated meter
    provider.
"""
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

"""
    Counter{T}(name, meter;unit="", description="") where T

`Counter` is a [`AbstractSyncInstrument`](@ref) which supports non-negative increments.

See more details from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#counter).
"""
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

"""
    ObservableCounter{T}(callback, name, meter; unit = "", description = "") where {T}

`ObservableCounter` is an [`AbstractAsyncInstrument`](@ref) which reports monotonically increasing value(s) when the instrument is being observed.

See more details from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#asynchronous-counter)
"""
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

"""
    Histogram{T}(name, meter; unit = "", description = "") where {T}

`Histogram`` is `AbstractSyncInstrument` which can be used to report arbitrary values that are likely to be statistically meaningful. It is intended for statistics such as histograms, summaries, and percentile.

See more details from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#histogram)
"""
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

"""
    ObservableGauge{T}(callback, name, meter; unit = "", description = "",) where {T}

`ObservableGauge` is an [`AbstractAsyncInstrument`](@ref) which reports non-additive value(s) (e.g. the room temperature - it makes no sense to report the temperature value from multiple rooms and sum them up) when the instrument is being observed.

See also the details from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#asynchronous-gauge)
"""
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

"""
    UpDownCounter{T}(name, meter; unit = "", description = "") where {T}

`UpDownCounter` is a [`AbstractSyncInstrument`](@ref) which supports increments and decrements.

See also the details from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#updowncounter).
"""
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

"""
    ObservableUpDownCounter{T}(callback, name, meter; unit = "", description = "") where {T}

`ObservableUpDownCounter` is an [`AbstractAsyncInstrument`](@ref) which reports additive value(s) (e.g. the process heap size - it makes sense to report the heap size from multiple processes and sum them up, so we get the total heap usage) when the instrument is being observed.

See more details from [the specification](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#asynchronous-updowncounter).
"""
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
