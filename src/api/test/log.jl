@testset "logging" begin
    with_logger(TransformerLogger(LogTransformer(), global_logger())) do
        @info "hello world!"
    end
end
