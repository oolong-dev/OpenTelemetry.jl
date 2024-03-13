using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryProto
using OpenTelemetryExporterOtlpProtoGrpc
using BenchmarkTools
using Logging
using Dates

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

function init_span(t)
    with_span(
        "benchmarkedSpan",
        t;
        attributes = Dict("long.attribute" => -10000000001000000000),
    ) do
        push!(current_span(), OpenTelemetryAPI.Event("benchmarkEvent"))
    end
end

trace_suite["Create Span"] = @benchmarkable init_span($TRACER)

trace_suite["Create Dummy Span"] = @benchmarkable init_span($DUMMY_TRACER)

const TYPICAL_SPAN = OpenTelemetrySDK.Span(
    "TYPICAL_SPAN",
    TRACER,
    INVALID_SPAN_CONTEXT,
    nothing,
    SPAN_KIND_INTERNAL,
    UInt(time() * 10^9),
    UInt(time() * 10^9),
    DynamicAttrs(
        Dict{String,TAttrVal}(
            "aaa" => repeat("a", 32),
            "bbb" => repeat("b", 32),
            "ccc" => repeat("c", 32),
        ),
    ),
    Limited(Link[Link(INVALID_SPAN_CONTEXT, StaticAttrs(; a = 1, b = 2.0))]),
    Limited(Event[Event("xyz", UInt(time() * 10^9), StaticAttrs(; m = [1], n = "2"))]),
    SpanStatus(SPAN_STATUS_UNSET),
)

trace_suite["Convert Span to Grpc"] = @benchmarkable convert(
    OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest,
    TYPICAL_SPAN,
)
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

function convert_counter_to_grpc(m) end

meter_suite["Convert Metrics to Grpc"] = @benchmarkable convert(
    OpenTelemetryProto.OpentelemetryClients.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest,
    metrics(PROVIDER),
)
#####

tune!(suite)
results = run(suite)
println(results)
BenchmarkTools.save(joinpath(@__DIR__, "output.json"), median(results))
