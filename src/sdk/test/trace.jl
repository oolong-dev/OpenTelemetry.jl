@testset "trace" begin
    
global_tracer_provider(
    TracerProvider(
        span_processor=CompositSpanProcessor(
            SimpleSpanProcessor(
                 InMemoryExporter()
            )
        )
    )
)

tracer = get_tracer("test")

with_span("test_async", tracer) do
    @sync for i in 1:5
        @async with_span("asyn_span_$i", tracer) do
            current_span()["my_id"] = i
        end
    end
end

end