include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2, PyCall
using DataFrames, CSV

const dd = DyDeo2

@pyimport SALib.analyze.sobol as sobol



#Helper fns and problem definition


problem  = Dict("num_vars" => 6,
             "names" => ["size_nw", "n_issues", "p", "σ", "ρ", "p_intran"],
             "bounds" => [[500, 5_000],
                          [1, 10],
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

dd.@load  "data/sample5k6params.jld2" #paramvalues5k_6params 

dd.@load "data/saltelli-6params-70kvalues.jld2" #Ysaltelli6params_70kvalues

dd.@load "data/saltellisample5000initcond.jld2" #saltelli5000_initialcond


#Turn the array initcond array into df then save it

initYstd,initYnips = extractys(saltelli5000_initialcond)

initcondf = DataFrame(std = initYstd, nips = initYnips)

CSV.write("data/saltelli70kinitcond.csv", initcondf)


# Create df for regression plot - 6params version

totaldf = DataFrame( N = map(discretize, paramvalues5k_6params[:,1]),
                     n_issues = map(discretize, paramvalues5k_6params[:,2]),
                     p = paramvalues5k_6params[:,3],
                     σ = paramvalues5k_6params[:,4],
                     ρ = paramvalues5k_6params[:,5],
                     p_intran = paramvalues5k_6params[:,6])

Ystd5000,Ynips5000 = extractys(Ysaltelli6params_70kvalues)

totaldf[:Ystd] = Ystd5000

CSV.write("data/5000paramsandresults.csv",totaldf)


#  Create df for sobol bar plot - 5params version

Si_std = sobol.analyze(problem, Ystd5000)

varcolumn= DataFrame(Var = problem["names"])

S2indices =hcat(varcolumn,
                DataFrame(N = Si_std["S2"][:,1],
                          n_issues = Si_std["S2"][:,2],
                          p = Si_std["S2"][:,3],
                          σ = Si_std["S2"][:,4], 
                          ρ = Si_std["S2"][:,5],
                          p_intran = Si_std["S2"][:,6]))

CSV.write("data/saltelli5000S2.csv", S2indices)

delete!(Si_std, "S2"); delete!(Si_std, "S2_conf")

stdsi_df = hcat(varcolumn,DataFrame(Si_std))

CSV.write("data/saltelli5000std.csv", stdsi_df)

