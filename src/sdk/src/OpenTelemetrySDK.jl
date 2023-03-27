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
include("instrument.jl")
include("patch.jl")

function __init__()
    @static if !isdefined(Base, :get_extension)
        @require Term = "22787eb5-b846-44ae-b979-8e399b8463ab" begin
            include("../ext/OpenTelemetrySDKTermExt.jl")
        end
        @require Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6" begin
            include("../ext/OpenTelemetrySDKDownloadsExt.jl")
        end
        @require HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3" begin
            include("../ext/OpenTelemetrySDKHTTPExt.jl")
        end
    end
end

end # module
