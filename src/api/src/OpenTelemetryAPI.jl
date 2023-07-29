module OpenTelemetryAPI


using TOML

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

include("utils.jl")
include("common/common.jl")
include("trace/trace.jl")
include("metric/metric.jl")
include("log.jl")
include("propagator/propagator.jl")

using PackageExtensionCompat

function __init__()
    @require_extensions

    for p in OTEL_PROPAGATORS()
        if p == "tracecontext"
            push!(TraceContextTextMapPropagator())
        end
    end
end

end # module
