module OpenTelemetryAPI

if !isdefined(Base, :get_extension)
    using Requires
end

using TOML

const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

include("utils.jl")
include("common/common.jl")
include("trace/trace.jl")
include("metric/metric.jl")
include("log.jl")
include("propagator/propagator.jl")

function __init__()
    @static if !isdefined(Base, :get_extension)
        @require Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6" include(
            "../ext/OpenTelemetryAPIDownloadsExt.jl",
        )
        @require HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3" include(
            "../ext/OpenTelemetryAPIHTTPExt.jl",
        )
    end
end

end # module
