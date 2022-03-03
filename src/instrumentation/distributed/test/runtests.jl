using Distributed
using OpenTelemetryInstrumentationDistributed

addprocs(1)

@spawnat 1 identity("Hello World!")
@spawnat 2 identity("Hello World!")
