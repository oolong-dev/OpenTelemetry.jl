module OpenTelemetrySDKTermExt

if isdefined(Base, :get_extension)
    using Term: Panel, tprint, TERM_THEME, Trees, Tree, RenderableText, highlight
else
    using ..Term: Panel, tprint, TERM_THEME, Trees, Tree, RenderableText, highlight
end

using Dates: unix2datetime

using AbstractTrees: children
using StructTypes: StructType, DictType, foreachfield

import OpenTelemetryAPI as API
import OpenTelemetrySDK as SDK

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
    c = children(s)
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

#####
# Better display for builtin datatypes
#####

AbstractTrees.children(s::StructTree{<:VersionNumber}) = ()
StructTypes.excludes(::Type{<:SDK.Tracer}) = (:provider,)
StructTypes.excludes(::Type{<:SDK.Meter}) = (:provider,)
StructTypes.excludes(::Type{<:API.AbstractInstrument}) = (:meter,)
StructTypes.excludes(::Type{<:SDK.DataPoint}) = (:exemplar_reservoir, :lock)

# Logging

function Base.show(io::IO, l::API.LogRecord)
    style = if l.severity_text == "INFO"
        "green"
    elseif l.severity_text == "WARN"
        "yellow"
    elseif l.severity_text == "ERROR"
        "red"
    else
        "white"
    end

    tprint(
        io,
        Panel(
            convert(Tree, StructTree(l));
            fit = true,
            style = style,
            title_style = "bold $style",
            title = l.severity_text,
            subtitle = string(unix2datetime(l.timestamp / 10^9)),
            subtitle_style = "bold $style",
            subtitle_justify = :right,
        ),
    )
end

# Tracing

function Base.show(io::IO, s::SDK.Span)
    style = "blue"
    tprint(
        io,
        Panel(
            convert(Tree, StructTree(s));
            fit = true,
            style = style,
            title = s.name,
            title_style = "bold $style",
            subtitle = "$(unix2datetime(s.start_time / 10^9)) ~ $(unix2datetime(s.end_time / 10^9))",
            subtitle_style = "bold $style",
            subtitle_justify = :right,
        ),
    )
end

# Metrics

function Base.show(io::IO, m::SDK.Metric)
    style = "purple"
    tprint(
        io,
        Panel(
            convert(Tree, StructTree(m));
            fit = true,
            style = style,
            title = m.name,
            title_style = "bold $style",
            subtitle = "$(length(m)) point(s) in total",
            subtitle_style = "bold $style",
            subtitle_justify = :right,
        ),
    )
end

function __init__()
    println("$(@__MODULE__) is loaded!")
end

end