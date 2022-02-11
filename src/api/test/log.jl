@testset "logging" begin
    with_logger(TransformerLogger(OtelLogTransformer(), global_logger())) do
        @info "hello world!"
    end
end
