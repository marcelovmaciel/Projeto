include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using Plots
using StatsBase, LaTeXStrings
inspectdr(legend = false)

fig = plot(show = false, xlabel = "iterações", ylabel = "valor do ponto ideal"  )


pa = dd.DyDeoParam(n_issues = 1, σ = 0.02, size_nw = 500, time = 500_000,
                   ρ = 0.0, propintransigents = 0.15)

statevec = dd.simstatesvec(pa);

a = dd.statesmatrix(statevec, pa.time, pa.size_nw);

a[1,:] |> std

round.(a[pa.time,:], 5) |> countmap

a[pa.time,:]  |> std


dd.@showprogress 1 "Plotting " for i in 1:pa.size_nw
    plot!(fig,a[:,i])
end


#display(fig)
#closeall()

savefig("image/timeseries4.png")




