module OpenTelemetryAPI

using TOML

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

include("common/common.jl")
include("trace/trace.jl")
include("propagator/propagator.jl")
include("metric/metric.jl")
include("log.jl")

function __init__()
    push!(GLOBAL_PROPAGATOR, TraceContextTextMapPropagator())
end

end # module
