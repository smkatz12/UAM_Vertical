export COC,DNC,DND,CL250,SCL450,stateType,actType,acts,discount_f,hMin,hMax,hs,
       vMin,vMax,vowns,vints,interp,accels,velRanges,allowedTrans

# General constants
fpm2fps = 1/60

# ADVISORY INDICES
COC = 0
DNC = 1
DND = 2
CL250 = 3
SCL450 = 4

# State Type:
stateType = Tuple{Float64,Float64,Float64,Int}
actType = Int
acts = [0,1,2,3,4]

# Default parameters
discount_f = 1.0

### STATE CUTPOINTS ###
# H: Altitude (ft)
hMin = -600.0
hMax = 600.0
hs   = vcat(LinRange(-600,-400,5),LinRange(-360,-200,5),LinRange(-180,0,10),
            LinRange(20,200,10),LinRange(240,400,5),LinRange(450,600,4))

# Velocities
vMin = -500.0fpm2fps
vMax = 500.0fpm2fps
vels = collect(-500:25:500)*fpm2fps
vowns = vels
vints = vels 

# Create the local function approximator using the grid
interp = LocalGIFunctionApproximator(RectangleGrid(hs,vowns,vints,acts))  


### Dictionaries to define transitions ###
# Tuple of probabilities and corresponding acceleration in ft/s^2
probs = [0.5,0.3,0.2] #[0.5,0.25,0.25]
g = 32.2
accels = Dict(COC=>([0.34, 0.33, 0.33],[0.0, -0.05g, 0.05g]),
              DNC=>(probs,[-0.1g, -0.15g, -0.2g]),
              DND=>(probs,[0.1g, 0.15g, 0.2g]),
              CL250=>(probs,[0.1g, 0.15g, 0.2g]),
              SCL450=>(probs,[0.1g, 0.15g, 0.2g]),
              -1=>([0.34,0.33,0.33],[0, -0.05g, 0.05g])) # -1 => intruder accels

# Velocity range where aircraft is NON-compliant with advisory (ft/s)
velRanges = Dict(COC=>(-500.0fpm2fps, 500.0fpm2fps),
                DNC=>(0.0, 500.0fpm2fps),
                DND=>(-500.0fpm2fps, 0.0),
                CL250=>(-500.0fpm2fps, 250fpm2fps),
                SCL450=>(-500.0fpm2fps, 450fpm2fps))

# Allowed transitions between advisories
allowedTrans = Dict(COC=>[1,1,1,1,1,0,0,0,0],
                   DNC=>[1,1,1,1,1,0,0,0,0],
                   DND=>[1,1,1,1,1,0,0,0,0],
                   CL250=>[1,1,1,1,1,1,1,0,0],
                   SCL450=>[1,1,1,1,1,1,1,1,1])
