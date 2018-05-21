include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using Plots
using StatsBase, CategoricalArrays
inspectdr(legend = false)

pa = dd.DyDeoParam(n_issues = 1, σ = 0.01,
                   size_nw = 500,
                   time = 500_000,
                   p = 0.9,
                   ρ = 0.00,
                   propintransigents = 0.0,
                   intranpositions = "extremes")

endpop = dd.simple_run(pa);

histfit = (endpop |>
           dd.pullidealpoints |>
           x->(fit(Histogram,x,
                   closed = :left,nbins = 15 )))

histfit.weights

plot(histfit)

fig = plot(show = false, xlabel = "iterações",
           ylabel = "valores dos pontos ideais")

pa_to_states = dd.statesmatrix(pa)


dd.@showprogress 1 "Plotting " for i in 1:pa.size_nw
    plot!(fig, pa_to_states[:,i])
end
