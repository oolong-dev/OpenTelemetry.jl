using OpenTelemetrySDK
using OpenTelemetryAPI
using Test
using Base.Threads

@testset "OpenTelemetrySDK.jl" begin
    include("trace.jl")
end

