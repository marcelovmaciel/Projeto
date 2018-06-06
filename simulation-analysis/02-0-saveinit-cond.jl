include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2

const dd = DyDeo2

dd.@load  "data/sample5k6params.jld2" #paramvalues5k_6params

saltelli5000_initialcond = dd.getsample_initcond(paramvalues5k_6params)

dd.@save "data/saltellisample5000initcond.jld2" saltelli5000_initialcond

println("done")


