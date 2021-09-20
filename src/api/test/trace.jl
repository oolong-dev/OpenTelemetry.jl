@testset "trace" begin

@testset "TraceState" begin
    ts = OpenTelemetryAPI.TraceState(
        "1a-2f@foo"    => "bar1",
        "1a-_*/2b@foo" => "bar2",
        "foo"          => "bar3",
        "foo-_*/bar"   => "bar4",
    )
    @test haskey(ts, "foo")
    @test ts["foo"] == "bar3"
end

@testset "TracerProvider" begin
    tracer = get_tracer("test")
    with_span(tracer, "foo") do
        with_span(tracer, "bar") do
            with_span(tracer, "baz") do
                println("hello")
            end
        end
    end
end

end