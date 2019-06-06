# Helper functions
sameSense(pra::Int, ra::Int) = mod(pra,2)==mod(ra,2)
downSense(ra::Int) = (ra>0) .& (mod(ra,2)==1)
upSense(ra::Int) = (ra>0) .& (mod(ra,2)==0)

# Reward function for VerticalCAS MDP
function POMDPs.reward(mdp::VerticalCAS_MDP, s::stateType, ra::actType)
    h = s[1]; vown = s[2]; vint = s[3]; pra = s[4]
    tau = mdp.currentTau
    r = 0.0
    sep = abs(h)
    closure = abs(vint-vown)
    crossing = ((h<0) .& downSense(ra)) .| ((h>0) .& upSense(ra))
    deltaVown = 0.0
    corrective = false
    preventitive = false
    weakening = false
    strengthening = false
    reversal = false

    sepTau0 = abs(h + tau * (vint-vown))

    if ra>COC
        if pra>COC
            reversal = mod(pra,2)!=mod(ra,2)
        end
        if !reversal
            weakening = pra>ra
            strengthening = pra<ra
        end
        vLow, vHigh = mdp.velRanges[ra]
        corrective = (vown>vLow) .& (vown < vHigh)
        preventitive = !corrective
        if corrective
            if downSense(ra)
                deltaVown = abs(vLow-vown)
            else
                deltaVown = abs(vHigh-vown)
            end
        end
    end
    lolo = (ra==DNC) .| (ra==DND)

    if (sep<=175) .& (tau==0)
        r-=1.0*2.0 # collision penalty
    end
    
    if (sep<=100) .& (tau<10) .& (ra==COC)
        r-=0.1
    end

    if (sepTau0<=300) .& (ra==COC) .& (tau<15)
        r-= (15.0-tau)/15.0
    end


    if mdp.allowedTrans[pra][ra+1]==0
        r-=10.0
    end

    if crossing
        #if preventitive
        #    r-=1.0 *0.0 #Remove this penalty
        #end
        if sep>500
            r-=0.01
        end
    end
    if corrective
        r-=1e-5
        if (sep>650) .& (closure<2000.0/60.0)
            r-= 0.1
        end
        if (sep>1000) .& (closure<4000.0/60.0)
            r-=0.03
        end
    elseif preventitive
        if (sep>650) .& (closure<2000.0/60.0)
            r-=0.01
        end
    end
    if reversal
        r-= 8e-3 *4.0 # Reversal penalty
        
        #### NEW! Penalize reversals in NMAC region - with pilot delay, better to be consistent
        if sep<100
            r-=1.0
        end
    end
    if strengthening
        r-=5e-3
    end
    if weakening
        r-=1e-3
    end
    if lolo
        r-=1e-4
        if closure > 3000.0/60.0
            r-=5e-4
        end
    elseif (ra!=COC) .& (closure > 3000.0/60.0)
        r-=1.5e-3
    end
    if closure < 3000.0/60.0
        r-=2.3e-3
    end
    if ra==COC
        r+=1e-9
    else
        r-=3e-5*deltaVown
        if closure > 3000.0/60.0
            r-=1.5e-3
        end
    end
    return r
end