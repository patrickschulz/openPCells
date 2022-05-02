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
        { "gatelength", tech.get_dimension("Minimum Gate Length") },
        { "gatespace", tech.get_dimension("Minimum Gate Space") },
        { "fingerwidth", tech.get_dimension("Minimum Gate Width") },
        { "clockfingers", 8 },
        { "nmosinputfingers", 2 },
        { "latchfingers", 2 },
        { "resetfingers", 2 },
        { "sdwidth", tech.get_dimension("Minimum M1 Width") }
    )
end

function layout(comparator, _P)
    local xpitch = _P.gatelength + _P.gatespace

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.gatelength, 
        gatespace = _P.gatespace, 
        fwidth = _P.fingerwidth, 
        sdwidth = _P.sdwidth,
    })
    pcell.push_overwrites("basic/mosfet", {
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        drawtopgate = true,
    })
    local nmosclockdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        fingers = 2,
        drawtopgate = false,
        drawbotgate = true,
        botgatestrspace = 100,
        connectdrain = true,
        conndrainmetal = 1,
        connectinverse = true,
        gtopext = 200,
    })
    -- clock tail transistor
    local nmosclockref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        fingers = _P.clockfingers / 2,
    })
    -- input transistors
    local nmosinputdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        fingers = 2,
        drawtopgate = false,
        drawbotgate = false,
        connectsource = false,
        connectdrain = false,
        drawdrainvia = false
    })
    local nmosinputref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        fingers = _P.nmosinputfingers,
        connsourcemetal = 2,
        drawsourcevia = true
    })
    pcell.pop_overwrites("basic/mosfet")
    -- CMOS inverter
    local nmosdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        fingers = 2,
        cliptop = true
    })
    local nmosinvref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
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
        vthtype = 1,
        drawbotgate = true,
        fingers = _P.latchfingers,
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 3,
        drawdrainvia = true,
        conndraininline = true,
        clipbot = true
    })
    local pmosdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        fingers = 2,
        clipbot = true
    })
    -- reset switches
    local pmosresetref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        vthtype = 1,
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

    local nmosclockdummyname = pcell.add_cell_reference(nmosclockdummyref, "nmosclockdummy")
    local nmosclockname = pcell.add_cell_reference(nmosclockref, "nmosclock")
    local nmosinputdummyname = pcell.add_cell_reference(nmosinputdummyref, "nmosinputdummy")
    local nmosinputname = pcell.add_cell_reference(nmosinputref, "nmosinput")
    local nmosdummyname = pcell.add_cell_reference(nmosdummyref, "nmosdummy")
    local nmosinvname = pcell.add_cell_reference(nmosinvref, "nmosinv")
    local pmosdummyname = pcell.add_cell_reference(pmosdummyref, "pmosdummy")
    local pmosinvname = pcell.add_cell_reference(pmosinvref, "pmosinv")
    local pmosresetname = pcell.add_cell_reference(pmosresetref, "pmosreset")

    local nmosclockdummy = comparator:add_child(nmosclockdummyname)
    local nmosclockleft = comparator:add_child(nmosclockname)
    local nmosclockright = comparator:add_child(nmosclockname)
    local nmosinputdummy = comparator:add_child(nmosinputdummyname)
    local nmosinputleft = comparator:add_child(nmosinputname)
    local nmosinputright = comparator:add_child(nmosinputname)
    local nmosdummy = comparator:add_child(nmosdummyname)
    local nmosinvleft = comparator:add_child(nmosinvname)
    local nmosinvright = comparator:add_child(nmosinvname)
    local pmosdummy = comparator:add_child(pmosdummyname)
    local pmosinvleft = comparator:add_child(pmosinvname)
    local pmosinvright = comparator:add_child(pmosinvname)
    local pmosresetleft1 = comparator:add_child(pmosresetname)
    local pmosresetleft2 = comparator:add_child(pmosresetname)
    local pmosresetright1 = comparator:add_child(pmosresetname)
    local pmosresetright2 = comparator:add_child(pmosresetname)

    nmosclockleft:move_anchor("sourcedrainmiddlecenterright", nmosclockdummy:get_anchor("sourcedrainmiddlecenterleft"))
    nmosclockright:move_anchor("sourcedrainmiddlecenterleft", nmosclockdummy:get_anchor("sourcedrainmiddlecenterright"))
    nmosinputdummy:move_anchor("botgate", nmosclockdummy:get_anchor("topgate"))
    nmosinputleft:move_anchor("sourcedrainmiddlecenterright", nmosinputdummy:get_anchor("sourcedrainmiddlecenterleft"))
    nmosinputright:move_anchor("sourcedrainmiddlecenterleft", nmosinputdummy:get_anchor("sourcedrainmiddlecenterright"))
    nmosdummy:move_anchor_y("sourcestrapmiddlecenter", nmosinputleft:get_anchor("drainstrapmiddlecenter"))
    nmosinvleft:move_anchor("sourcedrainmiddlecenterright", nmosdummy:get_anchor("sourcedrainmiddlecenterleft"))
    nmosinvright:move_anchor("sourcedrainmiddlecenterleft", nmosdummy:get_anchor("sourcedrainmiddlecenterright"))
    pmosinvleft:move_anchor("botgatestrap", nmosinvleft:get_anchor("topgatestrap"))
    pmosinvright:move_anchor("botgatestrap", nmosinvright:get_anchor("topgatestrap"))
    pmosdummy:move_anchor("sourcedrainmiddlecenterleft", pmosinvleft:get_anchor("sourcedrainmiddlecenterright"))
    pmosresetleft1:move_anchor("sourcedrainmiddlecenterright", pmosinvleft:get_anchor("sourcedrainmiddlecenterleft"))
    pmosresetleft2:move_anchor("sourcedrainmiddlecenterright", pmosresetleft1:get_anchor("sourcedrainmiddlecenterleft"))
    pmosresetright1:move_anchor("sourcedrainmiddlecenterleft", pmosinvright:get_anchor("sourcedrainmiddlecenterright"))
    pmosresetright2:move_anchor("sourcedrainmiddlecenterleft", pmosresetright1:get_anchor("sourcedrainmiddlecenterright"))

    -- connect reset gates
    geometry.path(comparator, generics.metal(1), {
        pmosresetleft1:get_anchor("botgatestrapleft"),
        pmosresetleft2:get_anchor("botgatestrapright"),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(1), {
        pmosresetright1:get_anchor("botgatestrapright"),
        pmosresetright2:get_anchor("botgatestrapleft"),
    }, _P.sdwidth)

    -- connect latch gates
    geometry.path(comparator, generics.metal(3), geometry.path_points_xy(
        pmosinvleft:get_anchor("sourcedrainmiddlecenter2"), {
            3 * xpitch,
            nmosinvright:get_anchor("topgatestrap"),
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(3), geometry.path_points_xy(
        nmosinvright:get_anchor("sourcedrainmiddlecenter2"), {
            -3 * xpitch,
            nmosinvleft:get_anchor("topgatestrap"),
    }), _P.sdwidth)
    geometry.viabltr(comparator, 1, 3,
        nmosinvleft:get_anchor("topgatestraplowerleft"),
        nmosinvleft:get_anchor("topgatestrapupperright")
    )
    geometry.viabltr(comparator, 1, 3,
        nmosinvright:get_anchor("topgatestraplowerleft"),
        nmosinvright:get_anchor("topgatestrapupperright")
    )

    -- connect latch drains
    geometry.path(comparator, generics.metal(3), {
        pmosinvleft:get_anchor("sourcedrainmiddlecenter2"),
        pmosinvleft:get_anchor("sourcedrainmiddlecenter2"):translate(-xpitch, 0),
        nmosinvleft:get_anchor("sourcedrainmiddlecenter2"):translate(-xpitch, 0),
        nmosinvleft:get_anchor("sourcedrainmiddlecenter2"),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(3), {
        pmosinvright:get_anchor("sourcedrainmiddlecenter2"),
        pmosinvright:get_anchor("sourcedrainmiddlecenter2"):translate(xpitch, 0),
        nmosinvright:get_anchor("sourcedrainmiddlecenter2"):translate(xpitch, 0),
        nmosinvright:get_anchor("sourcedrainmiddlecenter2"),
    }, _P.sdwidth)

    -- connect inner reset transistors
    geometry.path(comparator, generics.metal(2), {
        pmosresetleft1:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.resetfingers)),
        pmosinvleft:get_anchor(string.format("sourcedrainmiddlecenter%d", 2)),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(2), {
        pmosresetright1:get_anchor(string.format("sourcedrainmiddlecenter%d", 2)),
        pmosinvright:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.resetfingers)),
    }, _P.sdwidth)

    -- connect outer reset transistors
    geometry.path(comparator, generics.metal(2), 
        geometry.path_points_yx(pmosresetleft2:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.resetfingers)), {
            nmosinvleft:get_anchor("sourcestrapmiddlecenter")
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(2), 
        geometry.path_points_yx(pmosresetright2:get_anchor(string.format("sourcedrainmiddlecenter%d", 2)), {
            nmosinvright:get_anchor("sourcestrapmiddlecenter")
    }), _P.sdwidth)

    -- connect clock gates
    geometry.path(comparator, generics.metal(1), {
        nmosclockleft:get_anchor("topgatestrapleft"),
        nmosclockright:get_anchor("topgatestrapright")
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(1), 
        geometry.path_points_yx(pmosresetleft2:get_anchor("botgatestrap"), {
            nmosclockleft:get_anchor("topgatestrapleft")
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(1), 
        geometry.path_points_yx(pmosresetright2:get_anchor("botgatestrap"), {
            nmosclockright:get_anchor("topgatestrapright")
    }), _P.sdwidth)

    -- add ports
    comparator:add_port("clk", generics.metal(1), point.combine(nmosclockleft:get_anchor("topgatestrap"), nmosclockright:get_anchor("topgatestrap")))
    comparator:add_port("vinp", generics.metal(1), nmosinputleft:get_anchor("topgatestrap"))
    comparator:add_port("vinn", generics.metal(1), nmosinputright:get_anchor("topgatestrap"))
    comparator:add_port("vss", generics.metal(1), nmosclockdummy:get_anchor("sourcestrapmiddlecenter"))
    comparator:add_port("vdd", generics.metal(1), pmosinvleft:get_anchor("drainstrapmiddlecenter"))
end

-- TODO:
--   * nmos inverter transistors need to be separated, they don't share source/drain
--      -> add dummy between these transistors
--   * no cross coupling, this also needs to be placed
