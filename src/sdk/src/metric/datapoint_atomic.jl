mutable struct DataPoint{T,E}
    @atomic value::T
    start_time_unix_nano::UInt
    time_unix_nano::UInt
    exemplar_reservoir::E
end

function DataPoint{T}(exemplar_reservoir = nothing) where {T}
    t = UInt(time() * 10^9)
    DataPoint(zero(T), t, t, exemplar_reservoir)
end

function _add_to_datapoint!(p::DataPoint, v, t)
    @atomic p.value += v
    p.time_unix_nano = t
end

function _update_to_datapoint!(p::DataPoint, v, t)
    @atomic p.value = v
    p.time_unix_nano = t
end