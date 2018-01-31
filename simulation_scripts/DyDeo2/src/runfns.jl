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
    df = DataFrame(time = Integer[], id  = Integer[], ideology = Array[], ideal_point = Real[], neighbors = Array[])
    for agent in pop
        time = 0 
        push!(df,[time agent.id  [agent.ideo] agent.idealpoint [agent.neighbors]]) 
    end
    return df
end

"fn to update the df with relevant information"
function update_df!(pop,df,time)
    for agent in pop
        push!(df,[time  agent.id  [agent.ideo] agent.idealpoint [agent.neighbors]])
    end
    return(df)
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

"this fn runs the main procedure iteratively while updating the df; subject to change after the methodological review"
function runsim!(pop,df,p,σ,ρ,time)
    @showprogress 1 "Computing..." for step in 1:time
        agents_update!(pop,p, σ, ρ)
        update_df!(pop,df,step)
    end 
    return(df)
end

"repetition of the sim for some parameters ; should research more about the role of random seeds here"
function one_run(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type,graphcreator = pa
    df,pop = create_initdf(agent_type, σ, n_issues, size_nw,graphcreator)
    df = runsim!(pop,df,p,σ,ρ,time)
    return(df)
end
    

#= Plotting Functions

I'm gonna create an output csv, and those plot functions will plot data from it.

* Plot time series of ideal points
* Plot histogram of a given time
* Plot mg of a given time: coloured vertex!!! =#


"Should be refactored; "
function time_plot(which_df, n_issues, nagents, p, σ, ρ, agent_type)

    
    xlab = string("Time")
    ylab = string("Ideal Point") 

    @df which_df plot(:time,[:ideal_point],
                      group = :id,
                      dpi = 120, color = :black,
                      xlabel = xlab, ylabel = ylab,
                      α = 0.3)
    savefig("image/atype($(agent_type))_n($(nagents))_nissues($(n_issues))_p($(p))_sigma($(σ))_rho($(ρ))_tseries.png")
end


function mkdirs(filename)
    !(filename in readdir(pwd())) ? mkdir(filename): println("dir $(filename) exists... no need to create one ")
end




