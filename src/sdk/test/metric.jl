@testset "metric" begin
    p = MeterProvider()
    m = Meter("test";provider=p)
    c = Counter{Int}(m, "fruit counter")

    c(;name="apple", color="red")
    c(2;name="lemon", color="yellow")
    c(1;name="lemon", color="yellow")
    c(2;name="apple", color="green")
    c(5;name="apple", color="red")
    c(4;name="lemon", color="yellow")
end
