export current_context,
    with_context,
    Limited,
    n_dropped,
    TAttrVal,
    DynamicAttrs,
    StaticAttrs,
    Resource,
    InstrumentationInfo

using UUIDs: uuid4

const CONTEXT_KEY = :OPEN_TELEMETRY_CONTEXT

# ??? performace issue with NamedTuple
struct Context{T<:NamedTuple}
    kv::T
end

Context() = Context(NamedTuple())

Base.merge(c1::Context, c2::Context) = Context(merge(c1.kv, c2.kv))

create_key(s) = Symbol(s, '-', uuid4())

for f in (:getindex, :haskey, :get)
    @eval Base.$f(ctx::Context, args...) = $f(ctx.kv, args...)
end

with_context(f; kv...) = with_context(f, current_context(); kv...)

"""
    with_context(f, [context]; kv...)

Run function `f` in the `context`. If extra `kv` pairs are provided, they will be merged with the `context` to form a new context. When `context` is not provided, the [`current_context`](@ref) will be used.
"""
function with_context(f, ctx::Context; kw...)
    task_local_storage(CONTEXT_KEY, merge(ctx, Context(values(kw)))) do
        f()
    end
end

"""
Return the `Context` associated with the caller's current execution unit.
"""
current_context() = get!(task_local_storage(), CONTEXT_KEY, Context())

# !!! intentional type piracy
function Base.schedule(t::Task)
    if isnothing(t.storage)
        t.storage = IdDict()
    end
    t.storage[CONTEXT_KEY] = current_context()
    Base.enq_work(t)
end

#####

"""
    Limited(container; limit=32)

Create a container wrapper with limited elements. It supports the following common containers:

  - `AbstractDict`. If the length of the dict contains more elements than `limit`. Then `pop!` will be called repeatedly until the length is equal to `limit`. Further new key-value pair insertions will be ignored. If the key already exists in the dict, then the corresponding value will always be updated. `n_dropped` will return the number of dropped insertions.
  - `AbstractVector`. Similar to `AbstractDict`.

The following methods from `Base` are defined on `Limited` which are then forwarded to the inner `container`. Feel free to create a PR if you find any method you need is missing:

  - `Base.getindex`
  - `Base.setindex!`
  - `Base.iterate`
  - `Base.length`
  - `Base.haskey`
  - `Base.push!`. Only defined on containers of `AbstractVector`.
"""
struct Limited{T}
    xs::T
    limit::Int
    n_dropped::Ref{Int}
end

function Limited(xs::Union{Dict,AbstractVector}; limit = 32)
    n_dropped = Ref(0)
    if length(xs) > limit
        n_dropped[] = length(xs) - limit
        for _ = 1:(length(xs)-limit)
            pop!(xs)
        end
    end
    Limited(xs, limit, n_dropped)
end

Base.getindex(x::Limited, args...) = getindex(x.xs, args...)
Base.haskey(x::Limited, k) = haskey(x.xs, k)
Base.length(x::Limited) = length(x.xs)
Base.iterate(x::Limited, args...) = iterate(x.xs, args...)
Base.pairs(A::Limited) = pairs(A.xs)

"""
Return the total number of dropped elements since creation.
"""
n_dropped(x::Limited) = x.n_dropped[]

function Base.setindex!(x::Limited{<:AbstractDict}, v, k)
    if haskey(x.xs, k)
        setindex!(x.xs, v, k)
    elseif length(x.xs) >= x.limit
        @warn "limit [$(x.limit)] exceeded, dropped."
        x.n_dropped[] += 1
    else
        setindex!(x.xs, v, k)
    end
end

Base.setindex!(x::Limited{<:AbstractVector}, v, k) = setindex!(x.xs, v, k)

function Base.push!(x::Limited{<:AbstractVector}, v)
    if length(x.xs) >= x.limit
        @warn "limit [$(x.limit)] exceeded, dropped."
        x.n_dropped[] += 1
    else
        push!(x.xs, v)
    end
end

#####

_truncate(x, limit) = x

function _truncate(s::String, limit)
    if length(s) <= limit
        s
    else
        @warn "value is truncated to length $limit"
        s[1:min(end, limit)]
    end
end

function _truncate(xs::Vector{String}, limit)
    is_truncated = false
    for (i, s) in enumerate(xs)
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
    Vector{Float64},
}

is_valid_attr_val(nt::NamedTuple) = is_valid_attr_val(values(nt))
is_valid_attr_val(t::Tuple) = is_valid_attr_val(first(t)) && is_valid_attr_val(Base.tail(t))
is_valid_attr_val(x::TAttrVal) = true
is_valid_attr_val(t::Tuple{}) = true
is_valid_attr_val(x) = false

