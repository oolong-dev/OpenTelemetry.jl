@testset "trace" begin
    @testset "basic usage" begin
        global_tracer_provider(
            TracerProvider(
                span_processor = CompositSpanProcessor(
                    SimpleSpanProcessor(InMemoryExporter()),
                ),
            ),
        )

        t = Tracer()

        with_span("test_async", t) do
            @sync for i in 1:5
                @async with_span("asyn_span_$i", t) do
                    current_span()["my_id"] = i
                end
            end
        end

        p = global_tracer_provider()
        sp = p.span_processor.span_processors[1]
        @test length(sp.exporter.pool) == 6

        push!(p, SimpleSpanProcessor(ConsoleExporter()))

        @test_throws ErrorException with_span("test", t) do
            span_name!("TEST")  # one can change the name of current span
            println("hello world from $(span_name()) [$(span_status())]!")
            throw(ErrorException("???"))
        end

        flush(p)
        close(p)
        @test length(sp.exporter.pool) == 7

        with_span("test", t) do
            @test span_context() === INVALID_SPAN_CONTEXT
        end
    end

    @testset "sampling" begin
        p = TracerProvider(
            span_processor = SimpleSpanProcessor(InMemoryExporter()),
            sampler = ALWAYS_OFF,
        )

        t = Tracer(; provider = p)

        with_span("test", t) do
            @test span_context() === INVALID_SPAN_CONTEXT
        end

        p = TracerProvider(
            span_processor = SimpleSpanProcessor(InMemoryExporter()),
            sampler = DEFAULT_OFF,
        )

        t = Tracer(; provider = p)

        with_span("test", t) do
            @test span_context() === INVALID_SPAN_CONTEXT
        end

        p = TracerProvider(
            span_processor = SimpleSpanProcessor(InMemoryExporter()),
            sampler = TraceIdRatioBased(0.5),
            id_generator = RandomIdGenerator(; rng = MersenneTwister(123)),
        )

        t = Tracer(; provider = p)
        n_no_op_spans = 0
        for _ in 1:1_000
            with_span("test", t) do
                if span_context() === INVALID_SPAN_CONTEXT
                    n_no_op_spans += 1
                end
            end
        end
        @test isapprox(n_no_op_spans / 1_000, 0.5; atol = 0.1)
    end
end
