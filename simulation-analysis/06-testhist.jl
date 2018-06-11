include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using Plots
using StatsBase, CategoricalArrays
gr(legend = false)

out = dd.multiruns((1,0.02))


meanout(multirunout) = reduce((x,y)->broadcast(+,x,y),multirunout)/length(multirunout)

meanpop = meanout(out)

pa = dd.DyDeoParam(n_issues = 1, σ = 0.01,
                   size_nw = 500,
                   time = 500_000,
                   p = 0.9,
                   ρ = 0.00,
                   propintransigents = 0.0,
                   intranpositions = "extremes")

endpop = dd.simple_run(pa);

histfit = (meanpop |>
           x->(fit(Histogram,x,
                   closed = :left)))

#histfit.weights

plot(histfit)

fig = plot(show = false, xlabel = "iterações",
           ylabel = "valores dos pontos ideais")

pa_to_states = dd.statesmatrix(pa)


dd.@showprogress 1 "Plotting " for i in 1:pa.size_nw
    plot!(fig, pa_to_states[:,i])
end
