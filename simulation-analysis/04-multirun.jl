include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2
using StatsBase, IterTools, Plots


test = (let
          σs = [ 0.02 0.04 0.06 0.1 0.14]
          n_issues =  [1 5 10]
          product(n_issues, σs) |> collect |> sort |>
          x->partition(x, length(σs)) |>collect
          end) 

Ystd, Ynips = test[1][5] |> dd.multiruns |> dd.extractys


pyplot()

plot([mean(Ynips)], yerr = std(Ynips)) 
