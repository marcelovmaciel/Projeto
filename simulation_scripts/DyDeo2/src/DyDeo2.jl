module DyDeo2
using LightGraphs, MetaGraphs, Distributions, DataFrames
using Parameters, StatPlots, ProgressMeter, JLD2

# package code goes here
include("basefns.jl")
include("runfns.jl")


export DyDeoParam,
       one_run,
       time_plot,
       mkimdir,
       inspectdr,
       @unpack
end # module


