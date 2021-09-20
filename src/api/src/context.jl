export current_context, with_context

using UUIDs: uuid4

const CONTEXT_KEY = :OPEN_TELEMETRY_CONTEXT

# ??? performace issue with NamedTuple
struct Context{T<:NamedTuple}
    kv::T
end

Context(;kw...) = Context(kw.data)

Base.merge(c1::Context, c2::Context) = Context(merge(c1.kv, c2.kv))

create_key(s) = Symbol(s, '-', uuid4())

for f in (:getindex, :haskey, :get)
    @eval Base.$f(ctx::Context, args...) = $f(ctx.kv, args...)
end

with_context(f, kv::Pair{Symbol}...) = with_context(f, current_context(), kv...)

"""
    with_context(f, [context], [k=>v]...)

Run function `f` in the `context`. If extra `kv` pairs are provided, they will be merged with the `context` to form a new context. When `context` is not provided, the [`current_context`](@ref) will be used.
"""
function with_context(f, ctx::Context, kv::Pair{Symbol}...)
    task_local_storage(CONTEXT_KEY, merge(ctx,Context(;kv...))) do
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
