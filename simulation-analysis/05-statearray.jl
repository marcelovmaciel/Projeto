include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using Plots
using StatsBase
inspectdr(legend = false)



# pre-plots

#finalplot = plot(figs[1], figs[2])

fig = plot(show = false, xlabel = "iterações",
           ylabel = "valores dos pontos ideais")

#testar σ 0.02 0.04 0.06  e 0.1

pa = dd.DyDeoParam(n_issues = 1, σ = 0.1,
                   size_nw = 500,
                   time = 500_000,
                   p = 0.9,
                   ρ = 0.0.5,
                   propintransigents = 0.0,
                   intranpositions = "extremes")

pa_to_states = dd.statesmatrix(pa)

#  pa_to_states[end,  :] |>  x -> round.(x,5) |> dd.outputfromsim


dd.@showprogress 1 "Plotting " for i in 1:pa.size_nw
    plot!(fig, pa_to_states[:,i])
end

png("image/tests01newrho")
println("done")


#runs arrays
# parametrizations_to_states = map(dd.statesmatrix,parametrizations)



#=
for i in zip(parametrizations,figs,parametrizations_to_states)
dd.@showprogress 1 "Plotting " for j in 1:i[1].size_nw
    plot!(i[2],i[3][:,j])
    end
end

=#

#=
a[1,:] |> std

a[pa.time,:]  |> std

round.(a[pa.time,:], 6) |> countmap

round.(a[1,:], 6) |> countmap

a[pa.time,:] |> countmap
=#


#plots->pnn

#=

dd.@showprogress 1 "Plotting " for i in 1:pa.size_nw
    plot!(fig,a[:,i])
end


#display(fig)
#closeall()


=#
