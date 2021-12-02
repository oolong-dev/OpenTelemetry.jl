using OpenTelemetry
using BenchmarkTools
using Logging

Logging.disable_logging(Logging.Error)

suite = BenchmarkGroup()

const TRACER = Tracer(
    provider = TracerProvider(;
        sampler = DEFAULT_ON,
        resource = Resource(
            attributes = StaticAttrs((;
                Symbol("service.name") => "A123456789",
                Symbol("service.version") => "1.34567890",
                Symbol("service.instance.id") => "123ab456-a123-12ab-12ab-12340a1abc12",
            )),
        ),
    ),
)

function create_span(t)
    with_span(
        Span(
            "benchmarkedSpan",
            t;
            attributes = Dict{String,TAttrVal}("long.attribute" => -10000000001000000000),
        ),
    ) do
        push!(current_span(), OpenTelemetry.Event(name = "benchmarkEvent"))
    end
end

suite["Create Span"] = @benchmarkable create_span($TRACER)

tune!(suite)
results = run(suite)
BenchmarkTools.save(joinpath(@__DIR__, "output.json"), median(results))