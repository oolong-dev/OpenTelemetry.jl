module OpenTelemetryInstrumentationBase

using OpenTelemetryAPI
import TOML

const pkg_version =
    VersionNumber(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["version"])

"""
## Schema

| Meter Name | Instrument Name     | Instrument Type   | Unit        | Description                                                                                                      |
|:---------- |:------------------- |:----------------- |:----------- |:---------------------------------------------------------------------------------------------------------------- |
| `Base.Sys` | `uptime`            | `ObservableGauge` | second      | The current system uptime in seconds.                                                                            |
| `Base.Sys` | `free_memory`       | `ObservableGauge` | bytes       | The total free memory in RAM in bytes.                                                                           |
| `Base.Sys` | `free_memory_ratio` | `ObservableGauge` | %           | The ratio of free memory in percentage.                                                                          |
| `Base.Sys` | `maxrss`            | `ObservableGauge` | bytes       | The maximum resident set size utilized in bytes.The current system uptime in seconds.                            |
| `Base`     | `jit_total_bytes`   | `ObservableGauge` | bytes       | The total amount (in bytes) allocated by the just-in-time compiler.                                              |
| `Base`     | `gc_live_bytes`     | `ObservableGauge` | bytes       | The total size of live objects after the last garbage collection, plus the number of bytes allocated since then. |
| `Base`     | `gc_time_ns`        | `ObservableGauge` | nanoseconds | Total time spend in garbage collection, in nanoseconds                                                           |
"""
function init(;
    meter_provider = global_meter_provider(),
    tracer_provider = global_tracer_provider(),
)
    m_sys = Meter(
        "Base.Sys";
        provider = meter_provider,
        version = pkg_version,
        schema_url = "https://oolong.dev/OpenTelemetry.jl/dev/OpenTelemetryInstrumentationBase/",
    )

    ObservableGauge{Float64}(
        Sys.uptime,
        "uptime",
        m_sys;
        unit = "second",
        description = "The current system uptime in seconds.",
    )

    ObservableGauge{UInt64}(
        Sys.free_memory,
        "free_memory",
        m_sys;
        unit = "bytes",
        description = "The total free memory in RAM in bytes.",
    )

    ObservableGauge{Float64}(
        () -> Sys.free_memory() / Sys.total_memory() * 100,
        "free_memory_ratio",
        m_sys;
        unit = "%",
        description = "The ratio of free memory in percentage.",
    )

    ObservableGauge{UInt64}(
        Sys.maxrss,
        "maxrss",
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
        "jit_total_bytes",
        m;
        unit = "bytes",
        description = "The total amount (in bytes) allocated by the just-in-time compiler.",
    )

    ObservableGauge{Int64}(
        Base.gc_live_bytes,
        "gc_live_bytes",
        m;
        unit = "bytes",
        description = "The total size of live objects after the last garbage collection, plus the number of bytes allocated since then",
    )

    ObservableGauge{UInt64}(
        Base.gc_time_ns,
        "gc_time_ns",
        m;
        unit = "nanoseconds",
        description = "Total time spend in garbage collection, in nanoseconds",
    )
end

function __init__()
    init()
end

end # module
