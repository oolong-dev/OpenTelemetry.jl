using OpenTelemetry
using Test

@testset "OpenTelemetry.jl" begin
    code = []
    is_code = false
    for line in readlines(joinpath(@__DIR__, "..", "README.md"))
        if line == "```julia"
            is_code = true
        elseif line == "```"
            is_code = false
            code_str = """
            begin
            $(join(code, "\n"))
            end
            """
            println("Executing the following code:")
            println(code_str)
            eval(Meta.parse(code_str))
            empty!(code)
        elseif is_code
            push!(code, line)
        end
    end
end
