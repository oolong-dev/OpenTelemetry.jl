using Test

using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryExporterPrometheus
using HTTP

@testset "PrometheusExporter" begin
    p = MeterProvider()

    m = Meter("my_metrics"; provider = p)
    c = Counter{Int}("fruit_counter", m)

    c(; name = "apple", color = "red")
    c(2; name = "lemon", color = "yellow")
    c(1; name = "lemon", color = "yellow")
    c(2; name = "apple", color = "green")
    c(5; name = "apple", color = "red")
    c(4; name = "lemon", color = "yellow")

    h = Histogram{Float64}("latency", m)

    h(0.1; code = 666)
    h(1; code = 666)
    h(21; code = 666)
    h(321; code = 666)
    h(4321; code = 666)

    h(0.1; code = 888)
    h(1; code = 888)
    h(21; code = 888)
    h(321; code = 888)
    h(4321; code = 888)

    e = PrometheusExporter(; host = "0.0.0.0", port = 9966)
    r = MetricReader(p, e)

    resp = HTTP.request("GET", "http://localhost:9966")
    body = split(String(resp.body), "\n"; keepempty = false)
    expected = split(
        """
        # HELP fruit_counter 
        # TYPE fruit_counter counter
        fruit_counter{color="red",name="apple"} 6
        fruit_counter{color="green",name="apple"} 2
        fruit_counter{color="yellow",name="lemon"} 7
        """,
        "\n";
        keepempty = false,
    )

    for (expect, real) in zip(sort(expected), sort(body))
        @test startswith(real, expect)
    end
end
