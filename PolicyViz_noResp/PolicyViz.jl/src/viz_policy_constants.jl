#export relhs,dh0s,dh1s,taus,pas,nstates,actions, action_names

# General constants
fpm2fps = 1/60

# State dimension cutpoints
vels = collect(-500:25:500)*fpm2fps
relhs = vcat(linspace(-600,-400,5),linspace(-360,-200,5),linspace(-180,0,10),
              linspace(20,200,10),linspace(240,400,5),linspace(450,600,4))
dh0s = vels
dh1s = vels
taus  = linspace(0,100,101)
pas = [1,2,3,4,5]

# Number of states
nstates = length(relhs)*length(dh0s)*length(taus)*length(dh1s)*length(taus)

# Actions
actions = [1, 2, 3, 4, 5]
action_names = ["COC","DNC","DND","CL250","SCL450"]

# General constants
# fpm2fps = 1/60

# # State dimension cutpoints
# vels = collect(-500:25:500)*fpm2fps
# relhs = vcat(LinRange(-600,-400,5),LinRange(-360,-200,5),LinRange(-180,0,10),
#               LinRange(20,200,10),LinRange(240,400,5),LinRange(450,600,4))
# dh0s = vels
# dh1s = vels
# taus  = LinRange(0,40,41)
# pas = [1,2,3,4,5]

# # Number of states
# nstates = length(relhs)*length(dh0s)*length(taus)*length(dh1s)*length(taus)

# # Actions
# actions = [1, 2, 3, 4, 5]
# action_names = ["COC","DNC","DND","CL250","SCL450"]