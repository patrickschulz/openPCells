function parameters()
    pcell.reference_cell("basic/mosfet")
end
function layout(cell, _P, env)
    pcell.push_overwrites("basic/mosfet", env.nmos)
    pcell.push_overwrites("basic/mosfet", { 
        fingers = 4, 
        drawbotgate = true,
        connectinverse = true,
        connectsource = true,
        connsourcewidth = env.powerbarwidth,
        connsourcespace = env.powerbarspace,
        botgateextendhalfspace = true,
    })
    local currentref = pcell.create_layout("basic/mosfet", {
        connectdrain = true,
        conndraininline = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndrainwidth = 154,
    })
    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainupper3"):translate(-110, 185),
        currentref:get_anchor("sourcedrainupper3"):translate( 110, env.powerbarspace + env.powerbarwidth + env.guardringspace + env.guardringwidth + env.guardringsep / 2)
    ))

    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainlower3"):translate(-110, -env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth - env.guardringsep / 2),
        currentref:get_anchor("sourcedrainmiddle3"):translate(110, 0)
    ))

    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        currentref:get_anchor("sourcedrainupper1"):translate(0, env.powerbarspace),
        currentref:get_anchor("sourcedrainupper5"):translate(0, env.powerbarspace + env.powerbarwidth)
    ))

    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        currentref:get_anchor("sourcedrainupper1"):translate(0, 65),
        currentref:get_anchor("sourcedrainupper5"):translate(0, 185)
    ))

    currentref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        currentref:get_anchor("sourcedrainlower1"):translate(0, -env.powerbarspace),
        currentref:get_anchor("sourcedrainlower5"):translate(0, -env.powerbarspace - env.powerbarwidth)
    ))

    currentref:set_alignment_box(
        currentref:get_anchor("sourcedrainlower1"):translate(0, -500),
        currentref:get_anchor("topright")
    )
    local currentname = pcell.add_cell_reference(currentref, "delay_cell_ncurrent_cell")
    local current = cell:add_child(currentname)

    local dioderef = pcell.create_layout("basic/mosfet", {
        connectdrain = true,
        conndrainwidth = 120,
        conndrainspace = 65,
    })
    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        dioderef:get_anchor("botgatestraplowermiddle"):translate(-100, 0), 
        dioderef:get_anchor("botgatestrapuppermiddle"):translate(100, 0)
    ))

    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), point.create(-100, -435), point.create(100, 435)))

    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        dioderef:get_anchor("sourcedrainupper1"):translate(0, 65),
        dioderef:get_anchor("sourcedrainupper5"):translate(0, 185)
    ))

    dioderef:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        dioderef:get_anchor("sourcedrainlower1"):translate(0, -env.powerbarspace),
        dioderef:get_anchor("sourcedrainlower5"):translate(0, -env.powerbarspace - env.powerbarwidth)
    ))

    dioderef:set_alignment_box(
        dioderef:get_anchor("sourcedrainlower1"):translate(0, -500),
        dioderef:get_anchor("topright")
    )
    local diodename = pcell.add_cell_reference(dioderef, "delay_cell_ndiode_cell")
    local left = cell:add_child_array(diodename, 5, 1):move_anchor("topright", current:get_anchor("topleft"))
    local right = cell:add_child_array(diodename, 5, 1):move_anchor("topleft", current:get_anchor("topright"))

    local guardringref = pcell.create_layout("auxiliary/guardring", { 
        contype = "p", 
        ringwidth = env.guardringwidth, 
        width = (env.factor + 1) * env.fingers * (env.gatelength + env.gatespace) + 1000,
        height = env.ypitch + 200 + 2 * 200 + env.powerbarwidth,
        drawdeepwell = false, 
        fillwell = true,
    })
    local guardringname = pcell.add_cell_reference(guardringref, "guardring")
    local guardring = cell:add_child(guardringname)

    -- power grid vias
    env.place_power_vias("vss", cell,  env.gatewidth / 2 + env.powerbarspace + env.powerbarwidth / 2)
    env.place_power_vias("vss", cell, -env.gatewidth / 2 - env.powerbarspace - env.powerbarwidth / 2)
    env.place_power_vias("vss", cell,  env.gatewidth / 2 + env.powerbarspace + env.powerbarwidth + env.guardringspace + env.guardringwidth / 2)
    env.place_power_vias("vss", cell, -env.gatewidth / 2 - env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth / 2)

    cell:inherit_alignment_box(guardring)

    pcell.pop_overwrites("basic/mosfet")
end
