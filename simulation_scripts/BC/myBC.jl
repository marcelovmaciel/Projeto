using PyCall
using Distributions
@pyimport seaborn as sns
@pyimport matplotlib.pyplot as plt
@pyimport pandas as pd



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



function update_step(nw,ϵ)
    i,j = ij_comparison(nw)
    if abs(i.opinion - j.opinion) < ϵ
        i.opinion = (i.opinion - j.opinion)/2
    end
end

# Information Storing ----------------------------------------
function init_df(nw)




# plotting functions ----------------------------------------

# useful for the plot
function get_opinions(nw)
    a = []
    for i in nw
        push!(a,i.opinion)
    end
    return(a)
end

function opinion_series()

end

function opinion_dist(nw)
    x = get_opinions(nw)
    g = sns.distplot(x,hist = false, kde_kws = Dict("shade" => true))
    plt.show(g)
end


function run_simulation(size_nw,ϵ, time)
    nw = create_nw(size_nw)
    for i in 1:time
        update_step(nw,ϵ)
    end
end



# run_simulation(500,0.25,1000)


