using Downloads
using OpenTelemetryInstrumentationDownloads

include(joinpath(dirname(pathof(Downloads)), "..", "test", "runtests.jl"))
