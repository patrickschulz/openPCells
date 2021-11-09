--[[

  VDD -------------*---------*-----*-----------------*-----*---------*-------
                   |         |     |                 |     |         |
                   |         |     |                 |     |         |
               |---|     |---|     |---|         |---|     |---|     |---| 
    vclk o----o|--------o|             |o--   --o|             |o--------|o----o vclk
               |---|     |---|     |---|   \ /   |---|     |---|     |---| 
                   |         |     |        x        |     |         |
                   |         |-----*-------* *-------*-----|         |
                   |               |        x        |               |
                   |               |---|   / \   |---|               |
                   |                   |---   ---|                   |
                   |               |---|         |---|               |
                   |               |                 |               |
                   |---------------*                 *---------------|
                                   |                 |
                               |---|                 |---|         
                    vinp o-----|                         |o----o vinn
                               |---|                 |---|         
                                   |--------*--------|
                                            |
                                            |
                                        |---|
                              vclk o----|    
                                        |---|
                                            |
                                            |
  VSS --------------------------------------*---------------------------------

--]]

function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "clockfingers", 8 },
        { "nmosinputfingers", 2 },
        { "latchfingers", 2 },
        { "resetfingers", 2 },
        { "sdwidth", 40 }
    )
end

function layout(comparator, _P)
    local glength = 40
    local gspace = 90
    local fingerwidth = 500
    local fingerpitch = glength + gspace

    pcell.push_overwrites("basic/mosfet", {
        channeltype = "nmos",
        gatelength = glength, 
        gatespace = gspace, 
        fwidth = fingerwidth, 
        sdconnspace = 100,
        sdwidth = _P.sdwidth,
    })
    pcell.push_overwrites("basic/mosfet", {
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        drawtopgate = true,
    })
    -- clock tail transistor
    local nmosclockref = pcell.create_layout("basic/mosfet", { 
        fingers = _P.clockfingers,
    })
    -- input transistors
    local nmosinputref = pcell.create_layout("basic/mosfet", { 
        fingers = _P.nmosinputfingers,
        connsourcemetal = 2,
        drawsourcevia = true
    })
    pcell.pop_overwrites("basic/mosfet")
    -- CMOS inverter
    local nmosinvref = pcell.create_layout("basic/mosfet", { 
        drawtopgate = true,
        fingers = _P.latchfingers,
        connectsource = true,
        connsourcemetal = 2,
        drawsourcevia = true,
        connectdrain = true,
        conndrainmetal = 3,
        drawdrainvia = true,
        conndraininline = true,
        cliptop = true
    })
    local pmosinvref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        vthtype = 3,
        drawbotgate = true,
        fingers = _P.latchfingers,
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        clipbot = true
    })
    -- reset switches
    local pmosresetref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        vthtype = 3,
        drawbotgate = true,
        fingers = _P.resetfingers,
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        clipbot = true
    })
    pcell.pop_overwrites("basic/mosfet")

    local nmosclockname = pcell.add_cell_reference(nmosclockref, "nmosclock")
    local nmosinputname = pcell.add_cell_reference(nmosinputref, "nmosinput")
    local nmosinvname = pcell.add_cell_reference(nmosinvref, "nmosinv")
    local pmosinvname = pcell.add_cell_reference(pmosinvref, "pmosinv")
    local pmosresetname = pcell.add_cell_reference(pmosresetref, "pmosreset")

    local nmosclock = comparator:add_child(nmosclockname)
    local nmosinputleft = comparator:add_child(nmosinputname)
    local nmosinputright = comparator:add_child(nmosinputname)
    local nmosinvleft = comparator:add_child(nmosinvname)
    local pmosinvleft = comparator:add_child(pmosinvname)
    local nmosinvright = comparator:add_child(nmosinvname)
    local pmosinvright = comparator:add_child(pmosinvname)
    local pmosresetleft1 = comparator:add_child(pmosresetname)
    local pmosresetleft2 = comparator:add_child(pmosresetname)
    local pmosresetright1 = comparator:add_child(pmosresetname)
    local pmosresetright2 = comparator:add_child(pmosresetname)
    nmosinputleft:move_anchor("right")
    nmosinputright:move_anchor("left")
    nmosinputleft:move_anchor_y("sourcestrap", nmosclock:get_anchor("drainstrap"))
    nmosinputright:move_anchor_y("sourcestrap", nmosclock:get_anchor("drainstrap"))
    nmosinvleft:move_anchor("right")
    nmosinvright:move_anchor("left")
    nmosinvleft:move_anchor_y("sourcestrap", nmosinputleft:get_anchor("drainstrap"))
    nmosinvright:move_anchor_y("sourcestrap", nmosinputright:get_anchor("drainstrap"))
    pmosinvleft:move_anchor("right")
    pmosinvright:move_anchor("left")
    pmosinvleft:move_anchor_y("botgatestrap", nmosinvleft:get_anchor("topgatestrap"))
    pmosinvright:move_anchor_y("botgatestrap", nmosinvright:get_anchor("topgatestrap"))
    pmosresetleft1:move_anchor("right", pmosinvleft:get_anchor("left"))
    pmosresetleft2:move_anchor("right", pmosresetleft1:get_anchor("left"))
    pmosresetright1:move_anchor("left", pmosinvright:get_anchor("right"))
    pmosresetright2:move_anchor("left", pmosresetright1:get_anchor("right"))

    -- connect reset gates
    comparator:merge_into_shallow(geometry.path(generics.metal(1), {
        pmosresetleft1:get_anchor("botgatestrapleft"),
        pmosresetleft2:get_anchor("botgatestrapright"),
    }, _P.sdwidth))
    comparator:merge_into_shallow(geometry.path(generics.metal(1), {
        pmosresetright1:get_anchor("botgatestrapright"),
        pmosresetright2:get_anchor("botgatestrapleft"),
    }, _P.sdwidth))

    -- connect latch gate and drain
    comparator:merge_into_shallow(geometry.path(generics.metal(1), {
        pmosinvleft:get_anchor(string.format("sourcedrainlower%d", _P.latchfingers)),
        nmosinvleft:get_anchor(string.format("sourcedrainupper%d", _P.latchfingers)),
    }, _P.sdwidth))
    comparator:merge_into_shallow(geometry.path(generics.metal(1), {
        pmosinvright:get_anchor("sourcedrainlower2"),
        nmosinvright:get_anchor("sourcedrainupper2"),
    }, _P.sdwidth))

    -- connect inner reset transistors
    comparator:merge_into_shallow(geometry.path(generics.metal(2), {
        pmosresetleft1:get_anchor(string.format("sourcedrainmiddle%d", _P.resetfingers)),
        pmosinvleft:get_anchor(string.format("sourcedrainmiddle%d", 2)),
    }, _P.sdwidth))
    comparator:merge_into_shallow(geometry.path(generics.metal(2), {
        pmosresetright1:get_anchor(string.format("sourcedrainmiddle%d", 2)),
        pmosinvright:get_anchor(string.format("sourcedrainmiddle%d", _P.resetfingers)),
    }, _P.sdwidth))

    -- connect outer reset transistors
    comparator:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(pmosresetleft2:get_anchor(string.format("sourcedrainmiddle%d", _P.resetfingers)), {
            nmosinvleft:get_anchor("sourcestrap")
    }), _P.sdwidth))
    comparator:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(pmosresetright2:get_anchor(string.format("sourcedrainmiddle%d", 2)), {
            nmosinvright:get_anchor("sourcestrap")
    }), _P.sdwidth))

    -- connect clock gates
    comparator:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(pmosresetleft2:get_anchor("botgatestrap"), {
            nmosclock:get_anchor("topgatestrapleft")
    }), _P.sdwidth))
    comparator:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(pmosresetright2:get_anchor("botgatestrap"), {
            nmosclock:get_anchor("topgatestrapright")
    }), _P.sdwidth))

    -- add ports
    comparator:add_port("clk", generics.metal(1), nmosclock:get_anchor("topgatestrap"))
    comparator:add_port("vinp", generics.metal(1), nmosinputleft:get_anchor("topgatestrap"))
    comparator:add_port("vinn", generics.metal(1), nmosinputright:get_anchor("topgatestrap"))
    comparator:add_port("vss", generics.metal(1), nmosclock:get_anchor("sourcestrap"))
    comparator:add_port("vdd", generics.metal(1), pmosinvleft:get_anchor("drainstrap"))
end

