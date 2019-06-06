module VerticalCAS
using POMDPs, StaticArrays, GridInterpolations, LocalFunctionApproximation, SparseArrays, POMDPModelTools

include("constants.jl")
include("vertical_cas.jl")
include("transitions.jl")
include("rewards.jl")
end