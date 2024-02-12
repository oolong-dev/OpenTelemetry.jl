export BoundedAttributes, StaticBoundedAttributes, n_dropped

import TupleTools

"""
    BoundedAttributes(attrs; count_limit=nothing, value_length_limit=nothing)

This provides a wrapper around attributes (typically `AbstractDict` or `NamedTuple`) to follow the [specification of Attribute](https://opentelemetry.io/docs/reference/specification/common/#attribute).

The following methods from `Base` are defined on `BoundedAttributes` which are then forwarded to the inner `attrs` by default. Feel free to create a PR if you find any method you need is missing:

  - `Base.getindex`
  - `Base.setindex!`
  - `Base.iterate`
  - `Base.length`
  - `Base.haskey`
  - `Base.push!`. Obviously, an error will be thrown when calling on immutable `attrs`s like `NamedTuple`.
"""
mutable struct BoundedAttributes{T}
    attrs::T
    count_limit::Int
    value_length_limit::Int
    n_dropped::UInt32 # mutable
end

const StaticBoundedAttributes = BoundedAttributes{<:NamedTuple}

BoundedAttributes(; kw...) = BoundedAttributes(NamedTuple(); kw...)

_try_reorder(x) = x
_try_reorder(x::NamedTuple{()}) = x
_try_reorder(x::NamedTuple{K}) where {K} = x[TupleTools.sort(K)]

if VERSION < v"1.7.0"
    @inline Base.getindex(t::NamedTuple, idxs::Tuple{Vararg{Symbol}}) = NamedTuple{idxs}(t)
end

BoundedAttributes(attrs::BoundedAttributes; kw...) = attrs

function BoundedAttributes(
    attrs;
    count_limit = OTEL_ATTRIBUTE_COUNT_LIMIT(),
    value_length_limit = OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT(),
)
    attrs = _try_reorder(attrs) # !!! the order of static attributes is important in Metrics
    attrs, n_dropped = clean_attrs!(attrs, count_limit, value_length_limit)
    BoundedAttributes(attrs, count_limit, value_length_limit, UInt32(n_dropped))
end

Base.getindex(x::BoundedAttributes, args...) = getindex(x.attrs, args...)
Base.haskey(x::BoundedAttributes, k) = haskey(x.attrs, k)
Base.haskey(x::StaticBoundedAttributes, k::String) = haskey(x.attrs, Symbol(k))
Base.length(x::BoundedAttributes) = length(x.attrs)
Base.iterate(x::BoundedAttributes, args...) = iterate(x.attrs, args...)
Base.pairs(A::BoundedAttributes) = pairs(A.attrs)
Base.hash(x::BoundedAttributes, h::UInt) = hash(x.attrs, h)
Base.:(==)(x::BoundedAttributes, y::BoundedAttributes) = x.attrs == y.attrs

Base.merge(x::BoundedAttributes, y::BoundedAttributes) = BoundedAttributes(
    merge(x.attrs, y.attrs),
    x.count_limit,
    x.value_length_limit,
    x.n_dropped,
)

function Base.merge(x::StaticBoundedAttributes, y::StaticBoundedAttributes)
    attrs = merge(x.attrs, y.attrs)
    BoundedAttributes(
        attrs[TupleTools.sort(keys(attrs))],
        x.count_limit,
        x.value_length_limit,
        x.n_dropped,
    )
end

Base.show(io::IO, A::BoundedAttributes) = join(io, ("$k=$v" for (k, v) in pairs(A)), ",")

"""
Valid type of attribute value.
"""
const TAttrVal = Union{
    String,
    Bool,
    Int64,
    Int128,
    Float64,
    Vector{String},
    Vector{Bool},
    Vector{Int64},
    Vector{UInt8},
    Vector{Float64},
}

Base.setindex!(attrs::BoundedAttributes, v::AbstractString, k) =
    setindex!(attrs, string(v), k)
Base.setindex!(attrs::BoundedAttributes, v::Integer, k) =
    setindex!(attrs, convert(Int, v), k)
Base.setindex!(attrs::BoundedAttributes, v::AbstractFloat, k) =
    setindex!(attrs, convert(Float64, v), k)

function Base.setindex!(attrs::BoundedAttributes, v::TAttrVal, k)
    if !haskey(attrs, k) && length(attrs) >= attrs.count_limit
        clip_attrs_by_count!(attrs.attrs, attrs.count_limit - 1)
        attrs.n_dropped += 1
        @warn "The count of attributes exceeds the preset limit ($(attrs.count_limit))."
    end
    attrs.attrs[k] = _truncate(v, attrs.value_length_limit)
end

Base.setindex!(attrs::StaticBoundedAttributes, v::TAttrVal, k) =
    @error "Updating immutable attributes. Dropped."

"""
    n_dropped(x::BoundedAttributes)

Return the total number of dropped elements since creation.
"""
n_dropped(x::BoundedAttributes) = x.n_dropped

function clip_attrs_by_count!(attrs, count_limit)
    n_dropped = max(0, length(attrs) - count_limit)
    for k in Iterators.take(keys(attrs), n_dropped)
        delete!(attrs, k)
    end
    attrs, n_dropped
end

function clip_attrs_by_count!(attrs::NamedTuple, count_limit)
    n_dropped = max(0, length(attrs) - count_limit)
    NamedTuple(Iterators.drop(pairs(attrs), n_dropped)), n_dropped
end

_truncate(x, limit) = x

function _truncate(s::String, limit)
    if length(s) <= limit
        s
    else
        @warn "value is truncated to length $limit"
        s[1:min(end, limit)]
    end
end

function _truncate(attrs::Vector{String}, limit)
    is_truncated = false
    for (i, s) in enumerate(attrs)
        if length(s) > limit
            attrs[i] = s[1:limit]
            is_truncated = true
        end
    end
    is_truncated && @warn "some elements in the value are truncated."
    attrs
end

function clip_attrs_by_value_length!(attrs, value_length_limit)
    for k in keys(attrs)
        attrs[k] = _truncate(attrs[k], value_length_limit)
    end
    attrs
end

clip_attrs_by_value_length!(attrs::NamedTuple, value_length_limit) =
    map(x -> _truncate(x, value_length_limit), attrs)

"""
Follow the specification on [Attribute Limits](https://opentelemetry.io/docs/reference/specification/common/#attribute-limits). The cleaned attributes and the number of dropped elements is returned.

!!! warn
    
    If `attrs` is mutable, it may be modified in-place.
"""
function clean_attrs!(attrs, count_limit, value_length_limit)
    attrs, n_dropped = clip_attrs_by_count!(attrs, count_limit)
    attrs = clip_attrs_by_value_length!(attrs, value_length_limit)
    attrs, n_dropped
end