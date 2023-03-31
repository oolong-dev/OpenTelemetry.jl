@testset "logging" begin
    @testset "OtelSimpleLogger" begin
        with_logger(OtelSimpleLogger()) do
            @info "Hi"
        end
    end
    @testset "OtelBatchLogger" begin
        exporter = InMemoryExporter()
        logger = OtelBatchLogger(exporter)
        with_logger(logger) do
            @info "hello"
            @info "world" foo = 1 bar = 2

            flush(current_logger())
        end

        @test length(exporter.pool) == 2
        @test exporter.pool[1].body == "hello"
        @test exporter.pool[2].body == "world"

        @test string(exporter.pool[2].attributes) == "bar=2,foo=1" # !!! the attributes are sorted by key
    end
end