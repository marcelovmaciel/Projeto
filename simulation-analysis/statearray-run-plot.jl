
include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using Plots,DataFrames

gr(legend = false)
pa = dd.DyDeoParam(n_issues = 1, size_nw = 1000, time = 250_000,
                   ρ = 0.001, certaintyparams = (0,0))

statearray  = dd.simstatesvec(pa)


fig = plot()

for i in 1:pa.size_nw
    plot!(fig,a[:,i])
end

savefig("image/timeseries2.png")
