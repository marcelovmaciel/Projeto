#= File with  base functions/types for my simulation

This includes:
* Types for Beliefs and Agents;
* Functions to create agents;
* Functions to create the network;
* Functions to update the agents' beliefs;
=#

#= Type declarations

The code primary elements are the the Belief and Agent types. A belief is a pair
σ, μ  of uncertainty and expected value of a distribution about a
issue. So the type Belief has 3 fields. An Agent will have an id, a set of
beliefs, an ideal point (which will be the mean of its opinions μ = o   and
a set of neighbors. The opinion will be generated from an Uniform(0,1)
distribution, while the uncertainty is going to be, in this version, a global
var. =#



#Structs for Agents and Beliefs --------------------



abstract type  AbstractAgent end
abstract type AbstractBelief end 

"Concrete type for Agents' beliefs; comprised of opinion, uncertainty and an id (whichissue)"
mutable struct Belief{T1 <: Real, T2 <: Integer}
    o::T1
    σ::T1
    whichissue::T2
end

"Concrete type for an Agent which only change its opinion"
mutable struct Agent_o{T1 <: Integer, T2 <: Vector, T3 <: Real, T4 <: Vector} <: AbstractAgent
    id::T1
    ideo::T2
    idealpoint::T3
    neighbors::T4
end

"Concrete type for an Agent which changes both opinion and uncertainty"
mutable struct Agent_oσ{T1 <: Integer,T2 <: Vector,T3 <: Real, T4 <: Vector} <: AbstractAgent
    id::T1
    ideo::T2
    idealpoint::T3
    neighbors::T4
end

#= "Constructors" for Beliefs, Agents and Graphs
=#


"Instantiates beliefs; note o is taken from an Uniform while σ is global and an input"
function create_belief(σ::Real, issue::Integer)
    o = rand(Uniform())
    belief = Belief(o, σ, issue)
end

function create_idealpoint(ideology)
    opinions = []
    for issue in ideology
        push!(opinions,issue.o)
    end
    ideal_point = mean(opinions)
end

"Instantiates  agents; note that there are two kinds of them"
function create_agent(agent_type,n_issues::Integer, id::Integer, σ::Real)
    ideology = [create_belief(σ, issue) for issue in 1:n_issues ]
    idealpoint = create_idealpoint(ideology)
    if agent_type == "mutating o"
        agent = Agent_o(id,ideology, idealpoint,[0])
    elseif agent_type == "mutating o and sigma"
        agent = Agent_oσ(id,ideology, idealpoint,[0])
    else
        println("specify agent type: mutating o or mutating o and sigma")
    end
    return(agent)
end

"Creates an array of agents"
function createpop(agent_type, σ::Real,  n_issues::Integer, size::Integer)
    population = [create_agent(agent_type, n_issues,i,σ) for i in 1:size]
end

"Creates a graph; helper for add_neighbors!"
function creategraphfrompop(population, graphcreator)
    graphsize = length(population)
    nw = graphcreator(graphsize)
    return(nw)
end

"adds the neighbors from nw to pop; the fn neighbors is from LightGraphs"
function add_neighbors!(population, nw)
    for i in population
        i.neighbors = neighbors(nw,i.id)
    end
end


#= Interaction functions
=#

"Chooses and returns a neighbor for i"
function getjtointeract(i::AbstractAgent,  population)
    whichj = rand(i.neighbors)
    j = population[whichj]
end


"""Takes two agents and returns a tuple with:
 - wich issue they discuss
 - i and j beliefs
"""
function pick_issuebelief(i::AbstractAgent, j::AbstractAgent)
    whichissue= rand(1:length(i.ideo))
    i_belief = i.ideo[whichissue]
    j_belief = j.ideo[whichissue]
    return(whichissue, i_belief, j_belief)
end

# Using the information from mg to update population' -----------------------------

"helper for posterior opinion and uncertainty"
function calculate_pstar(i_belief::Belief, j_belief::Belief, p::AbstractFloat)
    numerator = p * (1 / (sqrt(2 * π ) * i_belief.σ ) )*
    exp(-((i_belief.o - j_belief.o)^2 / (2*i_belief.σ^2)))
    denominator = numerator + (1 - p)
    pₚ  = numerator / denominator
    return(pₚ)
end

# Helper for update step
"Input = beliefs in an issue and confidence paramater; Output = i new opinion"
function calc_posterior_o(i_belief::Belief, j_belief::Belief, p::AbstractFloat)
    pₚ = calculate_pstar(i_belief, j_belief, p)
    posterior_opinion = pₚ * ((i_belief.o + j_belief.o) / 2) +
        (1 - pₚ) * i_belief.o
end

"helper for update_step"
function calc_pos_uncertainty(i_belief::Belief, j_belief::Belief, p::AbstractFloat)
    pₚ = calculate_pstar(i_belief, j_belief, p)
    posterior_uncertainty = sqrt(i_belief.σ^2 * ( 1 - pₚ/2) + pₚ * (1 - pₚ) *
                                 ((i_belief.o - j_belief.o)/2)^2)
end

" update_step for changing opinion but not belief"
function update_o!(i::AbstractAgent, which_issue::Integer, posterior_o::AbstractFloat)
    i.ideo[which_issue].o = posterior_o
    newidealpoint = create_idealpoint(i.ideo)
    i.idealpoint = newidealpoint
end

"update_step for the version with changing opinions and changing uncertainty"
function update_oσ!(i::AbstractAgent,issue_belief::Integer, 
        posterior_o::AbstractFloat, posterior_σ::AbstractFloat)
    i.ideo[issue_belief].o = posterior_o
    i.ideo[issue_belief].σ = posterior_σ
    newidealpoint = create_idealpoint(i.ideo)
    i.idealpoint = newidealpoint
end

"Main update fn; has two methods depending on the agent type"
function updateibelief!(i::Agent_o, population, p::AbstractFloat )
    
    j = getjtointeract(i,population)
    whichissue,ibelief,jbelief = pick_issuebelief(i,j)
    pos_o = calc_posterior_o(ibelief,jbelief, p)
    update_o!(i,whichissue,pos_o)      
end


function updateibelief!(i::Agent_oσ, population,p::AbstractFloat )
    
    j = getjtointeract(i, population)
    whichissue,ibelief,jbelief = pick_issuebelief(i,j)
    pos_o = calc_posterior_o(ibelief,jbelief, p)
    pos_σ = calc_pos_uncertainty(ibelief, jbelief, p)
    update_oσ!(i,whichissue,pos_o, pos_σ)      
end


"fn for noise updating; note it returns a randomly taken o but the new σ is the initial one"
function ρ_update!(i::AbstractAgent,  σ::AbstractFloat, ρ::AbstractFloat)

    ξ = rand(Uniform())
    whichissue = rand(1:length(i.ideo))
    if ξ < ρ
        i.ideo[whichissue].o = rand(Uniform())
        i.ideo[whichissue].σ = σ
        newidealpoint = create_idealpoint(i.ideo)
        i.idealpoint = newidealpoint
    end
end