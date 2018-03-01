include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall
using DataFrames, CSV


@pyimport SALib.analyze.sobol as sobol

@load  "data/saltellisample1000.jld2" #param_values_saltelli1000

@load "data/saltellioutput1000.jld2" #Ysaltelli1000

problem  = Dict("num_vars" => 5,
             "names" => ["size_nw", "n_issues", "p", "σ", "ρ"],
             "bounds" => [[500, 5_000],
                          [1, 10],
                          [0.1, 0.99],
                          [0.01, 0.5],
                          [0.0, 0.1]])


function extractys(Ypairs)
    Ystd = Float64[]
    Ynips =  Int64[]
    for i in Ypairs
        push!(Ystd,i[1])
        push!(Ynips,i[2])
    end
    return(Ystd,Ynips)
end


Ystd1000,Ynips1000 = extractys(Ysaltelli1000)


Si_std = sobol.analyze(problem, Ystd1000)



# Si_nips = sobol.analyze(problem,Ynips1000)

Si_std["ST"]

Si_nips["ST"]


delete!(Si_std, "S2"); delete!(Si_std, "S2_conf")

varcolumn= DataFrame(Var = problem["names"])

stdsi_df = hcat(varcolumn,DataFrame(Si_std))

CSV.write("data/saltelli1000std.csv",stdsi_df)
