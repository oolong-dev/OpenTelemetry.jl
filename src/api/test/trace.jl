@testset "trace" begin
    @testset "basic" begin
        @test isnothing(current_span())
        @test isnothing(span_context())

        @testset "TraceState" begin
            ts = TraceState(
                "1a-2f@foo" => "bar1",
                "1a-_*/2b@foo" => "bar2",
                "foo" => "bar3",
                "foo-_*/bar" => "bar4",
                "^foo-_*/bar" => "bar5",  # invalid key
                "hello" => "世界！",  # invalid value
            )

            @test string(ts) == "1a-2f@foo=bar1,1a-_*/2b@foo=bar2,foo=bar3,foo-_*/bar=bar4"
            @test length(ts) == 4
            @test haskey(ts, :foo)
            @test !haskey(ts, "^foo-_*/bar")
            @test ts[:foo] == "bar3"
        end
    end

    @testset "TracerProvider" begin
        tracer = Tracer()
        with_span("test", tracer) do
            @test span_context() === INVALID_SPAN_CONTEXT
            @test is_recording() == false
            @test haskey(current_span(), "foo") == false
            @test length(span_events()) == 0
            @test length(span_links()) == 0
            @test span_status().code == SPAN_STATUS_UNSET
        end

        with_span("foo", tracer) do
            with_span("bar", tracer) do
                with_span("baz", tracer) do
                    println("hello")
                end
                with_span("baz", tracer) do
                    println("world!")
                end
            end
        end
    end
end
