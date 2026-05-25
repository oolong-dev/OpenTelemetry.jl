module OpenTelemetryProto

import ProtoBuf

# Compat shim: ProtoBuf 1.3 changed the decoder helper signature from
# `message_done(d)` to `message_done(d, endpos, group)`. Regenerated code
# uses the 3-arg form; provide a fallback when running against ProtoBuf <1.3
# so the package keeps working across the full `ProtoBuf = "1"` compat range.
# OTLP is proto3 (no groups) and all length-delimited sub-messages are decoded
# through ProtoBuf.decode!, which constructs a LengthDelimitedProtoDecoder on
# older ProtoBuf releases, so the `endpos`/`group` parameters are unused there.
if !hasmethod(ProtoBuf.message_done, Tuple{ProtoBuf.AbstractProtoDecoder,Int,Bool})
    ProtoBuf.message_done(d::ProtoBuf.AbstractProtoDecoder, ::Int, ::Bool) =
        ProtoBuf.message_done(d)
end

include("opentelemetry/opentelemetry.jl")

end
