export get_pkg_version

using Logging

# ??? what if value contains `,`? escape?
"""
Turn `"a=b,c=d"` into a `NamedTuple`
"""
extract_attrs(s) = NamedTuple(let (k, v) = split(kv, '=')
    Symbol(k) => v
end for kv in split(s, ',') if !isempty(kv))

function str2loglevel(s)
    S = uppercase(s)

    if S == "DEBUG"
        Logging.Debug
    elseif S == "INFO"
        Logging.Info
    elseif S == "WARN"
        Logging.Warn
    elseif S == "ERROR"
        Logging.Error
    else
        throw(ArgumentError("Unknown log level: $s"))
    end
end

function get_pkg_version(m::Module)
    project_toml = TOML.parsefile(joinpath(dirname(dirname(pathof(m))), "Project.toml"))
    if haskey(project_toml, "version")
        VersionNumber(project_toml["version"])
    else
        VERSION
    end
end