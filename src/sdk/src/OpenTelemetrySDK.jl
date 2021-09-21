module OpenTelemetrySDK

using OpenTelemetryAPI

const API = OpenTelemetryAPI

include("instrumentation.jl")
include("resource.jl")
include("trace/sampling.jl")
include("trace/id_generator.jl")
include("trace/span_processor.jl")
include("trace/trace.jl")

end # module
