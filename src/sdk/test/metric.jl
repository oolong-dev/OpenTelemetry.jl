@testset "metric" begin
    p = MeterProvider()
    e = InMemoryExporter()
    r = MetricReader(p, e)

    m = Meter("test"; provider = p)

    c = Counter{Int}("fruit_counter", m)
    c(; name = "apple", color = "red")
    c(2; name = "lemon", color = "yellow")
    c(1; name = "lemon", color = "yellow")
    c(2; name = "apple", color = "green")
    c(5; name = "apple", color = "red")
    c(4; name = "lemon", color = "yellow")

    @test length(metrics()) == 0  # the default meter provider is a dummy one

    @test length(metrics(p)) == 1
    mt = first(metrics(p))
    @test length(collect(mt)) == 3

    @test resource(mt) == resource(p)

    udc = UpDownCounter{Int}("stock", m)
    udc(200)
    udc(-50)
    udc(150)

    function fake_observer(x)
        i = x
        function ()
            res = i * 2
            i += 1
            res
        end
    end

    oc = ObservableCounter{Int}(fake_observer(0), "observable_counter", m)

    oudc = ObservableUpDownCounter{Int}(fake_observer(-2), "observable_up_down_counter", m)

    og = ObservableGauge{Int}(fake_observer(-3), "observable_gauge", m)

    h = Histogram{Int}("n_requests", m)
    h(3)
    h(5)
    h(8)
    h(12)
    h(2)
    h(1_000_000)

    r()

    c_points = first(m for m in e if m.name == "fruit_counter")
    @test length(c_points) == 3
    @test c_points[StaticBoundedAttributes((color = "red", name = "apple"))].value == 6
    @test c_points[StaticBoundedAttributes((color = "yellow", name = "lemon"))].value == 7
    @test c_points[StaticBoundedAttributes((color = "green", name = "apple"))].value == 2

    h_points = first(m for m in e if m.name == "n_requests")
    @test length(h_points) == 1
    hist = h_points[StaticBoundedAttributes()].value.counts
    @test hist[1] == 0
    @test hist[2] == 3
    @test hist[3] == 1
    @test hist[4] == 1
    @test hist[end] == 1
    @test sum(hist) == 6

    udc_points = first(m for m in e if m.name == "stock")
    @test udc_points[StaticBoundedAttributes()].value == 300

    oc_points = first(m for m in e if m.name == "observable_counter")
    @test oc_points[StaticBoundedAttributes()].value == 0

    oudc_points = first(m for m in e if m.name == "observable_up_down_counter")
    @test oudc_points[StaticBoundedAttributes()].value == -4

    og_points = first(m for m in e if m.name == "observable_gauge")
    @test og_points[StaticBoundedAttributes()].value == -6

    # observe again!
    # sync instruments should have no changes
    # async instruments should have been changed
    empty!(e)
    r()

    c_points = first(m for m in e if m.name == "fruit_counter")
    @test length(c_points) == 3
    @test c_points[StaticBoundedAttributes((color = "red", name = "apple"))].value == 6
    @test c_points[StaticBoundedAttributes((color = "yellow", name = "lemon"))].value == 7
    @test c_points[StaticBoundedAttributes((color = "green", name = "apple"))].value == 2

    h_points = first(m for m in e if m.name == "n_requests")
    @test length(h_points) == 1
    hist = h_points[StaticBoundedAttributes()].value.counts
    @test hist[1] == 0
    @test hist[2] == 3
    @test hist[3] == 1
    @test hist[4] == 1
    @test hist[end] == 1
    @test sum(hist) == 6

    udc_points = first(m for m in e if m.name == "stock")
    @test udc_points[StaticBoundedAttributes()].value == 300

    oc_points = first(m for m in e if m.name == "observable_counter")
    @test oc_points[StaticBoundedAttributes()].value == 0 + 2

    oudc_points = first(m for m in e if m.name == "observable_up_down_counter")
    @test oudc_points[StaticBoundedAttributes()].value == -4 + (-2)

    og_points = first(m for m in e if m.name == "observable_gauge")
    @test og_points[StaticBoundedAttributes()].value == -4 # the last value

    # observe again
    empty!(e)
    r()

    oc_points = first(m for m in e if m.name == "observable_counter")
    @test oc_points[StaticBoundedAttributes()].value == 0 + 2 + 4

    oudc_points = first(m for m in e if m.name == "observable_up_down_counter")
    @test oudc_points[StaticBoundedAttributes()].value == -4 + (-2) + 0

    og_points = first(m for m in e if m.name == "observable_gauge")
    @test og_points[StaticBoundedAttributes()].value == -2 # the last value

    periodic_reader = PeriodicMetricReader(
        CompositMetricReader(r, MetricReader(p, ConsoleExporter()));
        export_interval_seconds = 1,
    )

    periodic_reader()

    sleep(3)
    shut_down!(periodic_reader)

    global_meter_provider!(p)
    mr = MetricReader()  # read to console by default
