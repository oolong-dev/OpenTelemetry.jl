@testset "utils" begin
    @test get_pkg_version(Logging) == VERSION
    withenv("OTEL_LOG_LEVEL" => "error") do
        @test OTEL_LOG_LEVEL() == Logging.Error
    end
end