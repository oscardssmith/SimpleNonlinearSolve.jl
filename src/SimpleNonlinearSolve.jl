module SimpleNonlinearSolve

using Reexport
using FiniteDiff, ForwardDiff
using ForwardDiff: Dual
using StaticArraysCore
using LinearAlgebra
import ArrayInterface
using DiffEqBase

@reexport using SciMLBase

using PackageExtensionCompat
function __init__()
    @require_extensions
end

const NNlibExtLoaded = Ref{Bool}(false)

abstract type AbstractSimpleNonlinearSolveAlgorithm <: SciMLBase.AbstractNonlinearAlgorithm end
abstract type AbstractBracketingAlgorithm <: AbstractSimpleNonlinearSolveAlgorithm end
abstract type AbstractNewtonAlgorithm{CS, AD, FDT} <: AbstractSimpleNonlinearSolveAlgorithm end
abstract type AbstractImmutableNonlinearSolver <: AbstractSimpleNonlinearSolveAlgorithm end
abstract type AbstractBatchedNonlinearSolveAlgorithm <:
              AbstractSimpleNonlinearSolveAlgorithm end

include("utils.jl")
include("bisection.jl")
include("falsi.jl")
include("raphson.jl")
include("broyden.jl")
include("lbroyden.jl")
include("klement.jl")
include("trustRegion.jl")
include("ridder.jl")
include("brent.jl")
include("dfsane.jl")
include("ad.jl")
include("halley.jl")
include("alefeld.jl")
include("itp.jl")

# Batched Solver Support
include("batched/utils.jl")
include("batched/raphson.jl")
include("batched/dfsane.jl")
include("batched/broyden.jl")

import PrecompileTools

PrecompileTools.@compile_workload begin
    for T in (Float32, Float64)
        prob_no_brack = NonlinearProblem{false}((u, p) -> u .* u .- p, T(0.1), T(2))
        for alg in (SimpleNewtonRaphson, Halley, Broyden, Klement, SimpleTrustRegion,
            SimpleDFSane)
            solve(prob_no_brack, alg(), abstol = T(1e-2))
        end

        #=
        for alg in (SimpleNewtonRaphson,)
            for u0 in ([1., 1.], StaticArraysCore.SA[1.0, 1.0])
                u0 = T.(.1)
                probN = NonlinearProblem{false}((u,p) -> u .* u .- p, u0, T(2))
                solve(probN, alg(), tol = T(1e-2))
            end
        end
        =#

        prob_brack = IntervalNonlinearProblem{false}((u, p) -> u * u - p,
            T.((0.0, 2.0)),
            T(2))
        for alg in (Bisection, Falsi, Ridder, Brent, Alefeld, Itp)
            solve(prob_brack, alg(), abstol = T(1e-2))
        end
    end
end

# DiffEq styled algorithms
export Bisection, Brent, Broyden, LBroyden, SimpleDFSane, Falsi, Halley, Klement,
    Ridder, SimpleNewtonRaphson, SimpleTrustRegion, Alefeld, Itp
export BatchedBroyden, BatchedSimpleNewtonRaphson, BatchedSimpleDFSane

end # module
