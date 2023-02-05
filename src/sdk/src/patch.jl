#####
# !!! intentional type piracy
# https://github.com/oolong-dev/OpenTelemetry.jl/issues/32
#####

function Base.schedule(t::Task)
    ctx = current_context()
    if ctx !== OpenTelemetryAPI.Context()
        if isnothing(t.storage)
            t.storage = IdDict()
        end
        t.storage[OpenTelemetryAPI.CONTEXT_KEY] = ctx
    end
    Base.enq_work(t)
end
