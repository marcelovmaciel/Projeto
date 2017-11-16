function time_plot(which_df, n_issues, nagents, p, σ, ρ)

    
    xlab = string("Time")
    ylab = string("Ideal Point") 

    @df which_df plot(:time,[:ideal_point],
                      group = :id,
                      dpi = 120, color = :black,
                      xlabel = xlab, ylabel = ylab,
                      α = 0.3)
    savefig("n($(nagents))_nissues($(n_issues))_p($(p))_sigma($(σ))_rho($(ρ))_tseries.png")
end




