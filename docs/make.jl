using OpenTelemetryUber

using Documenter

open(joinpath(@__DIR__, "..", "README.md"), "r") do f_src
    open(joinpath(@__DIR__, "src", "index.md"), "w") do f_dest
        s_dest = read(f_src, String)
        s_dest = replace(s_dest, "<!-- ```@raw html -->" => "```@raw html")
        s_dest = replace(s_dest, "<!-- ``` -->" => "```")
        s_dest = replace(s_dest, "```julia" => "```@example")
        write(f_dest, s_dest)
    end
end

makedocs(
    modules = [OpenTelemetryUber],
    format = Documenter.HTML(
        prettyurls = true,
        analytics = "G-YWC6SQHSVM",
        assets = ["assets/favicon.ico"],
    ),
    sitename = "OpenTelemetry.jl",
    linkcheck = !("skiplinks" in ARGS),
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "Tips for Developers" => "tips.md",
        "FAQ" => "FAQ.md",
        "Design" => Any[
            "OpenTelemetryAPI.md",
            "OpenTelemetrySDK.md",
            "OpenTelemetryExporterOtlpProtoGrpc.md",
            "OpenTelemetryExporterPrometheus.md",
            "OpenTelemetryProto.md",
            "OpenTelemetryInstrumentationBase.md",
            "OpenTelemetryInstrumentationDownloads.md",
            "OpenTelemetryInstrumentationDistributed.md",
            "OpenTelemetryInstrumentationHTTP.md",
            "OpenTelemetryInstrumentationGenie.md",
        ],
    ],
)

deploydocs(repo = "github.com/oolong-dev/OpenTelemetry.jl.git", target = "build")
