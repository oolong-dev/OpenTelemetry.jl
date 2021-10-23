using OpenTelemetryAPI
using Test
using Base.Threads

const API = OpenTelemetryAPI

@testset "OpenTelemetryAPI.jl" begin

include("common.jl")
include("propagator.jl")
include("trace.jl")
include("metric.jl")

end
