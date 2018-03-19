include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")
import DyDeo2
const dd = DyDeo2

#import Seaborn

#@pyimport pandas as pd
para = dd.DyDeoParam(n_issues = 1,
                     size_nw = 500,
                     time = 1_000_000,
                     ρ = 0.0,
                     σ = 0.5,
                     p = 0.7
                     )


simpop = dd.simplerun_returnpop(para)

simideals = dd.pullidealpoints(simpop)

#result = run_simulation_v1(n_issues = nissues,
 #                          size_nw = population, p =  prob_correct,
  #                         σ =  σ, time =  time,  ρ = ρ)
#time_plot(result, nissues, population,
 #         prob_correct, σ, ρ )
