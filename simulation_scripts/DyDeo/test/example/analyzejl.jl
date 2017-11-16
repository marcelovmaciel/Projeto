using DyDeo
#import Seaborn
inspectdr(legend = false)
#@pyimport pandas as pd


const time = 10^5
const population = [500]
const nissues = [ 5]
const prob_correct = [0.99]
const σs = [0.7 ]
const ρs = [0.001]


run_simulation_v1()

result = run_simulation_v1(n_issues = nissues,   
                           size_nw = population, p =  prob_correct,
                           σ =  σ, time =  time,  ρ = ρ)


time_plot(result, nissues, population,
          prob_correct, σ, ρ )












