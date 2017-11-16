# Running Commands ----------------------------------------
function run_simulation_v1(; n_issues::Integer = 1,
                           size_nw::Integer = 2, p::Real = 0.5,
                           σ::Real = 0.5, time::Real = 2, ρ::Real = 0.01)
    nw = create_nw(σ, n_issues, size_nw)
    df = init_df(nw)
    for step in 1:time
        i,j = ij_comparison(nw)
        which_issue,i_belief,j_belief = pick_issuebelief(i, j, n_issues)
        pos_o = calc_posterior_o(i_belief, j_belief, p)
        update_step1!(i, which_issue, pos_o)
        ρ_update!.(nw, σ, n_issues, ρ)
        update_df!(nw,df,step)
    end
    return(df)
end

function run_simulation_v2(; n_issues::Integer = 1,
                           size_nw::Integer = 2, p::Real = 0.5,
                           σ::Real = 0.5, time::Real = 2, ρ::Real = 0.01)

    nw = create_nw(σ, n_issues, size_nw)
    df = init_df(nw)
    for step in 1:time
        i,j = ij_comparison(nw)
        which_issue, i_belief, j_belief = pick_issuebelief(i, j, n_issues)
        pos_o = calc_posterior_o(i_belief, j_belief, p)
        pos_σ = calc_pos_uncertainty(i_belief, j_belief, p)
        update_step2!(i, which_issue, pos_o, pos_σ)
        ρ_update!.(nw, σ, n_issues, ρ)
        update_df!(nw,df,step)
    end
    return(df)
end




function mkvardir(which_var::String)
    var_name = Dict{String, String}( "ρ"  => "ρ", "σ" => "σ", "prob_correct" => "prob_correct")
    !(string(var) in readdir(pwd())) ? mkdir(string(var)) : println(" dir ()  exists...nothing to do")
end


function sweep_run(n_issues, pops, ps, σs, ρs, time)
    for pop in pops
        for issues in n_issues
            for probs in ps
                for sigmas in σs
                    for rhos in ρs
                        result = run_simulation_v1(n_issues = issues,
                                                   size_nw = pop,
                                                   p = probs,
                                                   σ = sigmas,
                                                   time = time,
                                                   ρ = rhos)
                        time_plot(result, issues, pop, probs, sigmas, rhos )
                    end
                end
            end
        end
    end
end



#What it is that i want to do :
"have a dir of images with the following structure images/ population=K/ "
