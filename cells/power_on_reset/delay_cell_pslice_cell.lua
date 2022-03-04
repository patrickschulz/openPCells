function parameters()
    pcell.reference_cell("basic/mosfet")
end

function layout(cell, _P, env)
    pcell.push_overwrites("basic/mosfet", env.pmos)
    pcell.push_overwrites("basic/mosfet", {
        fingers = 4, 
        drawtopgate = true,
        connectsource = true,
        connectinverse = true,
        connsourcewidth = env.powerbarwidth,
        connsourcespace = env.powerbarspace,
        topgateextendhalfspace = true
    })
    local currentref = pcell.create_layout("basic/mosfet")
    currentref:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 60, env.gatewidth):translate(currentref:get_anchor("sourcedrainmiddle2")))
    currentref:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 60, env.gatewidth):translate(currentref:get_anchor("sourcedrainmiddle4")))
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainmiddle2"):translate(0, -77), 
        currentref:get_anchor("sourcedrainmiddle4"):translate(0, 77)
    ))
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainlower3"):translate(-100, -env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth - env.guardringsep / 2),
        currentref:get_anchor("sourcedrainupper3"):translate( 100,  env.powerbarspace + env.powerbarwidth + env.guardringspace + env.guardringwidth + env.guardringsep / 2)
    ))
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        currentref:get_anchor("sourcedrainupper1"):translate(0, env.powerbarspace),
        currentref:get_anchor("sourcedrainupper5"):translate(0, env.powerbarspace + env.powerbarwidth)
    ))

    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainmiddle2"):translate(0, -77), currentref:get_anchor("sourcedrainmiddle4"):translate(0, 77)))

    currentref:set_alignment_box(
        currentref:get_anchor("sourcestrapmiddleleft"),
        currentref:get_anchor("sourcedrainupper5"):translate(0, env.powerbarspace + env.powerbarwidth / 2)
    )
    local currentname = pcell.add_cell_reference(currentref, "delay_cell_pcurrent_cell")
    local current = cell:add_child(currentname)

    local dioderef = pcell.create_layout("basic/mosfet", { 
        connectdrain = true,
        conndrainwidth = 120,
        conndrainspace = 65,
    })
    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        dioderef:get_anchor("topgatestraplowermiddle"):translate(-100, 0), 
        dioderef:get_anchor("topgatestrapuppermiddle"):translate(100, 0)
    ))
    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        dioderef:get_anchor("sourcedrainupper1"):translate(0, env.powerbarspace),
        dioderef:get_anchor("sourcedrainupper5"):translate(0, env.powerbarspace + env.powerbarwidth)
    ))
    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        dioderef:get_anchor("sourcedrainlower3"):translate(-100, -env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth - env.guardringsep / 2),
        dioderef:get_anchor("sourcedrainupper3"):translate( 100,  env.powerbarspace + env.powerbarwidth + env.guardringspace + env.guardringwidth + env.guardringsep / 2)
    ))
    dioderef:set_alignment_box(
        dioderef:get_anchor("sourcestrapmiddleleft"),
        dioderef:get_anchor("sourcedrainupper5"):translate(0, env.powerbarspace + env.powerbarwidth / 2)
    )
    local diodename = pcell.add_cell_reference(dioderef, "delay_cell_pdiode_cell")
    local left = cell:add_child_array(diodename, env.factor / 2, 1):move_anchor("right", current:get_anchor("left"))
    local right = cell:add_child_array(diodename, env.factor / 2, 1):move_anchor("left", current:get_anchor("right"))

    local guardringref = pcell.create_layout("auxiliary/guardring", { 
        contype = "n", 
        ringwidth = env.guardringwidth, 
        width = (env.factor + 1) * env.fingers * (env.gatelength + env.gatespace) + 1000,
        height = env.ypitch + env.guardringwidth + 2 * env.guardringspace + env.powerbarwidth,
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

    pcell.pop_overwrites("basic/mosfet")
end
