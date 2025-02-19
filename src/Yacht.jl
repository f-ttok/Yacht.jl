module Yacht

using LinearAlgebra
using Combinatorics
using StaticArrays

const Hist = MVector{DICE_MAX_VALUE,UInt8}

@enum Category begin
    CAT_ACES
    CAT_DEUCES
    CAT_THREES
    CAT_FOURS
    CAT_FIVES
    CAT_SIXES
    CAT_CHOICE
    CAT_4_OF_A_KIND
    CAT_FULL_HOUSE
    CAT_S_STRAIGHT
    CAT_L_STRAIGHT
    CAT_YACHT
end

"""
ヒストグラムに対する得点を計算する
"""
function calc_score(h::Hist, c::Category)
    if c == CAT_ACES
        return h[1] * 1
    elseif c == CAT_DEUCES
        return h[2] * 2
    elseif c == CAT_THREES
        return h[3] * 3
    elseif c == CAT_FOURS
        return h[4] * 4
    elseif c == CAT_FIVES
        return h[5] * 5
    elseif c == CAT_SIXES
        return h[6] * 6
    elseif c == CAT_CHOICE
        return sum(h[i] * i for i = 1:6)
    elseif c == CAT_4_OF_A_KIND
        if 4 in h || 5 in h
            return sum(h[i] * i for i = 1:6)
        else
            return 0
        end
    elseif c == CAT_FULL_HOUSE
        if 2 in h && 3 in h
            return sum(h[i] * i for i = 1:6)
        else
            return 0
        end
    elseif c == CAT_S_STRAIGHT
        if (h[3] > 0 && h[4] > 0) &&
            ((h[1] > 0 && h[2] > 0) || (h[2] > 0 && h[5] > 0) || (h[5] > 0 && h[6] > 0))
            return 15
        else
            return 0
        end
    elseif c == CAT_L_STRAIGHT
        if (h[2] > 0 && h[3] > 0 && h[4] > 0 && h[5] > 0) && (h[1] > 0 || h[6] > 0)
            return 15
        else
            return 0
        end
    elseif c == CAT_YACHT
        if 5 in h
            return 50
        else
            return 0
        end
    else
        return 0
    end
end

const FINAL_HISTS::Vector{Hist} = [h for h in multiexponents(6, 5)]
const FINAL_SCORES::Matrix{Float64} = [
    calc_score(h, c) for h in FINAL_HISTS, c in instances(Category)
]
const NUM_FINAL_STATES = length(FINAL_HISTS)

const ALL_HISTS::Vector{Hist} = [h for n = 0:6 for h in multiexponents(6, n)]
const ALL_SCORES::Matrix{Float64} = [
    calc_score(h, c) for h in ALL_HISTS, c in instances(Category)
]
const NUM_ALL_HISTS = length(ALL_HISTS)

"""
あるヒストグラムから別ヒストグラムに遷移できる確率を計算する
"""
function calc_trans_prob(src::Hist, dst::Hist)::Float64
    # 遷移不可能（ある数についてsrcの方が個数が多い）ならば0を返す
    d = dst - src
    if any(d .< 0)
        return 0
    end
    numer = multinomial(d...) # 何パターンあるか
    denom = 6^sum(d) # ふるサイコロの個数
    return numer / denom
end

const TRANS_PROBS = [calc_trans_prob(src, dst) for src in ALL_HISTS, dst in FINAL_HISTS]
const POSSIBLE_TRANS = [all(src .>= dst) ? 1 : 0 for src in FINAL_HISTS, dst in ALL_HISTS]

end
