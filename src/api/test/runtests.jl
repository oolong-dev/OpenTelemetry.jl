using OpenTelemetryAPI
using Test
using Logging
using LoggingExtras

const API = OpenTelemetryAPI

@testset "OpenTelemetryAPI.jl" begin
    include("utils.jl")
    include("common.jl")
    include("propagator.jl")
    include("trace.jl")
    include("metric.jl")
    include("log.jl")
end
