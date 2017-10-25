using Distributions
# Define the entities = agents and network ------------------------------

#Structs for Agents and Beliefs --------------------

abstract type  AbstractAgent end

abstract  type PolAgent <: AbstractAgent end

mutable struct Belief{T<:AbstractFloat}
    o::T
    σ::T
    whichissue::Int
end

mutable struct Agent <: PolAgent
    id::Int
    ideo::Vector
    idealpoint::AbstractFloat
end


# Constructors for Agents, Beliefs and Network --------------------
function create_belief(σ,issue)
    o = rand(Uniform())
    belief = Belief(o, σ, issue)
end

function create_idealpoint(ideology)
    opinions = []
    for i in ideology
        push!(opinions,i.o)
    end
    ideal_point = mean(opinions)
end


function create_agent(n,id,σ)
    ideology = [create_belief(σ,i) for i in 1:n ]
    idealpoint = create_idealpoint(ideology)
    agent = Agent(id,ideology, idealpoint)
end

# network creation
" Creates an 1-d array of Agents with opinions ∈ [0,1]. Since it's a complete
graph + pairwise interaction i can create a list of Agents and pick two of them to
interact!!"

function create_nw(σ, n, size)
    nw = [create_agent(n,i,σ) for i in 1:size]
end



# Define the processes\actions ----------------------------------------
#helper function for the update rule/step. Create i,j with this then pass it to the other fns
function ij_comparison(nw)
    i,j = rand(nw), rand(nw)
    if i==j
        ij_comparison(nw)
    end
    return(i,j)
end


#helper for picking issue
function pick_issuebelief(i,j,n)
    issue_belief = rand(1:n)
    i_belief = i.ideo[issue_belief]
    j_belief = j.ideo[issue_belief]
    return(i_belief, j_belief)
end


# helper for posterior opinion and uncertainty
function calculate_pstar(i_belief, j_belief, p)
    numerator = p * (1 / (sqrt(2 * π ) * i_belief.σ ) )*
    exp(-((i_belief.o - j_belief.o)^2 / (2*i_belief.σ^2)))
    denominator = numerator + (1 - p)
    pₚ = numerator / denominator
    return(pₚ)
end


#helper for update_step
#=function calculate_posterior(i_belief,j_belief,p)
    σ = i_belief.σ
    pₚ = calculate_pstar(i,j,σ,p)
    posterior_opinion = pₚ * ((i.opinion + j.opinion) / 2) + (1 - pₚ) * i.opinion
end
=#


