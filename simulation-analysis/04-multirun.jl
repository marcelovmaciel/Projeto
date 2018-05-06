include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using StatsBase, IterTools, Plots, DataFrames, JLD2
pyplot()

σs = [ 0.02 0.04 0.06 0.1 0.14]
n_issues =  [1 5 10]


# Generate the data
test = (product(n_issues, σs) |> collect |> sort |>
        x->partition(x, length(σs)) |>collect)
       

test_results = []

for i in 1:length(test)    
    (map(x -> (x |> dd.multiruns |> dd.extractynips), test[i]) |>
     x -> (push!(test_results,x)))
end

@save "data/multi-out.jld2" test_results


#Plot the data now

@load "data/multi-out.jld2"


#=
issuestodf = append!(n_issues', [missing, missing])

df = DataFrame(σ = σs, n_issues  = [n_issues, missing, missing])
=#

fig1 = plot(show = false)
fig2 = plot(show = false)
fig3 = plot(show = false)

boxmulti(results,fig) = [boxplot!(fig,i , legend = false) for i in results]

boxmulti(test_results[1],fig1)
boxmulti(test_results[2],fig2)
boxmulti(test_results[3],fig3)

finalfig = plot(fig1,fig2,fig3,layout = grid(3,1))
closeall()


testdict = Dict(0.1 => [1 2 3 4], 0.2 => "fool")

testdict[0.2]
