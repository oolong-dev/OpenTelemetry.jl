using Genie
using HTTP
using OpenTelemetryInstrumentationGenie

route("/hello") do
    "world"
end

up(7777)

sleep(1)

HTTP.get("http://localhost:7777/hello")
HTTP.get("http://localhost:7777/hello")
HTTP.get("http://localhost:7777/hello")

down()
