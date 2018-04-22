include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall
using DataFrames, CSV

const dd = DyDeo2

@pyimport SALib.analyze.sobol as sobol



#Helper fns and problem definition


problem  = Dict("num_vars" => 5,
             "names" => [ "n_issues", "p", "σ", "ρ", "p_intran"],
             "bounds" => [[1, 10],
                          [0.1, 0.99],
                          [0.01, 0.5],
                          [0.0, 0.1],
                          [0.0, 0.3]])


function extractys(Ypairs)
    Ystd = Float64[]
    Ynips =  Int64[]
    for i in Ypairs
        push!(Ystd,i[1])
        push!(Ynips,i[2])
    end
    return(Ystd,Ynips)
end

discretize(x) = round(Int,x)


# Data structures from the simulation 

@load    "data/sample5k5params.jld2" #paramvalues5k_5params 

@load "data/saltelli5k5params.jld2" #Ysaltelli5params

@load "data/saltellisample5000initcond.jld2" #saltelli5000_initialcond



#Turn the array initcond array into df then save it

initYstd,initYnips = extractys(saltelli5000_initialcond)

initcondf = DataFrame(std = initYstd, nips = initYnips)

CSV.write("data/saltelli70kinitcond.csv", initcondf)




# Create df for regression plot - 6params version


totaldf = DataFrame( N = map(discretize, param_values_saltelli5000[:,1]),
                     n_issues = map(discretize, param_values_saltelli5000[:,2]),
                     p = param_values_saltelli5000[:,3],
                     σ = param_values_saltelli5000[:,4],
                     ρ = param_values_saltelli5000[:,5],
                     p_intran = param_values_saltelli5000[:,6])

Ystd5000,Ynips5000 = extractys(Ysaltelli5params)

totaldf[:Ystd] = Ystd5000

CSV.write("data/5000paramsandresults.csv",totaldf)


#  Create df for sobol bar plot - 5params version

Si_std = sobol.analyze(problem, Ystd5000)

delete!(Si_std, "S2"); delete!(Si_std, "S2_conf")

varcolumn= DataFrame(Var = problem["names"])

stdsi_df = hcat(varcolumn,DataFrame(Si_std))

CSV.write("data/saltelli5000std.csv", stdsi_df)

