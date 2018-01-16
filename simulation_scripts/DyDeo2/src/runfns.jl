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
    
end

## Information Storing Fns
#I'm going to initialize a dataframe and update it at each time step.

# going to think about the dataframe for v2. put mean and std uncertainty??
function init_df(nw)
    copypop = deepcopy(nw)
    df = DataFrame(time = Integer[], id  = Integer[], ideology = Array[], ideal_point = Real[], neighbors = Array[])
    for agent in copypop
        time = 0 
        push!(df,[time agent.id  [agent.ideo] agent.idealpoint [agent.neighbors]]) 
    end
    return df
end

function update_df!(nw,df,time)
    copypop = deepcopy(nw)
    for agent in copypop
        push!(df,[time  agent.id  [agent.ideo] agent.idealpoint [agent.neighbors]])
    end
    return(df)
end

#= Running Functions

This includes the following functions:
* Fn to update all the agents in population' ; 
* Fns to run the simulation:
 * Initialize the population and the metagrah;
 * Initialize the dataframe;
 * Update population';
 * Then update mg;
 * Then update the dataframe.
 
The output is a dataframe with all the data I need to analyze the simulation afterwards. =#


function pop_update!(population,metagraph,n_issues,p, σ, ρ)
    for agent in population
        updateibelief!(agent,population,metagraph,n_issues,p)
        ρ_update!(agent, σ, n_issues, ρ)
    end
    return(population)
end



function create_initdf(agent_type, σ, n_issues, size_nw)
    pop = listofagents(agent_type, σ, n_issues, size_nw)
    g = creategraphfrompop(pop)
    add_neighbors!(pop,g)
    mg = MetaGraph(g)
    setmgproperties!(mg,pop)
    df = init_df(pop)
    return(df,mg,pop)
end

function runsim!(pop,df,mg,n_issues,p,σ,ρ,time)
    @showprogress 1 "Computing..." for step in 1:time
        pop_update!(pop, mg, n_issues, p, σ, ρ)
        setmgproperties!(mg,pop)
        update_df!(pop,df,step)
    end 
    return(df)
end



function one_run(pa::DyDeoParam)
    @unpack n_issues, size_nw, p, σ, time, ρ, agent_type = pa
    df,mg,pop = create_initdf(agent_type, σ, n_issues, size_nw)
    df = runsim!(pop,df,mg,n_issues,p,σ,ρ,time)
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




