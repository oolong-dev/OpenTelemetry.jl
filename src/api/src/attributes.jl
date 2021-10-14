export Attributes, Limited

struct Limited{T}
    xs::T
    limit::Int
    n_dropped::Ref{Int}
end

Base.getindex(x::Limited, args...) = getindex(x.xs, args...)
n_dropped(x::Limited) = x.n_dropped[]

function Base.setindex!(x::Limited{<:AbstractDict}, v, k)
    if haskey(x.xs, k)
        setindex!(x.xs, v, k)
    elseif length(x.xs) >= x.limit
        @warn "limit exceeded, dropped."
        x.n_dropped[] += 1
    else
        setindex!(x.xs, v, k)
    end
end

function Base.push!(x::Limited{<:AbstractVector}, v)
    if length(x.xs) >= xs.limit
        @warn "limit exceeded, dropped."
        x.n_dropped[] += 1
    else
        push!(x.xs, v)
    end
end

function Limited(xs::NamedTuple, limit=32)
    n_dropped = Ref(0)
    if length(xs) > limit
        n_dropped[] = length(xs) - limit
        xs = NamedTuple{keys(xs)[1:limit]}(values(xs)[1:limit])
    end
    Limited(xs, limit, n_dropped)
end

function Limited(xs::Union{Dict,AbstractVector}, limit=32)
    n_dropped = Ref(0)
    if length(xs) > limit
        n_dropped[] = length(xs) - limit
        for _ in 1:(length(xs)-limit)
            pop!(xs)
        end
    end
    Limited(xs, limit, n_dropped)
end

struct Attributes{T}
    kv::Limited{T}
    value_length_limit::Int
end

n_dropped(a::Attributes) = n_dropped(a.kv)

_truncate(x, limit) = x

function _truncate(s::String, limit)
    if length(s) <= limit
        s
    else
        @warn "value is truncated to length $limit"
        s[1:min(end,limit)]
    end
end

function _truncate(xs::Vector{String}, limit)
    is_truncated = false
    for (i,s) in enumerate(xs)
        if length(s) > limit
            xs[i] = s[1:limit]
            is_truncated = true
        end
    end
    is_truncated && @warn "some elements in the value are truncated."
    xs
end

const TAttrVal = Union{
    String,
    Bool,
    Int64,
    Float64,
    Vector{String},
    Vector{Bool},
    Vector{Int64},
    Vector{Float64}
}


"""
    Attributes(kv::Pair{String,<:TAttrVal}...;count_limit=128, value_length_limit=typemax(Int), is_mutable=false)

Tha value type must be either `String`, `Bool`, `Int`, `Float64` or a `Vector` of above types. By default, we use a `NamedTuple` to represent the key-value pairs and they are sorted to allow for comparison. If `is_mutable` is set to `true`, we'll use a `Dict` instead internally. If the value is of type `String` or `Vector{String}`, then each entry with length bigger than `value_length_limit` will be truncated.
"""
function Attributes(
    kv::Pair{String,<:Union{TAttrVal, Attributes}}...
    ;count_limit=128,
    value_length_limit=typemax(Int),
    is_mutable=false
)
    kv_truncated = (k=>_truncate(v, value_length_limit) for (k, v) in kv)
    if is_mutable
        data = Limited(Dict{String,TAttrVal}(kv_truncated), count_limit)
    else
        data = Limited(NamedTuple(Symbol(k) => v for (k,v) in sort(kv_truncated)), count_limit)
    end
    Attributes(data, value_length_limit)
end

Base.getindex(d::Attributes, k::String) = getindex(d.kv, k)
Base.getindex(d::Attributes{<:NamedTuple}, k::String) = getindex(d.kv, Symbol(k))

function Base.setindex!(d::Attributes{<:Dict}, k::String, v::TAttrVal)
    v = _truncate(v, d.value_length_limit)
    d.kv[k] = v
end

Base.:(==)(a::Attributes, b::Attributes) = a.kv.xs == b.kv.xs
Base.hash(a::Attributes, h) = hash(a.kv.xs, h)
