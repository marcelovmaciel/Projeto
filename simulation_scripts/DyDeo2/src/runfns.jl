# Types needed for the simulation

"Parameters for the simulation; makes the code cleaner"
@with_kw struct DyDeoParam{R<:Real}
    n_issues::Int = 1
    size_nw::Int = 2
    p::R = 0.9
    σ::R = 0.1
    time::Int = 2
    ρ::R = 0.01
    agent_type::String = "mutating o"
    graphcreator = CompleteGraph
    propintransigents::R = 0.1
    intranpositions::String = "random"
end

## Information Storing Fns
#I'm going to initialize a dataframe and update it at each time step.
"""
    create_initialcond(agent_type, σ, n_issues, size_nw,graphcreator,
                propintransigents; intranpositions = "random")

this fn is a helper for all other fns used in the simulation
"""
function create_initialcond(agent_type, σ, n_issues, size_nw,graphcreator,
                propintransigents; intranpositions = "random")
    pop = createpop(agent_type, σ, n_issues, size_nw)
    g = creategraphfrompop(pop,graphcreator)
    add_neighbors!(pop,g)
    createintransigents!(pop, propintransigents, position = intranpositions)
    return(pop)
end

"""
    function createstatearray(pop,time)

Creates an array with the agents' ideal points; it's an alternative to saving everything in a df

"""
function createstatearray(pop,time)
    statearray = Array{Array{Float64}}(time+1)'
    statearray[1] = pullidealpoints(pop)
    return(statearray)
end



"""
    create_initdf(pop)

fn to initialize the df; it should store all the info I may need later.
"""
function create_initdf(pop)
    df = DataFrame(time = Integer[], id  = Integer[],  ideal_point = Real[])
    for agent in pop
        time = 0 
        push!(df,[time agent.id  agent.idealpoint ]) 
    end
    return df
end

"""
    update_df!(pop,df,time)

fn to update the df with relevant information.
"""
function update_df!(pop,df,time)
    for agent in pop
        push!(df,[time  agent.id   agent.idealpoint ])
    end
    return(df)
end

"self-describing... it takes a population and returns an array of ideal points"
function pullidealpoints(pop)
    idealpoints = Float64[]
    for agent in pop
        push!(idealpoints,agent.idealpoint)
    end
    return(idealpoints)
end

"""
    outputfromsim(endpoints::Array)
fn to turn extracted information into system measures; pressuposes an array with some system state (set of agents attributes)
"""
function outputfromsim(endpoints::Array)
    stdpoints = std(endpoints)
    num_points = endpoints |> countmap |> length
    return(stdpoints,num_points)
end


#= Running Functions
=#

"""
    agents_update!(population,p, σ, ρ)

this executes the main procedure of the model: one pair of agents interact and another updates randomly (noise).
"""
function agents_update!(population,p, σ, ρ)
    updateibelief!(rand(population),population,p)
    ρ_update!(rand(population), ρ)
    return(population)
end


"""
    runsim!(pop,df::DataFrame,p,σ,ρ,time)
this fn runs the main procedure iteratively while updating the df;

"""
function runsim!(pop,df::DataFrame,p,σ,ρ,time)
   for step in 1:time
        agents_update!(pop,p, σ, ρ)
        update_df!(pop,df,step)
    end 
    return(df)
end

"""
    runsim!(pop,p,σ,ρ,time)

runs the main procedure iteratively then returns the final population

"""
function runsim!(pop,p,σ,ρ,time)
    for step in 1:time
        agents_update!(pop, p, σ, ρ)
    end
    return(pop)
end


