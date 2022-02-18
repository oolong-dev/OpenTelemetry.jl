using Distributed
using OpenTelemetryInstrumentationDistributed

addprocs(1)

@spawnat 2 identity("Hello World!")