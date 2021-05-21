using CrossValidation
import CrossValidation: predict, score

struct MyModel
    a::Int
    b::Int
end

function mymodel(x::AbstractArray, a::Int, b::Int)
    return MyModel(a, b)
end

function predict(model::MyModel, x::AbstractArray)
    return rand(size(x)...)
end

function score(model::MyModel, x::AbstractArray)
    return sum(predict(model, x) - x)
end

x = rand(2, 10)

search = ExhaustiveSearch(a=1:2, b=3:4)

method = Holdout(x, ratio=0.8)

cv = crossvalidate(mymodel, method, search)

cv = crossvalidate((x) -> mymodel(x, 1, 2), method)

cv = crossvalidate((x) -> crossvalidate(mymodel, Holdout(x), search), Holdout(x))