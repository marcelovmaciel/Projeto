using Plots
#using Plots.PlotMeasures
using StatsBase
inspectdr(legend = false)
Plots.scalefontsizes(1.3)
include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2


pa1 = dd.DyDeoParam(n_issues = 1,
                   size_nw = 500,
                   p = 0.9,
                   ρ = 1e-5,
                   propintransigents = 0.0,
                   intranpositions = "random")



stdsn1 = dd.dist_initstds(pa, 500)






