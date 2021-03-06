# Helper functions

# Note: this function is sort of wrong for COC
# (but I do not plan to use it for COC)
function sameSense(pra::Int, ra::Int)
    ss = true
    if pra == DNC
        ss = ra == DNC ? true : false
    elseif ra == DNC
        ss = pra == DNC ? true : false
    end
    return ss
end

downSense(ra::Int) = ra == DNC
upSense(ra::Int) = (ra > COC) .& (ra != DNC)


# Reward function for VerticalCAS MDP
function POMDPs.reward(mdp::VerticalCAS_MDP, s::stateType, ra::actType)
    h, vown, vint, pra = s[1], s[2], s[3], s[4]
    tau = mdp.currentTau
    r = 0
    sep = abs(h)
    sepTau0 = abs(h + tau * (vint-vown))

    # Penalize nmac
    # if (sep <= 100) && (tau == 0)
    #     r -= 1.0
    # end

    # Penalize nmac
    if (sep <= 100) && (tau < 2)
        r -= 1.0
    end

    # Penalize closeness
    #if (sepTau0<=150) .& (ra==COC) .& (tau<15) # SMK changed 300 to 200
    if (sepTau0<=150) .& (tau<15) # SMK changed 300 to 200
        r-= (15.0-tau)/15.0
    end

    # Penalize alert and reward COC
    if ra != COC
        r -= alert_pens[ra+1]*mdp.factor # 0.01 # Changed from 0.01 12:36pm 8/16
    else
        r += 1e-4
    end

    # Penalize reversals and strengthings
    reversal = !sameSense(pra, ra) && (pra != COC) && (ra != COC)
    strengthening = !reversal ? (pra < ra) : false
    weakening = !reversal ? (pra > ra) : false

    if ra != COC
        strengthening ? r -= 0.009*mdp.factor : nothing # Get rid of these and set factor to 1.0 for good plot
        weakening ? r -= 0.009*mdp.factor : nothing # Get rid of these and set factor to 1.0 for good plot
        #reversal ? r -= 0.01 : nothing
    end

    # NEW: penalize crossing
    # crossing = (h > 0) .& upSense(ra) # || (h < 0 && downSense(ra))
    # if crossing && (tau < 7) && reversal
    #     r -= 1.5
    # end

    # NEW: try penalizing no alert when close
    # if (ra == COC) && (tau < 15) && (sep <= 150)
    #     r -= 0.5
    # end 

    # NEW: penalize going back to COC
    # if pra != COC && ra == COC
    #     r -= 0.5
    # end

    if mdp.allowedTrans[pra][ra+1]==0
        r-=10.0
    end    

    return r
end



# # Reward function for VerticalCAS MDP
# function POMDPs.reward(mdp::VerticalCAS_MDP, s::stateType, ra::actType)
#     h, vown, vint, pra = s[1], s[2], s[3], s[4]
#     tau = mdp.currentTau
#     r = 0
#     sep = abs(h)

#     # Penalize nmac
#     if (sep <= 175) && (tau == 0)
#         r -= 1.0
#     end

#     if ra == DNC || ra == DND
#         r -= 1e-1
#     elseif ra == CL250
#         r -= 2e-1
#     elseif ra == SCL450
#         r -= 2.5e-1
#     end

#     if mdp.allowedTrans[pra][ra+1]==0
#         r-=10.0
#     end    

#     return r
# end


# # Reward function for VerticalCAS MDP
# function POMDPs.reward(mdp::VerticalCAS_MDP, s::stateType, ra::actType)
#     ##########################################################
#     # Just calculating stuff
#     #########################################################
#     h = s[1]; vown = s[2]; vint = s[3]; pra = s[4]
#     tau = mdp.currentTau
#     r = 0.0
#     sep = abs(h)
#     closure = abs(vint-vown)
#     crossing = ((h<0) .& downSense(ra)) .| ((h>0) .& upSense(ra))
#     deltaVown = 0.0
#     corrective = false
#     preventitive = false
#     weakening = false
#     strengthening = false
#     reversal = false

#     sepTau0 = abs(h + tau * (vint-vown))

#     if ra>COC
#         if pra>COC
#             reversal = !sameSense(pra, ra)
#         end
#         if !reversal
#             weakening = pra>ra
#             strengthening = pra<ra
#         end
#         vLow, vHigh = mdp.velRanges[ra]
#         corrective = (vown>vLow) .& (vown < vHigh) # Not already following
#         preventitive = !corrective # Already following
#         if corrective
#             if downSense(ra)
#                 deltaVown = abs(vLow-vown)
#             else
#                 deltaVown = abs(vHigh-vown)
#             end
#         end
#     end
#     lolo = (ra==DNC) .| (ra==DND) # Level-off, Level-off

#     ##########################################################
#     # Actual rewards
#     #########################################################

#     if (sep<=125) .& (tau==0)
#         r-=1.0*2.0 # collision penalty
#     end
    
#     if (sep<=100) .& (tau<10) .& (ra==COC)
#         r-=0.1
#     end

#     # if (sepTau0<=150) .& (ra==COC) .& (tau<15) # SMK changed 300 to 200
#     #     r-= (15.0-tau)/15.0
#     # end


#     if mdp.allowedTrans[pra][ra+1]==0
#         r-=10.0
#     end

#     # if crossing
#     #     #if preventitive
#     #     #    r-=1.0 *0.0 #Remove this penalty
#     #     #end
#     #     if sep>500
#     #         r-=0.01
#     #     end
#     # end
#     # if corrective """ These numbers still might be too big """
#     #     r-=1e-5
#     #     if (sep>450) .& (closure<1000.0/60.0) # SMK decreased numbers (were 650 and 2000)
#     #         r-= 0.1
#     #     end
#     #     if (sep>600) .& (closure<2000.0/60.0) # were 1000 abd 4000
#     #         r-=0.03
#     #     end
#     # elseif preventitive
#     #     if (sep>450) .& (closure<1000.0/60.0) # were 650 and 2000
#     #         r-=0.01
#     #     end
#     # end
#     # if reversal
#     #     r-= 8e-3 *4.0 # Reversal penalty
        
#     #     #### NEW! Penalize reversals in NMAC region - with pilot delay, better to be consistent
#     #     if sep<100
#     #         r-=1.0
#     #     end
#     # end
#     # if strengthening
#     #     r-=5e-3
#     # end
#     # if weakening
#     #     r-=1e-3
#     # end
#     # if lolo
#     #     r-=1e-4
#     #     if closure > 800.0/60.0 # was 3000
#     #         r-=5e-4
#     #     end
#     # elseif (ra!=COC) .& (closure > 800.0/60.0) # was 3000
#     #     r-=1.5e-3
#     # end
#     # if closure < 800.0/60.0 # was 3000
#     #     r-=2.3e-3
#     # end
#     if ra==COC
#         r+=1e-9
#     else
#         r-=3e-5*deltaVown
#         # if closure > 800.0/60.0 # was 3000
#         #     r-=1.5e-3
#         # end
#     end
#     return r
# end
