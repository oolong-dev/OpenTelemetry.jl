using OpenTelemetrySDK
using OpenTelemetryAPI
using Test
using Random

@testset "OpenTelemetrySDK.jl" begin
    include("trace.jl")
    include("metric.jl")
end
