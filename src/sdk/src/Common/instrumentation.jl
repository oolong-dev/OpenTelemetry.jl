using Pkg

# source: https://discourse.julialang.org/t/how-to-find-out-the-version-of-a-package-from-its-module/37755/10?u=findmyway
pkgproject(m::Module) = Pkg.Operations.read_project(Pkg.Types.projectfile_path(pkgdir(m)))
pkgversion(m::Module) = pkgproject(m).version

struct InstrumentationInfo
    name::String
    version::VersionNumber
end

InstrumentationInfo(name::Module) =  InstrumentationInfo(String(nameof(name)), pkgversion(name))
InstrumentationInfo(name::String="Main") =  InstrumentationInfo(name, v"0.0.1-dev")
