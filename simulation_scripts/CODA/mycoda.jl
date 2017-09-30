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

#helper function for the update rule/step
function ij_comparison(nw)
    i,j = rand(nw), rand(nw)
    if i==j
        ij_comparison(nw)
    end
    return(i,j)
end

"Even though p and sigma are, in this version,
global variables i'm gonna put them inside the struct as pᵢ and σᵢ "

function update_step1(i,j,σ,p)
    numerator = i.p * (1 / (sqrt(2 * π ) * i.σ ) ) * exp(-((i.opinion - j.opinion)^2 / (2*i.σ^2)))
    denominator = numerator + (1 -  i.p)
    pₚ = numerator / denominator
    posterior_opinion = pₚ * ((i.opinion + j.opinion) / 2) + (1 - pₚ) * i.opinion
    i.opinion = posterior_opinion
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
function run_simulation(size_nw, p, σ, time)
    nw = create_nw(size_nw,p, σ)
    df = init_df(nw)
    for step in 1:time
        i,j = ij_comparison(nw)
        update_step1(i,j,σ,p)
        update_df(nw,df,step)
    end
    return(df)
end


result = run_simulation(500,0.7,0.3,10000)

writetable("output.csv", result)



