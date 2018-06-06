include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall
const dd = DyDeo2



@pyimport SALib.sample.saltelli as saltelli

problem  = Dict("num_vars" => 6,
             "names" => ["size_nw", "n_issues", "p", "σ", "ρ", "p_intran"],
             "bounds" => [[500, 5_000],
                          [1, 10],
                          [0.1, 0.99],
                          [0.01, 0.5],
                          [0.0, 0.1],
                          [0.0, 0.3]])

paramvalues5k_6params = saltelli.sample(problem, 5000)


dd.@save  "data/sample5k6params.jld2" paramvalues5k_6params


Ysaltelli6params_70kvalues = dd.sweep_sample(paramvalues5k_6params,
                                time = 1_000_000,
                                agent_type = "mutating o")

dd.@save "data/saltelli-6params-70kvalues.jld2" Ysaltelli6params_70kvalues

println("done")
-
