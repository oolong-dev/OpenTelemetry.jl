mutable struct DataPoint{T,E}
    value::T
    start_time_unix_nano::UInt
    time_unix_nano::UInt
    exemplar_reservoir::E
    lock::ReentrantLock
end

function DataPoint{T}(exemplar_reservoir = nothing) where {T}
    t = UInt(time() * 10^9)
    DataPoint(zero(T), t, t, exemplar_reservoir, ReentrantLock())
end

DataPoint(v,s,t,e) = DataPoint(v,s,t,e, ReentrantLock())

function _add_to_datapoint!(p::DataPoint, v, t)
    lock(p.lock) do
        p.value += v
        p.time_unix_nano = t
    end
end

function _update_to_datapoint!(p::DataPoint, v, t)
    p.value = v
    p.time_unix_nano = t
end