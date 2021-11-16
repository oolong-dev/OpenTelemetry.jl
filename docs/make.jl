using OpenTelemetryAPI
using OpenTelemetrySDK
using OpenTelemetryProto
using OpenTelemetryExporterOtlpProtoGrpc

using Documenter

open(joinpath(@__DIR__, "..", "README.md"), "r") do f_src
    open(joinpath(@__DIR__, "src", "index.md"), "w") do f_dest
        s_dest = read(f_src, String)
        s_dest = replace(s_dest, "<!-- ```@raw html -->" => "```@raw html")
        s_dest = replace(s_dest, "<!-- ``` -->" => "```")
        write(f_dest, s_dest)
    end
end

makedocs(
    modules = [
        OpenTelemetryAPI
        OpenTelemetrySDK
        OpenTelemetryProto
        OpenTelemetryExporterOtlpProtoGrpc
    ],
    format = Documenter.HTML(
        prettyurls = true,
        analytics = "G-YWC6SQHSVM",
        assets = ["assets/favicon.ico"],
    ),
    sitename = "OpenTelemetry.jl",
    linkcheck = !("skiplinks" in ARGS),
    pages = [
        "Home" => "index.md",
        "Design" => Any["API" => "design_api.md", "SDK" => "design_sdk.md"],
    ],
)
