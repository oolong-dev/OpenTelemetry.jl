using Downloads
using HTTP

instrument!(Downloads)

server = HTTP.serve!("127.0.0.1", 8121) do req
    if isnothing(HTTP.header(req, "traceparent", nothing))
        HTTP.Response(500, "Fail")
    else
        HTTP.Response(200, "Success")
    end
end

with_span("exmaple") do
    Downloads.download("http://localhost:8121/")
end

close(server)