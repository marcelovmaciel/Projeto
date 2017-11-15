using MyODModel, StatPlots, PyCall, DataFrames
import Seaborn

@pyimport pandas as pd
inspectdr(legend = false)


run_simulation_v1()

result = run_simulation_v1(n_issues = 1,   
                           size_nw = 500, p =  0.99,
                           σ =  0.1, time =  10^5,  ρ = 0.00001)


# for plotting options look the nb

@df result plot(:time,[:ideal_point], group = :id)
savefig("agentTime.png")





