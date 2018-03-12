include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall
using DataFrames, CSV

const dd = DyDeo2

@pyimport SALib.analyze.sobol as sobol

@load  "data/saltellisample5000.jld2" #param_values_saltelli5000

@load "data/saltellioutput5000.jld2" #Ysaltelli1000

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


# Create df for regression plot


totaldf = DataFrame( N = map(dd.discretize, param_values_saltelli5000[:,1]),
                     n_issues = map(dd.discretize, param_values_saltelli5000[:,2]),
                     p = param_values_saltelli5000[:,3],
                     σ = param_values_saltelli5000[:,4],
                     ρ = param_values_saltelli5000[:,5])

Ystd5000,Ynips5000 = extractys(Ysaltelli5000)

totaldf[:Ystd] = Ystd5000

CSV.write("data/muto5000paramsandresults.csv",totaldf)


#  Create df for sobol bar plot


Si_std = sobol.analyze(problem, Ystd5000)

delete!(Si_std, "S2"); delete!(Si_std, "S2_conf")

varcolumn= DataFrame(Var = problem["names"])

stdsi_df = hcat(varcolumn,DataFrame(Si_std))

CSV.write("data/saltelli5000std.csv", stdsi_df)
