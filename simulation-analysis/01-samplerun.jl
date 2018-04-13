include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall


@pyimport SALib.sample.saltelli as saltelli

mkdirs("data")


problem  = Dict("num_vars" => 6,
             "names" => ["size_nw", "n_issues", "p", "σ", "ρ", "p_intran"],
             "bounds" => [[500, 5_000],
                          [1, 10],
                          [0.1, 0.99],
                          [0.01, 0.5],
                          [0.0, 0.1],
                          [0.0, 0.1]])

param_values_saltelli5000 = saltelli.sample(problem, 5000)


@save  "data/saltellisample5000.jld2" param_values_saltelli5000


Ysaltelli5000 = sweep_sample(param_values_saltelli5000,
                             time = 1_000_000,
                             agent_type = "mutating o")

println("done")

@save "data/saltellioutput5000.jld2" Ysaltelli5000


