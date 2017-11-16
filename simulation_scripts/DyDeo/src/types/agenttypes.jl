# Define the entities = agents and network ------------------------------

#Structs for Agents and Beliefs --------------------

abstract type  AbstractAgent end
abstract  type PolAgent <: AbstractAgent end

mutable struct Belief{T<:Real}
    o::T
    σ::T
    whichissue::Integer
end

mutable struct Agent <: PolAgent
    id::Integer
    ideo::Vector
    idealpoint::Real
end



