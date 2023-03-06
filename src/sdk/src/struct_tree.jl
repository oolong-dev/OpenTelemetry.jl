using StructTypes: foreachfield, StructType, DictType
using Term: tprint, TERM_THEME, Trees, Tree, RenderableText, highlight

import AbstractTrees
import StructTypes

struct StructTree{X}
    name::Symbol
    value::X
end

StructTree(x::X) where {X} = StructTree(Symbol(""), x)

function AbstractTrees.children(s::StructTree)
    c = []
    if StructType(s.value) === DictType()
        for (k, v) in pairs(s.value)
            push!(c, StructTree(Symbol(k), v))
        end
    else
        foreachfield(s.value) do i, name, FT, v
            push!(c, StructTree(Symbol(name), v))
        end
    end
    c
end

function AbstractTrees.printnode(
    io::IO,
    s::StructTree{X};
    theme = TERM_THEME[],
    kw...,
) where {X}
    c = AbstractTrees.children(s)
    r =
        "{$(theme.tree_keys)}" *
        "$(s.name)" *
        "{/$(theme.tree_keys)}" *
        "{$(theme.repr_type)}" *
        "::$(nameof(X))" *
        "{/$(theme.repr_type)}"
    if length(c) == 0
        r *=
            "{$(theme.tree_pair)}" *
            " ⇒ " *
            "{/$(theme.tree_pair)}" *
            highlight("$(repr(s.value))")
    end
    tprint(IOContext(io, :compact => true, :limit => true), r; highlight = false)
end

function Base.convert(::Type{Tree}, s::StructTree)
    guides = Trees.treeguides[:standardtree]
    r = sprint(temp_io -> AbstractTrees.print_tree(temp_io, s; charset = guides))
    r = Trees.style_guides(r, guides, TERM_THEME[])
    rt = RenderableText(r)
    return Tree(rt.segments, rt.measure)
end

Base.show(io::IO, s::StructTree) = print(io, convert(Tree, s))
