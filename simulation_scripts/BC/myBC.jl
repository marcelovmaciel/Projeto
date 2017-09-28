using PyCall
using Distributions
using DataFrames
@pyimport seaborn as sns
@pyimport matplotlib.pyplot as plt



# Define the entities = agents and network ----------------------------------

#define the agent
mutable struct Agent
    opinion::AbstractFloat
    id::Integer
end

# network creation


"""
Creates an 1-d array of Agents with opinions  ∈ [0,1]
Since it's a complete graph + pairwise interaction i
can create a list of Agents and pick two of them to interact!!
"""
function create_nw(size)
    nw = [Agent(rand(Uniform()),i) for i in 1:size]
end



# Define the actions ----------------------------------------


#helper function for the update rule/step
function ij_comparison(nw)
    i,j = rand(nw), rand(nw)
    if i==j
        ij_comparison(nw)
    end
    return(i,j)
end

function update_step(nw,ϵ,i,j)
    if abs(i.opinion - j.opinion) < ϵ
        i.opinion = (i.opinion + j.opinion)/2
    end
    return nw
end


# Information Storing ----------------------------------------


function init_df(nw)
    dt = DataFrame(time = [], opinion = [], id  = [])
    for i in nw
        time = 0
        push!(dt,[time i.opinion i.id]) 
    end
    return dt
end

function update_df(nw,dt,time)
    for i in nw
        push!(dt,[time i.opinion i.id])
    end
end

# Running Commands ----------------------------------------
function run_simulation(size_nw,ϵ, time)
    nw = create_nw(size_nw)
    df = init_df(nw)
    for step in 1:time
        i,j = ij_comparison(nw)
        nw = update_step(nw,ϵ,i,j)
        update_df(nw,df,step)
    end
    return(df)
end

result = run_simulation(500,0.3,10000)

writetable("output.csv", result)



