
module Andre2009

export run_simulation_v1, run_simulation_v2

using Distributions
using DataFrames

# Define the entities = agents and network ----------------------------------

#define the agent
mutable struct Agent
    opinion::AbstractFloat
    σ::AbstractFloat
    p::AbstractFloat
    id::Integer
end

# network creation
" Creates an 1-d array of Agents with opinions ∈ [0,1]. Since it's a complete
graph + pairwise interaction i can create a list of Agents and pick two of them to
interact!!"
function create_nw(size, p, σ)
    nw = [Agent(rand(Uniform()),σ,p,i) for i in 1:size]
end


# Define the actions ----------------------------------------
#helper function for the update rule/step. Create i,j with this then pass it to the other fns
function ij_comparison(nw)
    i,j = rand(nw), rand(nw)
    if i==j
        ij_comparison(nw)
    end
    return(i,j)
end

"Even though p and sigma are, in this version,
global variables i'm gonna put them inside the struct as pᵢ and σᵢ "

# helper for posterior opinion and uncertainty
function calculate_pstar(i,j,σ,p)
    numerator = i.p * (1 / (sqrt(2 * π ) * i.σ ) ) * exp(-((i.opinion - j.opinion)^2 / (2*i.σ^2)))
    denominator = numerator + (1 -  i.p)
    pₚ = numerator / denominator
    return(pₚ)
end


#helper for update_step
function calculate_posterior(i,j,σ,p)
    pₚ = calculate_pstar(i,j,σ,p)
    posterior_opinion = pₚ * ((i.opinion + j.opinion) / 2) + (1 - pₚ) * i.opinion
end


#helper for update_step
function calculate_pos_uncertainty(i,j,σ,p)
    pₚ = calculate_pstar(i,j,σ,p)
    posterior_uncertainty = sqrt(i.σ^2 * ( 1 - pₚ/2) + pₚ * (1 - pₚ) * ((i.opinion - j.opinion)/2)^2)
end


# update_step for the version with changing opinions but unchanging uncertainty
function update_step1!(i,j,σ,p)
    posterior_opinion = calculate_posterior(i,j,σ,p)
    i.opinion = posterior_opinion
end

# update_step for the version with changing opinions and changing uncertainty
function update_step2!(i,j,σ,p)
    posterior_opinion = calculate_posterior(i,j,σ,p)
    posterior_uncertainty = calculate_pos_uncertainty(i,j,σ,p)
    i.opinion = posterior_opinion
    i.σ = posterior_uncertainty
end


# Information Storing ----------------------------------------

# information storing for v1 --------------------
function init_df1(nw)
    dt = DataFrame(time = [], opinion = [], id  = [])
    for i in nw
        time = 0
        push!(dt,[time i.opinion i.id]) 
    end
    return dt
end

function update_df1!(nw,dt,time)
    for i in nw
        push!(dt,[time i.opinion i.id])
    end
end

#information storing for v2 --------------------

function init_df2(nw)
    dt = DataFrame(time = [], opinion = [], uncertainty = [],  id  = [])
    for i in nw
        time = 0
        push!(dt,[time i.opinion i.σ  i.id]) 
    end
    return dt
end


function update_df2!(nw,dt,time)
    for i in nw
        push!(dt,[time i.opinion i.σ  i.id])
    end
end

# Running Commands ----------------------------------------
function run_simulation_v1(; size_nw = size_nw, p = p, σ = σ, time = time)
    nw = create_nw(size_nw,p, σ)
    df = init_df1(nw)
    for step in 1:time
        i,j = ij_comparison(nw)
        update_step1!(i,j,σ,p)
        update_df1!(nw,df,step)
    end
    return(df)
end

function run_simulation_v2(; size_nw = size_nw, p = p, σ = σ, time = time)
    nw = create_nw(size_nw,p, σ)
    df = init_df2(nw)
    for step in 1:time
        i,j = ij_comparison(nw)
        update_step2!(i,j,σ,p)
        update_df2!(nw,df,step)
    end
    return(df)
end

end
