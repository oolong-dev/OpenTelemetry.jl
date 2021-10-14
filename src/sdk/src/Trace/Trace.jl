@reexport module OpenTelemetryTrace

using OpenTelemetryAPI

const API = OpenTelemetryAPI

using ..Common

include("id_generator.jl")
include("sampling.jl")
include("span_processor.jl")
include("trace_provider.jl")

end