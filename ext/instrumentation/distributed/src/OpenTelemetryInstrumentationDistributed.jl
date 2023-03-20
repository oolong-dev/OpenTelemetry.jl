module OpenTelemetryInstrumentationDistributed

using OpenTelemetryAPI
using Distributed

using TOML
const PKG_VERSION =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])
const instrumentation_scope = InstrumentationScope(
    name = string(@__MODULE__),
    version = PKG_VERSION,
    schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationDistributed/",
)

const DISTRIBUTED_TRACER = Ref{Tracer}()
const REMOTE_CALLMSG_COUNT = Ref{Counter{UInt}}()

function Distributed.local_remotecall_thunk(f, args::Tuple, kwargs::Base.Pairs)
    () -> begin
        f_name = applicable(nameof, f) ? string(nameof(f)) : "UNKNOWN"
        with_span(
            "Distributed local call [$f_name]",
            DISTRIBUTED_TRACER[];
            kind = SPAN_KIND_INTERNAL,
            attributes = Dict{String,TAttrVal}(
                "Distributed.from_worker_id" => myid(),
                "Distributed.target_worker_id" => myid(),
                "Distributed.remote_call_name" => f_name,
            ),
        ) do
            invokelatest(f, args...; kwargs...)
            REMOTE_CALLMSG_COUNT[](;
                from_worker_id = myid(),
                target_worker_id = myid(),
                remote_call_name = f_name,
                mode = "",  # no mode info in local call
            )
        end
    end
end

struct CallMsgWrapper
    f::Any
    mode::Symbol
    from::Int
    span_ctx::Union{SpanContext,Nothing}
end

function (w::CallMsgWrapper)(args...; kw...)
    name = applicable(nameof, w.f) ? string(nameof(w.f)) : "UNKNOWN"
    with_context(;
        OpenTelemetryAPI.SPAN_KEY_IN_CONTEXT =>
            OpenTelemetryAPI.NonRecordingSpan("", w.span_ctx, nothing),
    ) do
        with_span(
            "Distributed remote call [$name]",
            DISTRIBUTED_TRACER[];
            kind = SPAN_KIND_INTERNAL,
            attributes = Dict{String,TAttrVal}(
                "Distributed.from_worker_id" => w.from,
                "Distributed.target_worker_id" => myid(),
                "Distributed.remote_call_name" => name,
            ),
        ) do
            invokelatest(w.f, args...; kw...)
            REMOTE_CALLMSG_COUNT[](;
                from_worker_id = w.from,
                target_worker_id = myid(),
                remote_call_name = name,
                mode = string(w.mode),
            )
        end
    end
end

struct DummyWrapper
    kwargs::Any
end

Base.iterate(w::DummyWrapper, args...) = iterate(w.kwargs, args...)

function Distributed.CallMsg{M}(f, args::Tuple, kwargs::Base.Pairs) where {M}
    Distributed.CallMsg{M}(
        CallMsgWrapper(f, M, myid(), span_context()),
        args,
        DummyWrapper(kwargs),
    )
end

"""
## Metrics

| Meter Name    | Instrument Name | Instrument Type | Unit | Dimensions                                               | Description             |
|:------------- |:--------------- |:--------------- |:---- |:-------------------------------------------------------- |:----------------------- |
| `Distributed` | `n_remote_call` | `Counter{UInt}` |      | `from_worker_id`, `target_worker_id`, `remote_call_name` | Number of remote calls. |

## Spans

The following attributes are added on span creation:

  - `Distributed.from_worker_id`
  - `Distributed.target_worker_id`, the value is the same with `Distributed.from_worker_id` when the function is executed on local processor.
  - `Distributed.remote_call_name`, which is inferred by `Base.nameof`, fallback to `UNKNOWN` when not implemented.
"""
function init(;
    tracer_provider = global_tracer_provider(),
    meter_provider = global_meter_provider(),
)
    REMOTE_CALLMSG_COUNT[] = Counter{UInt}(
        "n_remote_call",
        Meter(
            "Distributed";
            provider = meter_provider,
            instrumentation_scope = instrumentation_scope,
        );
        unit = "",
        description = "Number of remote calls executed.",
    )
    DISTRIBUTED_TRACER[] =
        Tracer(; provider = tracer_provider, instrumentation_scope = instrumentation_scope)
end

function __init__()
    init()
end

end # module
