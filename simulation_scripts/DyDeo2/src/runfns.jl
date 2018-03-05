#= File with functions to run the simulation and store/plot results

This includes:
* Fns to store the simulation information;
* Fns to update the collections of agent;
* Fns to write the results into csvs;
* Fns to plot from the csvs;
=#



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
    
end

## Information Storing Fns
#I'm going to initialize a dataframe and update it at each time step.

"fn to initialize the df; it should store all the info I may need later"
function init_df(pop)
    df = DataFrame(time = Integer[], id  = Integer[],  ideal_point = Real[])
    for agent in pop
        time = 0 
        push!(df,[time agent.id  agent.idealpoint ]) 
    end
    return df
end

"fn to update the df with relevant information"
function update_df!(pop,df,time)
    for agent in pop
        push!(df,[time  agent.id   agent.idealpoint ])
    end
    return(df)
end

function pullidealpoints(pop)
    endpoints = Float64[]
    for agent in pop
        push!(endpoints,agent.idealpoint)
    end
    return(endpoints)
end


"fn to save the parameters"
function save_params(params)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator = params
    striped_agenttype = filter(x -> !isspace(x),agent_type)
    @save "data/atype($(striped_agenttype))_n($(size_nw))_nissues($(n_issues))_p($(p))_sigma($(σ))_rho($(ρ))_graphis($(graphcreator)).jld2" params
end


function savetodisc(object,name)
    @save name object
end


#= Running Functions
=#

"this executes the main procedure of the model: one pair of agents interact and another updates randomly (noise)"
function agents_update!(population,p, σ, ρ)
    updateibelief!(rand(population),population,p)
    ρ_update!(rand(population), σ,ρ)
    return(population)
end

"this fn creates the population |> update it with the neighbors |> initialize the df"
function create_initdf(agent_type, σ, n_issues, size_nw,graphcreator)
    pop = createpop(agent_type, σ, n_issues, size_nw)
    g = creategraphfrompop(pop,graphcreator)
    add_neighbors!(pop,g)
    df = init_df(pop)
    return(df,pop)
end

"""
this fn runs the main procedure iteratively while updating the df;

it may also only return the final vec of agents 

"""

function runsim!(pop,df,p,σ,ρ,time)
   for step in 1:time
        agents_update!(pop,p, σ, ρ)
        update_df!(pop,df,step)
    end 
    return(df)
end


function runsim!(pop,p,σ,ρ,time)
    for step in 1:time
        agents_update!(pop, p, σ, ρ)
    end
    return(pop)
end


"repetition of the sim for some parameters ;"
function one_run(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator = pa
    df,pop = create_initdf(agent_type, σ, n_issues, size_nw,graphcreator)
    df = runsim!(pop,df,p,σ,ρ,time)
    return(df)
end
    

function simple_run(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator = pa
    pop = createpop(agent_type, σ, n_issues, size_nw)
    g = creategraphfrompop(pop,graphcreator)
    add_neighbors!(pop,g)
    endpop = runsim!(pop,p,σ,ρ,time)
    endpoints = pullidealpoints(endpop)
    return(endpoints)
end



discretize(parameter) = convert(Int,round(parameter))


function outputfromsim(endpoints::Array)
    stdpoints = std(endpoints)
    num_points = endpoints |> countmap |> length
    return(stdpoints,num_points)
end



function sweep_sample(param_values; time = 250_000, agent_type = "mutating o")
    Y = []
@showprogress 1 "Computing..." for i in 1:size(param_values)[1]
        paramfromsaltelli = DyDeoParam(size_nw = discretize(param_values[i,1]),
                               n_issues = discretize(param_values[i,2]),
                               p = param_values[i,3],
                               σ = param_values[i,4],
                                       ρ = param_values[i,5],
                                       time = time,
                                       agent_type = agent_type)
        out  =  simple_run(paramfromsaltelli) |> outputfromsim
        push!(Y,out)
    end
    return(Y)
end



#= Plotting Functions

I'm gonna create an output csv, and those plot functions will plot data from it.

* Plot time series of ideal points
* Plot histogram of a given time
* Plot mg of a given time: coloured vertex!!! =#


"Should be refactored; "
function time_plot(which_df, params)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator = params
    
    xlab = string("Time")
    ylab = string("Ideal Point") 
    striped_agenttype = filter(x -> !isspace(x),agent_type)

    @df which_df plot(:time,[:ideal_point],
                      group = :id,
                      dpi = 120, color = :black,
                      xlabel = xlab, ylabel = ylab,
                      α = 0.3)
    savefig("image/atype($(striped_agenttype))_n($(size_nw))_nissues($(n_issues))_p($(p))_sigma($(σ))_rho($(ρ))_graphis($(graphcreator))_tseries.png")
end


function mkdirs(filename)
    !(filename in readdir(pwd())) ? mkdir(filename): println("dir $(filename) exists... no need to create one ")
end




