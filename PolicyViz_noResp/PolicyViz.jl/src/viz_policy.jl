#export viz_policy, get_belief

function get_belief(pstate::Vector{Float64}, grid::RectangleGrid,interp::Bool=false)
    belief = spzeros(nstates, 1)
    indices, weights = interpolants(grid, pstate)
    if !interp
        indices = indices[findmax(weights)[2]]
        weights = 1.0
    end
    for i = 1:length(indices)
        belief[indices[i]] = weights[i]
    end # for i
    return belief
end # function get_belief

function viz_policy(Q)
    grid = RectangleGrid(relhs,dh0s,dh1s,actions,taus)
    
    # Colors
    ra_1 = RGB(1.,1.,1.) # white
    ra_2 = RGB(.0,1.0,1.0) # cyan
    ra_3 = RGB(144.0/255.0,238.0/255.0,144.0/255.0) # lightgreen
    ra_4 = RGB(0.0,1.0,.0) # lime
    ra_5 = RGB(34.0/255.0,139.0/255.0,34.0/255.0) # forestgreen
    colors = [ra_1;ra_2;ra_3;ra_4;ra_5]
    bg_colors = [RGB(1.0,1.0,1.0)]
    
    # Create scatter plot classes for color key
    sc_string = "{"
    for i=1:5
        define_color("ra_$i",  colors[i])
        if i==1
            sc_string *= "ra_$i={mark=square, style={black, mark options={fill=ra_$i}, mark size=6}},"
        else
            sc_string *= "ra_$i={style={ra_$i, mark size=6}},"
        end
    end
    
    # Color key as a scatter plot
    sc_string=sc_string[1:end-1]*"}"
    xx = [-1.5, -1.5, -1.5, -1.5, -1.5]
    yy = [1.65, 1.15, 0.65, 0.15, -0.35]
    zz = ["ra_1","ra_2","ra_3","ra_4","ra_5"]
    sc = string(sc_string)

    # Set up interactive display
    @manipulate for nbin = 100,
        savePlot = [false,true],
        xmin = 0.0,
        xmax = 120.0,
        ymin = -600.0,
        ymax = 600.0,
        dh0 = 0.0, 
        dh1 = 0.0, 
        pra = action_names,
        on_cost = 0.0
        
        # Get previous RA index
        pra = find(pra.==action_names)[1]
        
        # Q Table Heat Map
        function get_heat1(x::Float64, y::Float64)
            #println("x: $x, y: $y")
            tau = x 
            relh = y
            bel = get_belief([relh,dh0,dh1,pra,tau],grid,false)
            qvals = Q[:,bel.rowval[1]]
            #println("action_ind: $(actions[findmax(qvals)[2]])")
            return actions[findmax(qvals)[2]]
        end # function get_heat1

        #Plot table or neural network policies if possible
        g = GroupPlot(2, 1, groupStyle = "horizontal sep=3cm")
        push!(g, Axis([
            Plots.Image(get_heat1, (xmin, xmax), (ymin, ymax), zmin = 1, zmax = 5,
            xbins = nbin, ybins = nbin, colormap = ColorMaps.RGBArrayMap(colors), colorbar=false),
            ], xmin=xmin, xmax=xmax, ymin=ymin,ymax=ymax, width="10cm", height="8cm", 
               xlabel="Tau (s)", ylabel="Relative Alt (ft)", title="Table Advisories"))
        # Save policy to a tex file to be used in papers
        if savePlot
            PGFPlots.save("PolicyPlot.tex", g, include_preamble=true)
        else
                            
            # Create Color Key
            f = (x,y)->x # Dummy function for background white image
            push!(g, Axis([
                Plots.Image(f, (-2,2), (-2,2),colormap = ColorMaps.RGBArrayMap(bg_colors),colorbar=false),
                Plots.Scatter(xx, yy, zz, scatterClasses=sc),
                Plots.Node("RA 1: COC ",0.15,0.915,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 2: DNC ",0.15,0.790,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 3: DND",0.15,0.665,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 4: CL250",0.15,0.540,style="black,anchor=west", axis="axis description cs"),
                Plots.Node("RA 5: SCL450 ",0.15,0.415,style="black,anchor=west", axis="axis description cs"),
                ],width="10cm",height="8cm", hideAxis =true, title="KEY"))
        end
    end
end 
           