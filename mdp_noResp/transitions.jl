# State transition function
function POMDPs.transition(mdp::VerticalCAS_MDP, s::stateType, ra::actType)
    h = s[1]; vown = s[2]; vint = s[3]; pra = s[4];
    
    # Computation is faster when using vector of static size
    nextStates = MVector{9, stateType}(undef)
    nextProbs = @MVector(zeros(18))
    next_pra = ra
    ind=1

    # Determine if we are compliant with current ra
    vLow, vHigh = mdp.velRanges[pra]
    compliant = (vLow >= vown) .| (vHigh <= vown)

    # Compute probabilities of next states using sigma point sampling
    ownProbs, ownAccels = compliant ? mdp.accels_compliant[pra] : mdp.accels[pra]
    #ownProbs, ownAccels = mdp.accels[ra]
    intProbs, intAccels = mdp.accels[-1]
    for i = 1:length(ownAccels)
        for j = 1:length(intAccels)
            #next_h,next_vown,next_vint = dynamics(h,vown,vint,ownAccels[i],intAccels[j],pra,mdp)
            next_h,next_vown,next_vint = dynamics(h,vown,vint,ownAccels[i],intAccels[j],pra,compliant,mdp)
            nextStates[ind] = (next_h,next_vown,next_vint,next_pra)
            nextProbs[ind]  = ownProbs[i]*intProbs[j]
            ind+=1
        end
    end

    return SparseCat(nextStates,nextProbs)
end

# Dynamic equations
function dynamics(h::Float64,vown::Float64,vint::Float64,ownAccel::Float64, intAccel::Float64, ra::Int, compliant::Bool, mdp::VerticalCAS_MDP)
    vLow, vHigh = mdp.velRanges[ra]
    if !compliant
        if vLow > vown + ownAccel # 
            ownAccel = vLow-vown
        elseif vHigh < vown + ownAccel
            ownAccel = vHigh-vown
        end
    else
        # If above noncompliant range
        if vown > vHigh
            # Just don't exceed max velocity and dont go into range below
            if vMax < vown + ownAccel
                ownAccel = vMax - vown
            elseif vHigh > vown + ownAccel
                ownAccel = vHigh - vown
            end
        elseif vown < vLow
            # Just don't exceed min velocity and dont go into range above
            if vMin > vown + ownAccel
                ownAccel = vMin - vown
            elseif vLow < vown + ownAccel
                #println("vLow: $vLow; vown: $vown; ownAccel: $ownAccel; ra:$ra")
                ownAccel = vLow - vown
            end
        end
    end

    vLow, vHigh = mdp.velRanges[COC]
    if (vLow >= vint) .| (vHigh <= vint)
        intAccel = 0
    elseif vLow > vint + intAccel
        intAccel = vLow-vint
    elseif vHigh < vint + intAccel
        intAccel = vHigh-vint
    end

    next_h = h-vown-0.5*ownAccel+vint+0.5*intAccel
    next_vown = vown+ownAccel
    next_vint = vint+intAccel
    return next_h,next_vown,next_vint
end

# # State transition function
# function POMDPs.transition(mdp::VerticalCAS_MDP, s::stateType, ra::actType)
#     h = s[1]; vown = s[2]; vint = s[3]; pra = s[4];
    
#     # Computation is faster when using vector of static size
#     nextStates = MVector{9, stateType}(undef)
#     nextProbs = @MVector(zeros(18))
#     next_pra = ra
#     ind=1

#     # Compute probabilities of next states using sigma point sampling
#     ownProbs, ownAccels = mdp.accels[pra]
#     #ownProbs, ownAccels = mdp.accels[ra]
#     intProbs, intAccels = mdp.accels[-1]
#     for i = 1:3
#         for j = 1:3
#             #next_h,next_vown,next_vint = dynamics(h,vown,vint,ownAccels[i],intAccels[j],pra,mdp)
#             next_h,next_vown,next_vint = dynamics(h,vown,vint,ownAccels[i],intAccels[j],pra,mdp)
#             nextStates[ind] = (next_h,next_vown,next_vint,next_pra)
#             nextProbs[ind]  = ownProbs[i]*intProbs[j]
#             ind+=1
#         end
#     end

#     return SparseCat(nextStates,nextProbs)
# end

# # Dynamic equations
# function dynamics(h::Float64,vown::Float64,vint::Float64,ownAccel::Float64, intAccel::Float64, ra::Int, mdp::VerticalCAS_MDP)
#     vLow, vHigh = mdp.velRanges[ra]
#     if (vLow >= vown) .| (vHigh <= vown) # Compliant velocity
#         if ((ra != DNC) && (ra != DND)) || abs(ownAccel) > 0.1g
#             ownAccel = 0
#         end
#     elseif vLow > vown + ownAccel # 
#         ownAccel = vLow-vown
#     elseif vHigh < vown + ownAccel
#         ownAccel = vHigh-vown
#     end

#     vLow, vHigh = mdp.velRanges[COC]
#     if (vLow >= vint) .| (vHigh <= vint)
#         intAccel = 0
#     elseif vLow > vint + intAccel
#         intAccel = vLow-vint
#     elseif vHigh < vint + intAccel
#         intAccel = vHigh-vint
#     end

#     next_h = h-vown-0.5*ownAccel+vint+0.5*intAccel
#     next_vown = vown+ownAccel
#     next_vint = vint+intAccel
#     return next_h,next_vown,next_vint
# end