export current_context, with_context, is_suppress_instrument

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

Run function `f` in the `context`. If extra `kv` pairs are provided, they will
be merged with the `context` to form a new context. When `context` is not
provided, the [`current_context`](@ref) will be used.
"""
with_context(f, ctx::Context; kw...) =
    task_local_storage(f, CONTEXT_KEY, merge(ctx, Context(values(kw))))

"""
Return the `Context` associated with the caller's current execution unit.
"""
current_context() = get(task_local_storage(), CONTEXT_KEY, Context())::Context

#####

SUPPRESS_INSTRUMENTATION_KEY = create_key("suppress_instrumentation")

is_suppress_instrument(ctx = current_context()) =
    get(ctx, SUPPRESS_INSTRUMENTATION_KEY, false)