@testset "context" begin
    @test isnothing(get(current_context(), :say, nothing))
    with_context(:say=>"foo") do
        @test current_context()[:say] == "foo"
        with_context(:say => "bar") do
            @test current_context()[:say] == "bar"
        end
        @test current_context()[:say] == "foo"
    end
    @test isnothing(get(current_context(), :say, nothing))
end