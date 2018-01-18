include("../simulation_scripts/DyDeo2/src/DyDeo2.jl")

using DyDeo2
const dd = DyDeo2

inspectdr(legend = false)
dd.mkdirs("image")
dd.mkdirs("data")


#=
topology = Complete Graph
agent_type = "mutating o"  or "mutating o and σ"
size_nw = [ 500 5000]
n_issues = [1 5 10 ]
p = [ 0.1 0.3 0.7 0.9]
σ = [ 0.02 0.05 0.1 0.3]
ρs to run ρs=  [ 0.1  0.01 0.001 0.0001 0.0]
=#


para = DyDeoParam()
df = one_run(para);

# Mutating o, time = 5000, nagent = 500 -------------------------------------------------
## Nissues = 10
#=
* p = [ 0.1 0.3 0.7 0.9]
* σ = [ 0.02 0.05 0.1 0.3]
* ρ =  [0.1  0.01 0.001 0.0001 0.0]
=#

param = DyDeoParam(agent_type = "mutating o",
                   time = 20000, size_nw = 500,
                   n_issues = 1, p = 0.9, σ = 0.5, ρ = 0.0)

df = one_run(param);
    
time_plot(df, param.n_issues, 
          param.size_nw, param.p,
          param.σ, param.ρ, param.agent_type)
println(" \n done")



function multi_run()
    for ρ in [0.0001, 0.001]
        param = DyDeoParam(agent_type = "mutating o",
                   time = 20000, size_nw = 500,
                           n_issues = 1, p = 0.9, σ = 0.5, ρ = ρ)
        df = one_run(param);
    
        time_plot(df, param.n_issues, 
                  param.size_nw, param.p,
                  param.σ, param.ρ, param.agent_type)
        println(" \n done")
    end
end

multi_run()
