export global_meter_provider,
    get_meter,
    create_counter,
    create_up_down_counter,
    create_histogram,
    create_observable_counter,
    create_observable_gauge,
    create_observable_up_down_counter,
    is_sync_instrument,
    is_valid_instrument_name,
    is_valid_instrument_unit,
    is_valid_instrument_description

using Base.Threads

struct Measurement{V}
    value::V
    attributes::Attributes
end

abstract type AbstractMeterProvider end

struct DefaultMeterProvider <: AbstractMeterProvider
end

const GLOBAL_METER_PROVIDER = Ref{AbstractMeterProvider}(DefaultMeterProvider())

global_meter_provider() = GLOBAL_METER_PROVIDER[]
global_meter_provider(p::AbstractMeterProvider) = GLOBAL_METER_PROVIDER[] = p

get_meter(name) = get_meter(name, global_meter_provider())
get_meter(name, ::DefaultMeterProvider) = DefaultMeter(name)

abstract type AbstractMeter end

struct DefaultMeter <: AbstractMeter
    name::String
end

Base.nameof(m::DefaultMeter) = m.name
version(m::DefaultMeter) = v"0.0.0-dev"
schema_url(m::DefaultMeter) = ""


abstract type AbstractInstrument end
abstract type AbstractSyncInstrument <: AbstractInstrument end
abstract type AbstractAsyncInstrument <: AbstractInstrument end

is_sync_instrument(i::AbstractSyncInstrument) = true
is_sync_instrument(i::AbstractAsyncInstrument) = false

is_valid_instrument_name(name) = !isnothing(match(r"[a-zA-Z][_0-9a-zA-Z\\.\\-]{0,62}$", name))
is_valid_instrument_unit(unit) = length(unit) <= 63
is_valid_instrument_description(d) = length(d) <=1024

# Default dummy implementations

struct DefaultCounter{T} <: AbstractSyncInstrument
    name::String
    unit::String
    description::String
end

function create_counter(::DefaultMeter, name; unit="", description="", value_type=Int)
    is_valid_instrument_name(name) || throw(ArgumentError("invalid name: $name"))
    is_valid_instrument_unit(unit) || throw(ArgumentError("invalid unit: $unit"))
    is_valid_instrument_description(description) || throw(ArgumentError("invalid description: $description"))
    DefaultCounter{value_type}(name, unit, description)
end

add!(c::DefaultCounter, amount;kw...) = add!(c, amount, Attributes(kw...))

function add!(c::DefaultCounter, amount, attrs::Attributes)
    if amount < 0
        throw(ArgumentError("amount must be non-negative, got $amount"))
    end
end

struct DefaultObservableCounter{F} <: AbstractAsyncInstrument
    name::String
    unit::String
    description::String
    callback::F
end

function create_observable_counter(::DefaultMeter, callback, name; unit="", description="")
    is_valid_instrument_name(name) || throw(ArgumentError("invalid name: $name"))
    is_valid_instrument_unit(unit) || throw(ArgumentError("invalid unit: $unit"))
    is_valid_instrument_description(description) || throw(ArgumentError("invalid description: $description"))
    DefaultObservableCounter(name, unit, description, callback)
end

(c::DefaultObservableCounter)() = c.callback()

struct DefaultHistogram <: AbstractSyncInstrument
    name::String
    unit::String
    description::String
end

function create_histogram(::DefaultMeter, name; unit="", description="")
    is_valid_instrument_name(name) || throw(ArgumentError("invalid name: $name"))
    is_valid_instrument_unit(unit) || throw(ArgumentError("invalid unit: $unit"))
    is_valid_instrument_description(description) || throw(ArgumentError("invalid description: $description"))
    DefaultHistogram(name, unit, description)
end

record(h::DefaultHistogram, val;kw...) = record(h, val, Attributes(kw...))
function record(h::DefaultHistogram, val, attrs) end

struct DefaultObservableGauge{F} <: AbstractAsyncInstrument
    name::String
    unit::String
    description::String
    callback::F
end

function create_observable_gauge(::DefaultMeter, callback, name; unit="", description="")
    is_valid_instrument_name(name) || throw(ArgumentError("invalid name: $name"))
    is_valid_instrument_unit(unit) || throw(ArgumentError("invalid unit: $unit"))
    is_valid_instrument_description(description) || throw(ArgumentError("invalid description: $description"))
    DefaultObservableGauge(name, unit, description, callback)
end

(c::DefaultObservableGauge)() = c.callback()

struct DefaultUpDownCounter{T} <: AbstractSyncInstrument
    name::String
    unit::String
    description::String
end

function create_up_down_counter(::DefaultMeter, name; unit="", description="", value_type=Int)
    is_valid_instrument_name(name) || throw(ArgumentError("invalid name: $name"))
    is_valid_instrument_unit(unit) || throw(ArgumentError("invalid unit: $unit"))
    is_valid_instrument_description(description) || throw(ArgumentError("invalid description: $description"))
    DefaultUpDownCounter{value_type}(name, unit, description)
end

add!(c::DefaultUpDownCounter, amount;kw...) = add!(c, amount, Attributes(kw...))
function add!(c::DefaultUpDownCounter, amount, attrs) end

struct DefaultObservableUpDownCounter{F} <: AbstractAsyncInstrument
    name::String
    unit::String
    description::String
    callback::F
end

function create_observable_up_down_counter(::DefaultMeter, callback, name; unit="", description="")
    is_valid_instrument_name(name) || throw(ArgumentError("invalid name: $name"))
    is_valid_instrument_unit(unit) || throw(ArgumentError("invalid unit: $unit"))
    is_valid_instrument_description(description) || throw(ArgumentError("invalid description: $description"))
    DefaultObservableUpDownCounter(name, unit, description, callback)
end

(c::DefaultObservableUpDownCounter)() = c.callback()