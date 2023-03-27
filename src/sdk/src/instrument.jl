export instrument!, uninstrument!, get_pkg_version

using Pkg

instrument!(m::Module) = instrument!(Val(Symbol(m)))
uninstrument!(m::Module) = uninstrument!(Val(Symbol(m)))

get_pkg_version(m) =
    something(Pkg.dependencies()[Pkg.project().dependencies[string(m)]].version, VERSION) # !!! Stdlibs' version is `nothing`