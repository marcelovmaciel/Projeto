#= File with functions to run the simulation and store/plot results

This includes:
* Fns to store the simulation information;
* Fns to update the collections of agent;
* Fns to write the results into csvs;
* Fns to plot from the csvs;
=#



# Types needed for the simulation


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


function init_df(pop)
    df = DataFrame(time = Integer[], id  = Integer[], ideology = Array[], ideal_point = Real[], neighbors = Array[])
    for agent in pop
        time = 0 
        push!(df,[time agent.id  [agent.ideo] agent.idealpoint [agent.neighbors]]) 
    end
    return df
end

function update_df!(pop,df,time)
    for agent in pop
        push!(df,[time  agent.id  [agent.ideo] agent.idealpoint [agent.neighbors]])
    end
    return(df)
end

#= Running Functions
=#


function agents_update!(population,p, σ, ρ)
    updateibelief!(rand(population),population,p)
    ρ_update!(rand(population), σ,ρ)
    return(population)
end

function create_initdf(agent_type, σ, n_issues, size_nw,graphcreator)
    pop = listofagents(agent_type, σ, n_issues, size_nw)
    g = creategraphfrompop(pop,graphcreator)
    add_neighbors!(pop,g)
    df = init_df(pop)
    return(df,pop)
end

function runsim!(pop,df,p,σ,ρ,time)
    @showprogress 1 "Computing..." for step in 1:time
        agents_update!(pop,p, σ, ρ)
        update_df!(pop,df,step)
    end 
    return(df)
end

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



function time_plot(which_df, n_issues, nagents, p, σ, ρ, agent_type)

    
    xlab = string("Time")
    ylab = string("Ideal Point") 

    @df which_df plot(:time,[:ideal_point],
                      group = :id,
                      dpi = 120, color = :black,
                      xlabel = xlab, ylabel = ylab,
                      α = 0.3)
    savefig("images/atype($(agent_type))_n($(nagents))_nissues($(n_issues))_p($(p))_sigma($(σ))_rho($(ρ))_tseries.png")
end


function mkimdir()
    !("images" in readdir(pwd())) ? mkdir("images"): println("dir images exists... no need to create one ")
end




