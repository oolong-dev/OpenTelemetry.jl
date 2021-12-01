using BenchmarkTools
using Logging

Logging.disable_logging(Logging.Error)

using OpenTelemetryAPI

function dummy_span(t)
    with_span(Span("a", t)) do 
        nothing
    end
end