include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using StatsBase, IterTools, Plots, DataFrames, JLD2
gr()

σs = [ 0.02, 0.04, 0.06, 0.1, 0.14]
n_issues =  [1 5 10 20]


# Generate the data
test = (product(n_issues, σs) |> collect |> sort |>
        x->partition(x, length(σs)) |>collect)
       

test_results = []


function extractynips(Ypairs)
    Ystd = Float64[]
    Ynips =  Int64[]
    for i in Ypairs
        push!(Ystd,i[1])
        push!(Ynips,i[2])
    end
    return(Ynips)
end

for i in 1:length(test)    
    (map(x -> (x |> dd.multiruns |>
               y->round.(y,5)  |>
               dd.outputfromsim |>
               extractynips), test[i]) |>
     x -> (push!(test_results,x)))
end



@save "data/multi-out2.jld2" test_results