end

@testset "AggregationStore" begin
    store = OpenTelemetrySDK.AggregationStore{OpenTelemetrySDK.DataPoint{Int,Nothing}}(;
        n_max_points = 3,
        n_max_attrs = 4,
    )
    init_data = () -> OpenTelemetrySDK.DataPoint{Int}()

    p1 = get!(init_data, store, StaticBoundedAttributes())
    p2 = get!(init_data, store, StaticBoundedAttributes((a = 1, b = 2, c = 3)))
    p3 = get!(init_data, store, StaticBoundedAttributes((b = 2, a = 1, c = 3)))
    @test p2 === p3

    p4 = get!(init_data, store, StaticBoundedAttributes((b = 2, c = 3, a = 1)))
    @test p2 === p4

    @test (@test_logs (
        :warn,
        "maximum cached keys in agg store reached, please consider increase `n_max_points`",
    ) get!(init_data, store, StaticBoundedAttributes((c = 3, b = 2, a = 1)))) === p2

    p5 = get!(init_data, store, StaticBoundedAttributes((; x = 123)))
    p6 = get!(init_data, store, StaticBoundedAttributes((; y = 123)))
    @test isnothing(p6)
end

@testset "Views" begin
    b = (5.0, 10.0, 25.0, 50.0, 100.0)

    p = MeterProvider(
        views = [
            View("X"),
            View("Foo"; instrument_name = "Y"),
            View(
                "Bar";
                instrument_name = "Y",
                aggregation = HistogramAgg{Int}(boundaries = b),
            ),
        ],
    )

    e = InMemoryExporter()
    r = MetricReader(p, e)
    m = Meter("test"; provider = p)

    X = Counter{Int}("X", m)
    X(2)
    X(3)
    X(1)

    Y = Histogram{Int}("Y", m)
    Y(-1)
    Y(1)
    Y(2000)
    Y(200)

    Z = UpDownCounter{Int}("Z", m)
    Z(-10)
    Z(10)

    r()

    @test length(e.pool) == 3

    @test first(m for m in e if m.name == "X")[StaticBoundedAttributes()].value == 2 + 3 + 1

    foo = first(m for m in e if m.name == "Foo")[StaticBoundedAttributes()].value.counts
    # DEFAULT_HISTOGRAM_BOUNDARIES = (0.0, 5.0, 10.0, 25.0, 50.0, 75.0, 100.0, 250.0, 500.0, 1000.0)
    @test foo[1] == 1
    @test foo[2] == 1
    @test foo[8] == 1
    @test foo[end] == 1
    @test sum(foo) == 4

    bar = first(m for m in e if m.name == "Bar")[StaticBoundedAttributes()].value.counts
    # b = (5.0, 10.0, 25.0, 50.0, 100.0)
    @test bar[1] == 2
    @test bar[end] == 2
    @test sum(bar) == 4
end

@testset "Drop Agg" begin
    p = MeterProvider(
        views = [
            View(
                "*";
                instrument_type = Counter,
                meter_name = "test",
                meter_version = v"0.0.1-dev",
                meter_schema_url = "",
            ),
            View("X"; aggregation = DROP),
        ],
    )

    e = InMemoryExporter()
    r = MetricReader(p, e)

    m = Meter("test"; provider = p)
    x = Counter{Int}("X", m)
    x(1)

    y = Counter{Int}("Y", m)
    tracer = Tracer()
    with_span("test", tracer) do
        y(2)
    end

    r()

    @test length(e) == 1
    @test e.pool[1].name == "Y"
end
