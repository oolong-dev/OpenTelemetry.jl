using OpenTelemetrySDK
using OpenTelemetryAPI
using Test
using Random
using Base.Threads

@testset "OpenTelemetrySDK.jl" begin
    include("trace.jl")
    include("metric.jl")
end

