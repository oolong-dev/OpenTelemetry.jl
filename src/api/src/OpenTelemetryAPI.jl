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

end # module
