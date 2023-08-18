module OpenTelemetrySDK

@static if VERSION >= v"1.10.0-alpha"
    # https://github.com/oolong-dev/OpenTelemetry.jl/issues/93
    __precompile__(false)
end

if !isdefined(Base, :get_extension)
    using Requires
end

using Reexport

@reexport using OpenTelemetryAPI

include("exporter.jl")
include("log.jl")
include("trace/trace.jl")
include("metric/metric.jl")
include("patch.jl")

using PackageExtensionCompat

function __init__()
    @require_extensions
end

end # module
