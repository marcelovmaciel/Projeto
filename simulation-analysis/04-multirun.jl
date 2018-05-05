include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using StatsBase, IterTools, Plots


σs = [ 0.02 0.04 0.06 0.1 0.14]
n_issues =  [1 5 10]


test = (product(n_issues, σs) |> collect |> sort |>
        x->partition(x, length(σs)) |>collect)
       

results = map(x -> (x |> dd.multiruns |> dd.extractynips), test[1])


fig = plot()

for i in results
    boxplot!(fig,i)
end



fig
closeall()
