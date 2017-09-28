using PyCall
using Distributions
using DataFrames
@pyimport seaborn as sns
@pyimport matplotlib.pyplot as plt


#define the agent
mutable struct Agent
    opinion::AbstractFloat
    id::Integer
end


function create_nw(size)
    nw = [Agent(rand(Uniform()),i) for i in 1:size]
end


function ij_comparison(nw)
    i,j = rand(nw), rand(nw)
    if i==j
        ij_comparison(nw)
    end
    return(i,j)
end

function update_step(nw,ϵ,i,j)
    if abs(i.opinion + j.opinion) < ϵ
        i.opinion = (i.opinion + j.opinion)/2
    end
    return nw
end

function update_step1(nw,ϵ)
    i,j = ij_comparison(nw)
    if abs(i.opinion + j.opinion) < ϵ
        i.opinion = (i.opinion - j.opinion)/2
    end
end



# testing stuff ----------------------------------------



function update_step2(nw,ϵ,i,j)
    if abs(i.opinion - j.opinion) < ϵ
        i.opinion = (i.opinion + j.opinion)/2
    end
    return nw
end


network = create_nw(10);  #network creation = ok

#i,j = ij_comparison(network)  #ij_comparison  = ok

#update_step2(network,0.8,i,j) #it works...

#=
function get_opinions(nw)
    a = []
    for i in nw
        push!(a,i.opinion)
    end
    return(a)
end
=#

network = create_nw(10);  #network creation = ok
println(network)
for i in 1:1000
    i,j = ij_comparison(network)
    network = update_step(network,0.8,i,j)
end
println(network)


