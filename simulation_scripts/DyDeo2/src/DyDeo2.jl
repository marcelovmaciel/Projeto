module DyDeo2
using NBInclude
using LightGraphs, MetaGraphs, Distributions, DataFrames
using Parameters, StatPlots, ProgressMeter
# package code goes here
nbinclude("basefns.ipynb")
nbinclude("runfns.ipynb")


export DyDeoParam,
       one_run,
       time_plot,
       mkimdir,
       inspectdr,
       @unpack
end # module
