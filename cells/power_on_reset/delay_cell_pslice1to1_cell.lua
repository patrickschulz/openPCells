function parameters()
    pcell.reference_cell("basic/mosfet")
end

function layout(cell, _P, env)
    pcell.push_overwrites("basic/mosfet", env.pmos)
    local currentref = pcell.create_layout("basic/mosfet", { 
        fingers = 4, 
        drawtopgate = true,
        connectinverse = true,
        connectsource = true,
        connsourcewidth = 200,
        connsourcespace = 400,
        connectdrain = true,
        conndrainwidth = 120,
        conndrainspace = 65,
        topgateextendhalfspace = true
    })
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainlower3"):translate(-100, -env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth - env.guardringsep / 2),
        currentref:get_anchor("drainstrapouter"):translate( 100, 0)
    ))
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        currentref:get_anchor("topgatestraplowermiddle"):translate(-100, 0), 
        currentref:get_anchor("topgatestrapuppermiddle"):translate(100, 0)
    ))
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        currentref:get_anchor("sourcedrainupper1"):translate(0, 400),
        currentref:get_anchor("sourcedrainupper5"):translate(0, 600)
    ))

    currentref:set_alignment_box(
        currentref:get_anchor("sourcestrapmiddleleft"),
        currentref:get_anchor("sourcedrainupper5"):translate(0, 500)
    )
    local currentname = pcell.add_cell_reference(currentref, "delay_cell_pcurrent_cell")
    local current = cell:add_child(currentname)
    current:move_anchor("sourcedrainmiddle3")

    local baseref = pcell.create_layout("basic/mosfet", { 
        fingers = 4, 
        drawtopgate = true,
        connectinverse = true,
        connectsource = true,
        connsourcewidth = 200,
        connsourcespace = 400,
        drawdrainvia = true,
        conndrainmetal = 2,
        topgateextendhalfspace = true
    })
    baseref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        baseref:get_anchor("sourcedrainupper1"):translate(0, 400),
        baseref:get_anchor("sourcedrainupper5"):translate(0, 600)
    ))
    baseref:set_alignment_box(
        baseref:get_anchor("sourcestrapmiddleleft"),
        baseref:get_anchor("sourcedrainupper5"):translate(0, 500)
    )
    local basename = pcell.add_cell_reference(baseref, "delay_cell_base_pmos")
    local base = cell:add_child(basename):move_anchor("right", current:get_anchor("left"))

    local dummyref = pcell.create_layout("basic/mosfet", { 
        fingers = 2, 
        drawtopgate = true,
        connectinverse = true,
        connectsource = true,
        connsourcewidth = 200,
        connsourcespace = 400,
        topgateextendhalfspace = true
    })

    dummyref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        dummyref:get_anchor("sourcedrainupper1"):translate(0, 400),
        dummyref:get_anchor("sourcedrainupper3"):translate(0, 600)
    ))

    dummyref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        dummyref:get_anchor("sourcedrainlower2"):translate(-30, 0), 
        dummyref:get_anchor("sourcestrapinner"):translate(30, 0)
    ))

    dummyref:set_alignment_box(
        dummyref:get_anchor("sourcestrapmiddleleft"),
        dummyref:get_anchor("sourcedrainupper3"):translate(0, 500)
    )
    local dummyname = pcell.add_cell_reference(dummyref, "delay_cell_pdummy_cell")
    local left = cell:add_child_array(dummyname, 6, 1):move_anchor("right", base:get_anchor("left"))
    local right = cell:add_child_array(dummyname, 10, 1):move_anchor("left", current:get_anchor("right"))

    -- bleeder resistors
    local resref = pcell.create_layout("basic/mosfet", { 
        fingers = 4, 
        drawbotgate = true,
        drawdrainvia = true,
        conndrainmetal = 2,
    })
    resref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        resref:get_anchor("sourcedrainlower1"):translate(0, -400),
        resref:get_anchor("sourcedrainlower5"):translate(0, -600)
    ))
    resref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        resref:get_anchor("sourcedrainupper1"):translate(0, 400),
        resref:get_anchor("sourcedrainupper5"):translate(0, 600)
    ))
    resref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        resref:get_anchor("sourcedrainupper1"):translate(-30, 0),
        resref:get_anchor("sourcedrainupper1"):translate(30, 400)
    ))
    resref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        resref:get_anchor("sourcedrainupper3"):translate(-30, 0),
        resref:get_anchor("sourcedrainupper3"):translate(30, 400)
    ))
    resref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        resref:get_anchor("botgatestraplowermiddle"):translate(-30, 0),
        resref:get_anchor("botgatestraplowermiddle"):translate(30, -400)
    ))
    resref:set_alignment_box(
        resref:get_anchor("sourcedrainlower1"):translate(0, -500),
        resref:get_anchor("sourcedrainupper5"):translate(0, 500)
    )
    local resname = pcell.add_cell_reference(resref, "delay_cell_res")
    local res = cell:add_child(resname):move_anchor("right", left:get_anchor("left"))

    cell:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        res:get_anchor("sourcedrainmiddle2"):translate(-1000, -100),
        base:get_anchor("sourcedrainmiddle4"):translate(0, 100)
    ))

    local guardringref = pcell.create_layout("auxiliary/guardring", { 
        contype = "n", 
        ringwidth = 200, 
        width = (env.factor + 1) * env.fingers * (env.gatelength + env.gatespace) + 1000,
        height = env.ypitch + 200 + 2 * 200 + env.powerbarwidth,
        drawdeepwell = false, 
        fillwell = true,
    })
    local guardringname = pcell.add_cell_reference(guardringref, "guardring")
    local guardring = cell:add_child(guardringname)

    -- power grid vias
    env.place_power_vias("vss", cell,  env.gatewidth / 2 + env.powerbarspace + env.powerbarwidth / 2)
    env.place_power_vias("vdd", cell, -env.gatewidth / 2 - env.powerbarspace - env.powerbarwidth / 2)
    env.place_power_vias("vdd", cell,  env.gatewidth / 2 + env.powerbarspace + env.powerbarwidth + env.guardringspace + env.guardringwidth / 2)
    env.place_power_vias("vdd", cell, -env.gatewidth / 2 - env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth / 2)

    cell:inherit_alignment_box(guardring)

    cell:add_anchor("out", res:get_anchor("sourcedrainmiddle2"):translate(-1000, 0))

    pcell.pop_overwrites("basic/mosfet")
end
