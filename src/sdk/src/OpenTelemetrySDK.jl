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
include("patch.jl")

function __init__()
    @static if !isdefined(Base, :get_extension)
        @require Term = "22787eb5-b846-44ae-b979-8e399b8463ab" begin
            include("../ext/OpenTelemetrySDKTermExt.jl")
        end
    end
end

end # module
