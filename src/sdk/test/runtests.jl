using OpenTelemetrySDK
using OpenTelemetryAPI
using Test
using Random
using LoggingExtras
using Logging

@testset "OpenTelemetrySDK.jl" begin
    include("log.jl")
    include("trace.jl")
    include("metric.jl")
    include("log.jl")
end
