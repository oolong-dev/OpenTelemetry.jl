module OpenTelemetrySDK

using OpenTelemetryAPI

include("exporter.jl")
include("trace/trace.jl")
include("metric/metric.jl")

end # module