"repetition of the sim for some parameters;"
function one_run(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator, propintransigents, intranpositions = pa
    pop = create_initialcond(agent_type, σ, n_issues, size_nw,graphcreator, propintransigents, intranpositions = intranpositions)
    initdf = create_initdf(pop)
    df = runsim!(pop,df,p,σ,ρ,time)
    return(df)
end
    

"""this runs the simulation without using any df;
this speeds up a lot the sim, but i can't keep track of the system state evolution;
that is, I only save the end state
"""
function simple_run(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator, propintransigents, intranpositions = pa
    pop = create_initialcond(agent_type, σ, n_issues, size_nw,graphcreator, propintransigents, intranpositions = intranpositions)
    endpop = runsim!(pop,p,σ,ρ,time)
    return(endpop)
end


"""
    simstatesvec(pa::DyDeoParam)
runs the simulation and keeps each iteration configuration (ideal points)

"""
function simstatesvec(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator, propintransigents, intranpositions = pa
    pop = create_initialcond(agent_type, σ, n_issues, size_nw,graphcreator, propintransigents, intranpositions = intranpositions)
    statearray = createstatearray(pop, pa.time)

    for step in 1:time
        pop = agents_update!(pop,p, σ, ρ)
        statearray[step+1] =  pop |> pullidealpoints
       end
    return(statearray)
end


"""
    statesmatrix(statearray, time, size_nw)
fn to turn the system configurations (its state) into a matrix. I need to plot the agents' time series.
Takes a lot of time (10 min for 1.000.000 iterations and 1000 agents)
"""
function statesmatrix(pa; time = pa.time , size_nw = pa.size_nw)
    a = Array{Float64}(time+1,size_nw)
    statesvec = simstatesvec(pa)

   @showprogress 1 "Computing..." for (step,popstate) in enumerate(statesvec)
        for (agent_indx,agentstate) in enumerate(popstate)
            a[step,agent_indx] = agentstate
        end
    end
    return(a)
end


"""
    sweep_sample(param_values; time = 250_000, agent_type = "mutating o")

this fn pressuposes an array of param_values where each column is a param and each row is a parametization;
Then it runs the sim for each parametization and pushs system measures to another array (the output array)
"""
function sweep_sample(param_values; size_nw = 500, time = 250_000, agent_type = "mutating o")
    Y = []
@showprogress 1 "Computing..." for i in 1:size(param_values)[1]
    paramfromsaltelli = DyDeoParam(size_nw =  round(Int,param_values[i,1]),
                                    n_issues = round(Int,param_values[i,2]),
                                    p = param_values[i,3],
                                    σ = param_values[i,4],
                                    ρ = param_values[i,5],
                                    propintransigents = param_values[i,6],
                                    time = time,
                                    agent_type = agent_type)
        out  =  simple_run(paramfromsaltelli) |> pullidealpoints |> outputfromsim
        push!(Y,out)
    end
    return(Y)
end

"""
    function getsample_initcond(param_values; time = 250_000, agent_type = "mutating o")
returns Initstd and Initnips (outputfromsim from initialcond)

"""
function getsample_initcond(param_values; time = 250_000, agent_type = "mutating o")

    param_values[:,1] = round.(Int,param_values[:,1])
    param_values[:,2] = round.(Int,param_values[:,2])
    Y = Tuple{Float64,Int64}[]

    @showprogress 1 "Computing..." for i in 1:size(param_values)[1]
        paramfromsaltelli = DyDeoParam(size_nw = convert(Int,param_values[i,1]),
                                       n_issues = convert(Int,param_values[i,2]),
                                       p = param_values[i,3],
                                       σ = param_values[i,4],
                                       ρ = param_values[i,5],
                                       propintransigents = param_values[i,6],
                                       time = time,
                                       agent_type = agent_type)
        @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator, propintransigents, intranpositions = paramfromsaltelli
        pop = create_initialcond(agent_type, σ, n_issues, size_nw,graphcreator, propintransigents, intranpositions = intranpositions)
        out = pop |> pullidealpoints |> outputfromsim
        push!(Y,out)
    end
    return(Y)
end



function extractys(Ypairs)
    Ystd = Float64[]
    Ynips =  Int64[]
    for i in Ypairs
        push!(Ystd,i[1])
        push!(Ynips,i[2])
    end
    return(Ystd,Ynips)
end


"""
function multiruns(sigmanissues::Tuple; repetitions = 50)

    helper function to plot the box plots
"""
function multiruns(sigmanissues::Tuple; repetitions = 100) 
    pa = DyDeoParam(n_issues = sigmanissues[1],
                       σ = sigmanissues[2],
                       size_nw = 500,
                       time = 1_000_000,
                       p = 0.9,
                       ρ = 1e-5,
                       propintransigents = 0.0,
                       intranpositions = "random")

    repetitionsout = Array{Float64}[]

@showprogress 1 "Multiruns"    for run in 1:repetitions
        singleout = simple_run(pa) |> pullidealpoints 
        push!(repetitionsout,singleout)
    end
    return(repetitionsout)
end


function mkdirs(filename)
    !(filename in readdir(pwd())) ? mkdir(filename): println("dir $(filename) exists... no need to create one ")
end
