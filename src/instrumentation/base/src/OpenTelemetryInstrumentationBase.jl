module OpenTelemetryInstrumentationBase

using OpenTelemetryAPI
import TOML

const pkg_version =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

"""
## Schema

| Meter Name | Instrument Name   | Instrument Type   | Description                           |
|:---------- |:----------------- |:----------------- |:------------------------------------- |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
| `Base.Sys` | `Base.Sys.uptime` | `ObservableGauge` | The current system uptime in seconds. |
"""
function init(;
    meter_provider = global_meter_provider(),
    tracer_provider = global_tracer_provider(),
)
    m_sys = Meter(
        "Base.Sys";
        provider = meter_provider,
        version = pkg_version,
        schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationBase/#Schema",
    )

    ObservableGauge{Float64}(
        Sys.uptime,
        "Base.Sys.uptime",
        m_sys;
        unit = "second",
        description = "The current system uptime in seconds.",
    )

    ObservableGauge{UInt64}(
        Sys.free_memory,
        "Base.Sys.free_memory",
        m_sys;
        unit = "bytes",
        description = "The total free memory in RAM in bytes.",
    )

    ObservableGauge{Float64}(
        () -> Sys.free_memory() / Sys.total_memory() * 100,
        "Base.Sys.free_memory_ratio",
        m_sys;
        unit = "%",
        description = "The ratio of free memory in percentage.",
    )

    ObservableGauge{Float64}(
        () -> Sys.free_memory() / Sys.total_memory() * 100,
        "Base.Sys.free_memory_ratio",
        m_sys;
        unit = "%",
        description = "The ratio of free memory in percentage.",
    )

    ObservableGauge{UInt64}(
        Sys.maxrss,
        "Base.Sys.maxrss",
        m_sys;
        unit = "bytes",
        description = "The maximum resident set size utilized in bytes.",
    )

    ObservableGauge{UInt64}(
        Sys.maxrss,
        "Base.Sys.maxrss",
        m_sys;
        unit = "bytes",
        description = "The maximum resident set size utilized in bytes.",
    )

    m = Meter(
        "Base";
        provider = meter_provider,
        version = pkg_version,
        schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationBase/#Schema",
    )

    ObservableGauge{Int64}(
        Base.jit_total_bytes,
        "Base.jit_total_bytes",
        m;
        unit = "bytes",
        description = "The total amount (in bytes) allocated by the just-in-time compiler.",
    )

    ObservableGauge{Int64}(
        Base.gc_live_bytes,
        "Base.gc_live_bytes",
        m;
        unit = "bytes",
        description = "The total size of live objects after the last garbage collection, plus the number of bytes allocated since then",
    )

    ObservableGauge{UInt64}(
        Base.gc_time_ns,
        "Base.gc_time_ns",
        m;
        unit = "nanoseconds",
        description = "Total time spend in garbage collection, in nanoseconds",
    )
end

function __init__()
    init()
end

end # module
