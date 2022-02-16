using HTTP
using OpenTelemetryInstrumentationHTTP
using Sockets

get_oolong(x) = HTTP.Response(200)
router = HTTP.Router()
HTTP.@register(router, "GET", "/api/oolong/*", get_oolong)

server = Sockets.listen(Sockets.InetAddr(parse(IPAddr, "127.0.0.1"), 8586))
tsk = @async HTTP.serve(router, "127.0.0.1", 8586; server = server)
sleep(1)
HTTP.get("http://127.0.0.1:8586/api/oolong/123")
close(server)
