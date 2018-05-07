include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using StatsBase, IterTools, Plots, DataFrames, JLD2
pyplot()

σs = [ 0.02, 0.04, 0.06, 0.1, 0.14]
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


