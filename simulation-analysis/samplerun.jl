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

param_values_saltelli5000_mutatingsigma = saltelli.sample(problem,5000)


@save  "data/saltellisample5000mutatingsigma.jld2" param_values_saltelli5000_mutatingsigma


Ysaltelli5000mutatingsigma = sweep_sample(param_values_saltelli5000_mutatingsigma,
                             time = 1_000_000,
                             agent_type = "mutating o and sigma")

println("done")

@save "data/saltellioutput5000mutatingsigma.jld2" Ysaltelli5000mutatingsigma





