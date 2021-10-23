@testset "trace" begin

@testset "basic" begin
    @test isnothing(current_span())
    @test isnothing(span_context())

    @testset "TraceState" begin
        ts = TraceState(
            "1a-2f@foo"    => "bar1",
            "1a-_*/2b@foo" => "bar2",
            "foo"          => "bar3",
            "foo-_*/bar"   => "bar4",
            "^foo-_*/bar"  => "bar5",
            "hello"        => "世界！",
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
        s = Span("test", tracer)
        @test span_context(s) === INVALID_SPAN_CONTEXT
        @test is_recording(s) == false

        @testset "non recording behaviors" begin
            s["foo"] = "bar"
            push!(s, API.Event(;name="test"))
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
            push!(s, API.Event(;name="test"))
            push!(s, Link(INVALID_SPAN_CONTEXT, StaticAttrs()))
            throw(ErrorException("!!!"))
        end

        @test is_recording(s) == false
        @test s["foo"] == "bar"
        @test length(s.events) == 2  # note that the ErrorException is also recorded
        @test length(s.links) == 1
        @test s.status[].code == SPAN_STATUS_ERROR

        with_span(Span("foo", tracer)) do
            with_span(Span("bar", tracer)) do
                with_span(Span("baz", tracer)) do
                    println("hello")
                end
                with_span(Span("baz", tracer)) do
                    println("world!")
                end
            end
        end
    end

end