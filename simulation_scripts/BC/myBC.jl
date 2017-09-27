using PyCall
using Distributions
@pyimport seaborn as sns
@pyimport matplotlib.pyplot as plt


#define the agent
mutable struct Agent
    opinion::AbstractFloat
    id::Integer
end


# network creation

#=
since it's a complete graph + pairwise interaction i can create a list of Agents and pick two of them to interact!!

=#
function create_nw(size)
    nw = [Agent(rand(Uniform()),i) for i in 1:size]
end


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

function get_opinions(nw)
    a = []
    for i in nw
        push!(a,i.opinion)
    end
    return(a)
end


#=
to pick a random element from the array
array = [1 2 3 4]

rand(array)
=#


#=
To plot the distribution


sns.distplot(x,hist = false, kde_kws = Dict("shade" => true))
plt.show()
=#

