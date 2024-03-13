module OpenTelemetrySDK

if !isdefined(Base, :get_extension)
    using Requires
end

using Reexport

@reexport using OpenTelemetryAPI

include("exporter.jl")
include("log.jl")
include("trace/trace.jl")
include("metric/metric.jl")

using PackageExtensionCompat

function __init__()
    @require_extensions
end

end # module
