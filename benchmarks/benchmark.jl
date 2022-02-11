using OpenTelemetry
using BenchmarkTools
using Logging

Logging.disable_logging(Logging.Error)

suite = BenchmarkGroup()

#####

trace_suite = BenchmarkGroup()
suite["Trace"] = trace_suite

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

const DUMMY_TRACER = Tracer(provider = OpenTelemetryAPI.DUMMY_TRACER_PROVIDER)

function create_span(t)
    with_span(
        "benchmarkedSpan",
        t;
        attributes = Dict{String,TAttrVal}("long.attribute" => -10000000001000000000),
    ) do
        push!(current_span(), OpenTelemetry.Event(name = "benchmarkEvent"))
    end
end

trace_suite["Create Span"] = @benchmarkable create_span($TRACER)

trace_suite["Create Dummy Span"] = @benchmarkable create_span($DUMMY_TRACER)

#####

meter_suite = BenchmarkGroup()
suite["Meter"] = meter_suite

const PROVIDER = MeterProvider(;
    views = [
        View("benchmark_counter"),
        View(
            "benchmark_histogram";
            aggregation = HistogramAgg{Int}(; boundaries = Tuple(100.0:100.0:900.0)),
        ),
    ],
)
const METER = Meter("benchmark_meter"; provider = PROVIDER)
const COUNTER = Counter{Int}("benchmark_counter", METER)

function update_counter(c, n)
    c(n; name = "a", code = 2, msg = "hi")
end

meter_suite["Update Counter"] =
    @benchmarkable update_counter(c, n) setup = (c = $COUNTER; n = rand(1:100))

const HISTOGRAM = Histogram{Int}("benchmark_histogram", METER)

function update_histogram(h, n)
    h(n; name = "a", code = 2, msg = "hi")
end

meter_suite["Update Histogram"] =
    @benchmarkable update_histogram(h, n) setup = (h = $HISTOGRAM; n = rand(1:1_000))

#####

tune!(suite)
results = run(suite)
println(results)
BenchmarkTools.save(joinpath(@__DIR__, "output.json"), median(results))
