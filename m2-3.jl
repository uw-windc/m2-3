using JuMP, JSON, Ipopt


d = JSON.Parser.parsefile("m2_3_data.json")


function parse_data(key)
    x = Dict()

    if d[key]["type"] == "GamsSet"
        if d[key]["dimension"] == 1
            x = d[key]["elements"]
            return x
        end
    end

    # need to work on import multidimentional sets (i.e., mappings)

    if d[key]["type"] == "GamsParameter"
        if d[key]["dimension"] == 0
            x = d[key]["values"]
            return x
        end

        if d[key]["dimension"] == 1
            for i in 1:length(d[key]["values"]["domain"])
                a = d[key]["values"]["domain"][i]
                x[a] = d[key]["values"]["data"][i]
            end
            return x
        end

        if d[key]["dimension"] > 1
            for i in 1:length(d[key]["values"]["domain"])
                a = tuple(d[key]["values"]["domain"][i]...)
                x[a] = d[key]["values"]["data"][i]
            end
        return x
        end
    end
end

# data pull
M = parse_data("M")
P1 = parse_data("P1")
P2 = parse_data("P2")
S1 = parse_data("S1")
S2 = parse_data("S2")
# RATION = parse_data("RATION")



# model object
m = Model(with_optimizer(Ipopt.Optimizer, print_level = 0))

# add variables and initial point to model object
@variable(m, X1, start=50)
@variable(m, X2, start=50)
@variable(m, U, start=100)


# add constartins to model object
@NLparameter(m, RATION == 100)
@NLconstraint(m, utility, U == 2 * (X1^S1) * (X2^S2) )
@NLconstraint(m, income, M >= P1*X1 + P2*X2 )
@NLconstraint(m, ration1, RATION >= X1 )
@NLobjective(m, Max, U)


# SOLVE #1
optimize!(m)

# post processing / output solution check
print(termination_status(m))
print(primal_status(m))
print(dual_status(m))


report = Dict()

report["no_ration","X1"] = value(X1)
report["no_ration","X2"] = value(X2)
report["no_ration","U"] = value(U)


# SOLVE #2
set_value(RATION, 25)
optimize!(m)

report["ration_25","X1"] = value(X1)
report["ration_25","X2"] = value(X2)
report["ration_25","U"] = value(U)
