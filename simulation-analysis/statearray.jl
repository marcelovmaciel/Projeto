include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using Plots
using StatsBase, LaTeXStrings
inspectdr(legend = false)


# pre-plots

#finalplot = plot(figs[1], figs[2])

σs = [ 0.02 0.05  0.1]

parametrizations = [dd.DyDeoParam(n_issues = 7, σ = σ, size_nw = 500,
                                  time = 500_000, p = 0.7,
                                  ρ = 0.0, propintransigents = 0.0) for σ in σs]


figs = [plot(show = false, xlabel = "iterações",
             ylabel = "valor do ponto ideal", title = "$(i)"  ) for i in 1:length(parametrizations)]

# pa = dd.DyDeoParam(n_issues = 7, σ = 0.05, size_nw = 500, time = 100_000, p = 0.7,
 #                  ρ = 0.0, propintransigents = 0.0)

#runs arrays
parametrizations_to_states = map(dd.statesmatrix,parametrizations)


for i in zip(parametrizations,figs,parametrizations_to_states)
dd.@showprogress 1 "Plotting "    for j in 1:i[1].size_nw
    plot!(i[2],i[3][:,j])
    end
end

plot(figs[1],figs[2],figs[3])


savefig("image/testmulti.png")
#finalplot = plot(figs[1],figs[2],figs[3])

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
