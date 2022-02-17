using Genie
using HTTP
using OpenTelemetryInstrumentationGenie

route("/hello") do
    "world"
end

up(8888)

sleep(1)

HTTP.get("http://localhost:8888/hello")
HTTP.get("http://localhost:8888/hello")
HTTP.get("http://localhost:8888/hello")

down()