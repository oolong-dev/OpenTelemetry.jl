using Pkg
using HTTP
using OpenTelemetryInstrumentationHTTP

include(joinpath(dirname(pathof(HTTP)), "..", "test", "runtests.jl"))