"""
    StaticAttrs(attrs::NamedTuple; value_length_limit=nothing)
    StaticAttrs(attrs::Pair{String, TAttrVal}...; value_length_limit=nothing)
    StaticAttrs(attrs::Pair{Symbol, TAttrVal}...; value_length_limit=nothing)

Here we use the `NamedTuple` internally to efficiently represent the immutable version of the [`Attributes`](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/common.md#attributes) specification. If the `value_length_limit` is set to a positive int, the value of `String` or each element in a value of `Vector{String}` will be truncated to a maximum length of `value_length_limit`. By default we do not do the truncation.

See also [`DynamicAttrs`](@ref).
"""
struct StaticAttrs{T<:NamedTuple}
    attrs::T
    function StaticAttrs(attrs::T; value_length_limit = nothing) where {T<:NamedTuple}
        if is_valid_attr_val(attrs)
            if !isnothing(value_length_limit)
                attrs = map(x -> _truncate(x, value_length_limit), attrs)
            end
            new{T}(attrs)
        else
            throw(ArgumentError("Invalid value type found!"))
        end
    end
end

function Base.show(io::IO, s::StaticAttrs)
    print(io, "StaticAttrs")
    if isempty(s.attrs)
        print(io, "()")
    else
        print(io, s.attrs)
    end
end

StaticAttrs(; kw...) = StaticAttrs(NamedTuple(); kw...)

n_dropped(a::StaticAttrs) = 0

Base.keys(A::StaticAttrs) = keys(A.attrs)
Base.getindex(A::StaticAttrs, k::String) = getindex(A, Symbol(k))
Base.getindex(A::StaticAttrs, k::Symbol) = getindex(A.attrs, k)
Base.getindex(A::StaticAttrs, k::Tuple{Vararg{Symbol}}) =
    StaticAttrs(NamedTuple{k}(A.attrs))
Base.length(A::StaticAttrs) = length(A.attrs)
Base.iterate(A::StaticAttrs, args...) = iterate(A.attrs, args...)
Base.pairs(A::StaticAttrs) = pairs(A.attrs)

# ??? a more efficient approach?
Base.sort(A::StaticAttrs) = A[keys(A)|>collect|>sort|>Tuple]

"""
    DynamicAttrs(attrs::Dict{String, TAttrVal};count_limit=128, value_length_limit=nothing)
    DynamicAttrs(attrs::Pair{String, TAttrVal}...;count_limit=128, value_length_limit=nothing)

Here we use a `Dict` internally to represent the mutable version of the [`Attributes`](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/common.md#attributes) specification. If the `value_length_limit` is set to a positive int, the value of `String` or each element in a value of `Vector{String}` will be truncated to a maximum length of `value_length_limit`. By default we do not do the truncation. When adding new pairs into it, if the number of attributes exceeds the `count_limit`, it will be dropped. You can get the number of dropped pairs via `n_dropped`.
"""
struct DynamicAttrs
    attrs::Limited{Dict{String,TAttrVal}}
    value_length_limit::Union{Int,Nothing}
    function DynamicAttrs(
        d::Dict{String,TAttrVal};
        count_limit = 128,
        value_length_limit = nothing
    )
        if !isnothing(value_length_limit)
            for k in keys(d)
                d[k] = _truncate(d[k], value_length_limit)
            end
        end
        new(Limited(d; limit = count_limit), value_length_limit)
    end
end

DynamicAttrs(attrs::Pair{String}...; kw...) =
    DynamicAttrs(Dict{String,TAttrVal}(attrs...); kw...)

Base.getindex(A::DynamicAttrs, k::String) = getindex(A.attrs, k)
Base.haskey(A::DynamicAttrs, k::String) = haskey(A.attrs, k)
Base.length(A::DynamicAttrs) = length(A.attrs)
Base.iterate(A::DynamicAttrs, args...) = iterate(A.attrs, args...)
Base.pairs(A::DynamicAttrs) = pairs(A.attrs)

function Base.setindex!(d::DynamicAttrs, v::TAttrVal, k::String)
    if !isnothing(d.value_length_limit)
        v = _truncate(v, d.value_length_limit)
    end
    d.attrs[k] = v
end

n_dropped(a::DynamicAttrs) = n_dropped(a.attrs)

#####

Base.@kwdef struct Resource{A<:StaticAttrs}
    attributes::A = StaticAttrs()
    schema_url::String = ""
end

#####

Base.@kwdef struct InstrumentationInfo
    name::String = "Main"
    version::VersionNumber = v"0.0.1-dev"
end
