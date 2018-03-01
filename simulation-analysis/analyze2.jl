include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall

@pyimport SALib.sample.saltelli as saltelli

mkdirs("data")


problem  = Dict("num_vars" => 5,
             "names" => ["size_nw", "n_issues", "p", "σ", "ρ"],
             "bounds" => [[500, 5_000],
                          [1, 10],
                          [0.1, 0.99],
                          [0.01, 0.5],
                          [0.0, 0.1]])

param_values_saltelli1000 = saltelli.sample(problem,1000)


@save  "data/saltellisample1000.jld2" param_values_saltelli1000


Ysaltelli1000 = sweep_sample(param_values_saltelli1000)

println("done")

@save "data/saltellioutput1000.jld2" Ysaltelli1000





