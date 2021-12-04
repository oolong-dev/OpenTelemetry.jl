using OpenTelemetryAPI
using Test
using LoggingExtras
using Logging

const API = OpenTelemetryAPI

@testset "OpenTelemetryAPI.jl" begin
    include("common.jl")
    include("propagator.jl")
    include("trace.jl")
    include("metric.jl")
    include("log.jl")
end
