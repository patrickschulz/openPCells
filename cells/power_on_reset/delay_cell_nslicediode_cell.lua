function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "numstack", 2 }
    )
end

function layout(cell, _P, env)
    pcell.push_overwrites("basic/mosfet", env.nmos)
    pcell.push_overwrites("basic/mosfet", {
        fingers = 4, 
        drawbotgate = true,
        connectsource = true,
        connectinverse = true,
        connsourcewidth = 120,
        connsourcespace = 65,
        connectdrain = true,
        conndrainwidth = 120,
        conndrainspace = 65,
        botgateextendhalfspace = true,
    })

    local leftrightref = object.create("leftrightref")
    local mosfetref = pcell.create_layout("basic/mosfet")
    local mosfetname = pcell.add_cell_reference(mosfetref, "nmos_upper")

    local instances = { leftrightref:add_child(mosfetname) }
    for i = 2, _P.numstack do
        instances[i] = leftrightref:add_child(mosfetname):translate(0, -1500 * (i - 1))
    end

    -- power bars
    leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        instances[1]:get_anchor("sourcedrainupper1"):translate(0, 400),
        instances[1]:get_anchor("sourcedrainupper5"):translate(0, 600)
    ))
    for i = 1, _P.numstack do
        leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            instances[i]:get_anchor("sourcedrainlower1"):translate(0, -400),
            instances[i]:get_anchor("sourcedrainlower5"):translate(0, -600)
        ))
    end

    -- connection to VSS
    leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        instances[1]:get_anchor("sourcedrainupper3"):translate(-100, 400),
        instances[1]:get_anchor("sourcestrapouter"):translate(100, 0)
    ))

    -- connection to next diode
    for i = 2, _P.numstack do
        leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
            instances[i - 1]:get_anchor("botgatestraplowermiddle"):translate(-100, 0),
            instances[i]:get_anchor("sourcestrapinner"):translate(100, 0)
        ))
        leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            instances[i - 1]:get_anchor("botgatestraplowermiddle"):translate(-100, 0),
            instances[i - 1]:get_anchor("botgatestrapuppermiddle"):translate(100, 0)
        ))
        leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
            instances[i]:get_anchor("sourcestrapinner"):translate(-100, 0),
            instances[i]:get_anchor("sourcestrapouter"):translate(100, 0)
        ))
    end

    leftrightref:set_alignment_box(
        instances[_P.numstack]:get_anchor("sourcedrainlower1"):translate(0, -500),
        instances[1]:get_anchor("sourcedrainupper5"):translate(0, 500)
    )

    local middleref = leftrightref:copy()

    -- add M2 line AFTER middleref was created
    leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        instances[_P.numstack]:get_anchor("sourcedrainlower3"):translate(-100, -env.powerbarspace - env.powerbarwidth - env.guardringspace - env.guardringwidth - env.guardringsep / 2),
        instances[_P.numstack]:get_anchor("drainstrapinner"):translate(100, 0)
    ))
    leftrightref:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        instances[_P.numstack]:get_anchor("drainstrapinner"):translate(-100, 0),
        instances[_P.numstack]:get_anchor("drainstrapouter"):translate(100, 0)
    ))

    local leftrightname = pcell.add_cell_reference(leftrightref, "leftrightref")
    local middlename = pcell.add_cell_reference(middleref, "middle")

    local middle = cell:add_child(middlename)
    local left = cell:add_child_array(leftrightname, 5, 1)
    left:move_anchor("right", middle:get_anchor("left"))
    local right = cell:add_child_array(leftrightname, 5, 1)
    right:move_anchor("left", middle:get_anchor("right"))

    local guardringref = pcell.create_layout("auxiliary/guardring", { 
        contype = "p", 
        ringwidth = 200, 
        width = (env.factor + 1) * env.fingers * (env.gatelength + env.gatespace) + 1000,
        height = _P.numstack * env.ypitch + 200 + 2 * 200 + env.powerbarwidth,
        drawdeepwell = false, 
        fillwell = false,
    })
    local guardringname = pcell.add_cell_reference(guardringref, "guardring")
    local guardring = cell:add_child(guardringname)
    guardring:translate(0, -(_P.numstack - 1) * 750)

    -- power grid vias
    for i = 1, _P.numstack + 1 do
        env.place_power_vias("vss", cell, env.gatewidth / 2 + env.powerbarspace + env.powerbarwidth / 2 - (i - 1) * env.ypitch)
    end
    env.place_power_vias("vss", cell, env.gatewidth / 2 + env.powerbarspace + env.powerbarwidth + env.guardringspace + env.guardringwidth / 2)
    env.place_power_vias("vss", cell, env.gatewidth / 2 + env.powerbarspace - _P.numstack * env.ypitch - env.guardringspace - env.guardringwidth / 2)

    cell:inherit_alignment_box(guardring)

    pcell.pop_overwrites("basic/mosfet")
end
