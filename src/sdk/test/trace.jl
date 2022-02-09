@testset "trace" begin
    @testset "Span" begin
        @testset "non recording behaviors" begin
            s["foo"] = "bar"
            push!(s, API.Event(; name = "test"))
            push!(s, Link(INVALID_SPAN_CONTEXT, StaticAttrs()))
            set_status!(s, SPAN_STATUS_OK)

            @test haskey(s, "foo") == false
            @test length(s.events) == 0
            @test length(s.links) == 0
            @test s.status[].code == SPAN_STATUS_UNSET
        end

        s.end_time[] = nothing # !!! for test only

        @test_throws ErrorException with_span(s) do
            s["foo"] = "bar"
            push!(s, API.Event(; name = "test"))
            push!(s, Link(INVALID_SPAN_CONTEXT, StaticAttrs()))
            throw(ErrorException("!!!"))
        end

        @test is_recording(s) == false
        @test s["foo"] == "bar"
        @test length(s.events) == 2  # note that the ErrorException is also recorded
        @test length(s.links) == 1
        @test s.status[].code == SPAN_STATUS_ERROR
    end

    @testset "basic usage" begin
        global_tracer_provider(
            TracerProvider(
                span_processor = CompositSpanProcessor(
                    SimpleSpanProcessor(InMemoryExporter()),
                ),
            ),
        )

        tracer = Tracer()

        with_span(Span("test_async", tracer)) do
            @sync for i in 1:5
                @async with_span(Span("asyn_span_$i", tracer)) do
                    current_span()["my_id"] = i
                end
            end
        end

        p = global_tracer_provider()
        sp = p.span_processor.span_processors[1]
        @test length(sp.span_exporter.pool) == 6

        push!(p, SimpleSpanProcessor(ConsoleExporter()))

        with_span(Span("test", tracer)) do
            println("hello world!")
        end

        force_flush!(p)
        shut_down!(p)
        @test length(sp.span_exporter.pool) == 0

        s = Span("test", tracer)
        @test span_context(s) === INVALID_SPAN_CONTEXT
    end

    @testset "sampling" begin
        p = TracerProvider(
            span_processor = SimpleSpanProcessor(InMemoryExporter()),
            sampler = ALWAYS_OFF,
        )

        t = Tracer(; provider = p)

        s = Span("test", t)
        @test span_context(s) === INVALID_SPAN_CONTEXT

        p = TracerProvider(
            span_processor = SimpleSpanProcessor(InMemoryExporter()),
            sampler = DEFAULT_OFF,
        )

        t = Tracer(; provider = p)

        s = Span("test", t)
        @test span_context(s) === INVALID_SPAN_CONTEXT

        p = TracerProvider(
            span_processor = SimpleSpanProcessor(InMemoryExporter()),
            sampler = TraceIdRatioBased(0.5),
            id_generator = RandomIdGenerator(; rng = MersenneTwister(123)),
        )

        t = Tracer(; provider = p)
        n_no_op_spans = 0
        for _ in 1:1_000
            s = Span("test", t)
            if span_context(s) === INVALID_SPAN_CONTEXT
                n_no_op_spans += 1
            end
        end
        @test isapprox(n_no_op_spans / 1_000, 0.5; atol = 0.1)
    end
end
