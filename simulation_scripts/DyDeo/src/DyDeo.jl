module DyDeo

# imports --------------------------------------------------

using Distributions, DataFrames, StatPlots, LaTeXStrings


#types --------------------------------------------------

include("types/agenttypes.jl")


#functions --------------------------------------------------

include("functions/basefns.jl")
include("functions/runfns.jl")
include("functions/plotoutput.jl")

#methods --------------------------------------------------




#exports --------------------------------------------------

export run_simulation_v1,
    run_simulation_v2,
    time_plot,
    pyplot,
    inspectdr



end # module
