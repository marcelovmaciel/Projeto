using PyCall
@pyimport SALib.sample.saltelli as saltelli
@pyimport SALib.analyze.sobol as sobol
@pyimport SALib.test_functions.Ishigami as Ishigami

problem = Dict("num_vars" => 3,
            "names" => ["x1", "x2", "x3"],
            "bounds" => [[-3.14159265359, 3.14159265359],
               [-3.14159265359, 3.14159265359],
               [-3.14159265359, 3.14159265359]]
            )
param_values = saltelli.sample(problem, 1000)


Y = Ishigami.evaluate(param_values)

# Perform analysis
Si = sobol.analyze(problem, Y, print_to_console=true)

println(Si["S1"])


keys(Si)

Si["S1"]
