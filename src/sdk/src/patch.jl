#####
# !!! intentional type piracy
# https://github.com/oolong-dev/OpenTelemetry.jl/issues/32
#####

function Base.schedule(t::Task)
    ctx = current_context()
    if ctx !== OpenTelemetryAPI.Context()
        if isnothing(t.storage)
            t.storage = IdDict()
        end
        t.storage[OpenTelemetryAPI.CONTEXT_KEY] = ctx
    end
    Base.enq_work(t)
end

#####
# Better display for builtin datatypes
#####
using Term: Tree, Panel, tprint
using Dates: unix2datetime

# Logging

function Base.show(io::IO, l::LogRecord)
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

function Base.show(io::IO, s::Span)
    style = "blue"
    tprint(
        io,
        Panel(
            convert(Tree, StructTree(s));
            fit = true,
            style = style,
            title = s.name[],
            title_style = "bold $style",
            subtitle = "$(unix2datetime(s.start_time / 10^9)) ~ $(unix2datetime(s.end_time[] / 10^9))",
            subtitle_style = "bold $style",
            subtitle_justify = :right,
        ),
    )
end

# Metrics

function Base.show(io::IO, m::Metric)
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