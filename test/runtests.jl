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

collect(FixedSplit(1:10))
collect(RandomSplit(1:10))
collect(LeaveOneOut(1:10))
collect(KFold(1:10))
collect(ForwardChaining(1:10, 4, 2))
collect(SlidingWindow(1:10, 4, 2))

x = rand(2, 100)

validate(MyModel(2.0, 2.0), FixedSplit(x), epochs = 100)

sp = space(a = DiscreteUniform(-8.0:1.0:8.0), b = DiscreteUniform(-8.0:1.0:8.0))

brute(MyModel, sp, FixedSplit(x), args = (epochs = 100,), maximize = false)
brute(MyModel, sample(sp, 64), FixedSplit(x), args = (epochs = 100,), maximize = false)
hc(MyModel, sp, FixedSplit(x), args = (epochs = 100,), nstart = 10, k = 1, maximize = false)

sha(MyModel, sp, FixedSplit(x), Budget(epochs = 448), mode = GeometricSchedule, rate = 2, maximize = false)
sha(MyModel, sample(sp, 64), FixedSplit(x), Budget(epochs = 600), mode = ConstantSchedule, rate = 2, maximize = false)

hyperband(MyModel, sp, FixedSplit(x), Budget(epochs = 81), rate = 3, maximize = false)

sasha(MyModel, sp, FixedSplit(x), args = (epochs = 1,), temp = 1, maximize = false)

validate(KFold(x)) do train
    prms = brute(MyModel, sp, FixedSplit(train), args = (epochs = 100,), maximize = false)
    return fit!(MyModel(prms...), train, epochs = 10)
end

validate(KFold(x)) do train
    prms = hc(MyModel, sp, FixedSplit(train), args = (epochs = 100,), nstart = 10, k = 1, maximize = false)
    return fit!(MyModel(prms...), train, epochs = 10)
end

validate(KFold(x)) do train
    prms = sha(MyModel, sp, FixedSplit(train), Budget(epochs = 100), mode = GeometricSchedule, rate = 2, maximize = false)
    return fit!(MyModel(prms...), train, epochs = 10)
end

validate(KFold(x)) do train
    prms = sasha(MyModel, sp, FixedSplit(train), args = (epochs = 1,), temp = 1, maximize = false)
    return fit!(MyModel(prms...), train, epochs = 10)
end
