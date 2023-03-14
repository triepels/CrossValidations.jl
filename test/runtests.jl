using CrossValidation

import CrossValidation: fit!, loss

struct MyModel
    a::Float64
    b::Float64
end

MyModel(; a::Float64, b::Float64) = MyModel(a, b)

function fit!(model::MyModel, x::AbstractArray; epochs::Int = 1)
    #println("Fitting $model ..."); sleep(0.1)
    return model
end

# Himmelblau's function
function loss(model::MyModel, x::AbstractArray)
    a, b = model.a, model.b
    return (a^2 + b - 11)^2 + (a + b^2 - 7)^2
end

x = rand(2, 100)

validate(MyModel(2.0, 2.0), (epochs=100,), FixedSplit(x))
validate(MyModel(2.0, 2.0), (epochs=100,), RandomSplit(x))
validate(MyModel(2.0, 2.0), (epochs=100,), KFold(x))
validate(MyModel(2.0, 2.0), (epochs=100,), ForwardChaining(x, 40, 10))
validate(MyModel(2.0, 2.0), (epochs=100,), SlidingWindow(x, 40, 10))

space = ParameterSpace(a = -6.0:0.5:6.0, b = -6.0:0.5:6.0)

brute(MyModel, GridSampler(space), (epochs=100,), FixedSplit(x), maximize=false)
brute(MyModel, RandomSampler(space, n=100), (epochs=100,), FixedSplit(x), maximize=false)
hc(MyModel, space, (epochs=100,), FixedSplit(x), k=1, maximize=false)

sha(MyModel, GridSampler(space), ConstantBudget((epochs=100,)), FixedSplit(x), maximize=false)
sha(MyModel, RandomSampler(space, n=100), GeometricBudget((epochs=100,), 1.5), FixedSplit(x), maximize=false)

f(train) = train ./ 10
f(train, test) = train ./ 10, test ./ 10

validate(MyModel(2.0, 2.0), (epochs=100,), PreProcess(FixedSplit(x), f))
brute(MyModel, RandomSampler(space, n=100), (epochs=100,), PreProcess(KFold(x), f), maximize=false)

validate(KFold(x)) do train
    prms = brute(MyModel, GridSampler(space), (epochs=100,), FixedSplit(train), maximize=false)
    return fit!(MyModel(prms...), train)
end

validate(KFold(x)) do train
    prms = hc(MyModel, space, (epochs=100,), FixedSplit(train), maximize=false)
    return fit!(MyModel(prms...), train)
end

validate(KFold(x)) do train
    prms = sha(MyModel, GridSampler(space), ConstantBudget((epochs=100,)), FixedSplit(train), maximize=false)
    return fit!(MyModel(prms...), train)
end
