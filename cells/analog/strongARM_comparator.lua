--[[
  VDD ─────────────┬─────────┬─────┬───────────────────┬─────┬─────────┐
                   │         │     │                   │     │         │
                   │         │     │                   │     │         │
               ║───┘     ║───┘     └───║           ║───┘     └───║     └───║ 
    vclk o────o║────────o║             ║o──┐   ┌──o║             ║o────────║o────o vclk
               ║───┐     ║───┐     ┌───║   │   │   ║───┐     ┌───║     ┌───║ 
                   │         │     │       │   │       │     │         │
                   │         └─────┼───────────┤       │     │         │
                   │               │       │   │       │     │         │
                   │               │       ├───────────┼─────┘         │
                   │               │       │   │       │               │
                   │               └───║   │   │   ║───┘               │
                   │                   ║───┘   └───║                   │
                   │               ┌───║           ║───┐               │
                   │               │                   │               │
                   └───────────────┤                   ├───────────────┘
                                   │                   │
                               ║───┘                   └───║         
                    vinp o─────║                           ║o────o vinn
                               ║───┐                   ┌───║         
                                   └─────────┬─────────┘
                                             │
                                             │
                                         ║───┘
                               vclk o────║    
                                         ║───┐
                                             │
                                             │
  VSS ───────────────────────────────────────┴──────────────────────────
--]]

function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "gatelength", tech.get_dimension("Minimum Gate Length") },
        { "gatespace", tech.get_dimension("Minimum Gate Space") },
        { "fingerwidth", tech.get_dimension("Minimum Gate Width") },
        { "clockfingers", 8 },
        { "clockdummyfingers", 0 },
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
    -- clock tail dummy transistor (split actual clock transistor in two, left and right)
    -- this is not needed, maybe I will get rid of this at some point
    -- the transistor in the middle can be used to equalize the width regarding the input transistors
    local nmosclockdummyref
    if _P.clockdummyfingers > 0 then
        nmosclockdummyref = pcell.create_layout("basic/mosfet", { 
            channeltype = "nmos",
            fingers = _P.clockdummyfingers,
            drawbotgate = true,
            botgatecompsd = false,
            connectdrain = true,
            connectdraininverse = true,
            gtopext = 200 + 200,
            connectsource = true,
        })
    end
    -- clock tail transistor
    local nmosclockref = pcell.create_layout("basic/mosfet", { 
        drawtopgate = true,
        topgatestrspace = 200,
        topgatestrwidth = 200,
        channeltype = "nmos",
        fingers = _P.clockfingers / 2,
        topgatecompsd = false,
        connectdrain = true,
        conndrainmetal = 2,
        conndrainspace = 800,
        drawdrainvia = true,
        connectsource = true,
        gbotext = 200 + 200,
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
        connectsource = true,
        connsourcemetal = 2,
        drawsourcevia = true,
        drawbotgate = true,
        connsourcespace = 800,
        connectdrain = true,
        botgatecompsd = false
    })
    -- CMOS inverter
    local nmosdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        fingers = 2,
        cliptop = true,
        connectsource = true
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

    local nmosclockdummyname
    if _P.clockdummyfingers > 0 then
        nmosclockdummyname = pcell.add_cell_reference(nmosclockdummyref, "nmosclockdummy")
    end
    local nmosclockname = pcell.add_cell_reference(nmosclockref, "nmosclock")
    local nmosinputdummyname = pcell.add_cell_reference(nmosinputdummyref, "nmosinputdummy")
    local nmosinputname = pcell.add_cell_reference(nmosinputref, "nmosinput")
    local nmosdummyname = pcell.add_cell_reference(nmosdummyref, "nmosdummy")
    local nmosinvname = pcell.add_cell_reference(nmosinvref, "nmosinv")
    local pmosdummyname = pcell.add_cell_reference(pmosdummyref, "pmosdummy")
    local pmosinvname = pcell.add_cell_reference(pmosinvref, "pmosinv")
    local pmosresetname = pcell.add_cell_reference(pmosresetref, "pmosreset")

    local nmosclockdummy
    local nmosclockleft, nmosclockright
    if _P.clockdummyfingers > 0 then
        nmosclockdummy = comparator:add_child(nmosclockdummyname)
        nmosclockleft = comparator:add_child(nmosclockname)
        nmosclockright = comparator:add_child(nmosclockname)
        nmosclockleft:move_anchor("sourcedrainrightcc", nmosclockdummy:get_anchor("sourcedrainleftcc"))
        nmosclockright:move_anchor("sourcedrainleftcc", nmosclockdummy:get_anchor("sourcedrainrightcc"))
        -- connect both gates
        geometry.rectanglebltr(comparator, generics.metal(1),
            nmosclockleft:get_anchor("topgatestrapll"),
            nmosclockright:get_anchor("topgatestrapur")
        )
    else
        nmosclockleft = comparator:add_child(nmosclockname)
        nmosclockright = nmosclockleft
    end
    --local nmosinputdummy = comparator:add_child(nmosinputdummyname)
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

    --nmosinputdummy:move_anchor("sourcestrap", nmosclockdummy:get_anchor("topgate"))
    nmosinputleft:move_anchor("sourcedrainrightcc")
    nmosinputleft:move_anchor_y("sourcestrapcr", nmosclockleft:get_anchor("drainstrapcr"))
    nmosinputright:move_anchor("sourcedrainleftcc")
    nmosinputright:move_anchor_y("sourcestrapcl", nmosclockright:get_anchor("drainstrapcl"))
    nmosdummy:move_anchor_y("sourcestrapcc", nmosinputleft:get_anchor("drainstrapcl"))
    nmosinvleft:move_anchor("sourcedrainrightcc", nmosdummy:get_anchor("sourcedrainleftcc"))
    nmosinvright:move_anchor("sourcedrainleftcc", nmosdummy:get_anchor("sourcedrainrightcc"))
    pmosinvleft:move_anchor("botgatestrapcc", nmosinvleft:get_anchor("topgatestrapcc"))
    pmosinvright:move_anchor("botgatestrapcc", nmosinvright:get_anchor("topgatestrapcc"))
    pmosdummy:move_anchor("sourcedrainleftcc", pmosinvleft:get_anchor("sourcedrainrightcc"))
    pmosresetleft1:move_anchor("sourcedrainrightcc", pmosinvleft:get_anchor("sourcedrainleftcc"))
    pmosresetleft2:move_anchor("sourcedrainrightcc", pmosresetleft1:get_anchor("sourcedrainleftcc"))
    pmosresetright1:move_anchor("sourcedrainleftcc", pmosinvright:get_anchor("sourcedrainrightcc"))
    pmosresetright2:move_anchor("sourcedrainleftcc", pmosresetright1:get_anchor("sourcedrainrightcc"))

    -- connect reset gates
    geometry.path(comparator, generics.metal(1), {
        pmosresetleft1:get_anchor("botgatestrapcl"),
        pmosresetleft2:get_anchor("botgatestrapcr"),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(1), {
        pmosresetright1:get_anchor("botgatestrapcr"),
        pmosresetright2:get_anchor("botgatestrapcl"),
    }, _P.sdwidth)

    -- connect latch gates
    geometry.path(comparator, generics.metal(3), geometry.path_points_xy(
        pmosinvleft:get_anchor("sourcedrain2cc"), {
            3 * xpitch,
            nmosinvright:get_anchor("topgatestrapcc"),
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(3), geometry.path_points_xy(
        nmosinvright:get_anchor("sourcedrain2cc"), {
            -3 * xpitch,
            nmosinvleft:get_anchor("topgatestrapcc"),
    }), _P.sdwidth)
    geometry.viabltr(comparator, 1, 3,
        nmosinvleft:get_anchor("topgatestrapll"),
        nmosinvleft:get_anchor("topgatestrapur")
    )
    geometry.viabltr(comparator, 1, 3,
        nmosinvright:get_anchor("topgatestrapll"),
        nmosinvright:get_anchor("topgatestrapur")
    )

    -- connect latch drains
    geometry.path(comparator, generics.metal(3), {
        pmosinvleft:get_anchor("sourcedrain2cc"),
        pmosinvleft:get_anchor("sourcedrain2cc"):translate(-xpitch, 0),
        nmosinvleft:get_anchor("sourcedrain2cc"):translate(-xpitch, 0),
        nmosinvleft:get_anchor("sourcedrain2cc"),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(3), {
        pmosinvright:get_anchor("sourcedrain2cc"),
        pmosinvright:get_anchor("sourcedrain2cc"):translate(xpitch, 0),
        nmosinvright:get_anchor("sourcedrain2cc"):translate(xpitch, 0),
        nmosinvright:get_anchor("sourcedrain2cc"),
    }, _P.sdwidth)

    ---- connect inner reset transistors
    --geometry.path(comparator, generics.metal(2), {
    --    pmosresetleft1:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.resetfingers)),
    --    pmosinvleft:get_anchor(string.format("sourcedrainmiddlecenter%d", 2)),
    --}, _P.sdwidth)
    --geometry.path(comparator, generics.metal(2), {
    --    pmosresetright1:get_anchor(string.format("sourcedrainmiddlecenter%d", 2)),
    --    pmosinvright:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.resetfingers)),
    --}, _P.sdwidth)

    ---- connect outer reset transistors
    --geometry.path(comparator, generics.metal(2), 
    --    geometry.path_points_yx(pmosresetleft2:get_anchor(string.format("sourcedrainmiddlecenter%d", _P.resetfingers)), {
    --        nmosinvleft:get_anchor("sourcestrapmiddlecenter")
    --}), _P.sdwidth)
    --geometry.path(comparator, generics.metal(2), 
    --    geometry.path_points_yx(pmosresetright2:get_anchor(string.format("sourcedrainmiddlecenter%d", 2)), {
    --        nmosinvright:get_anchor("sourcestrapmiddlecenter")
    --}), _P.sdwidth)

    -- connect clock gates
    --geometry.path(comparator, generics.metal(1), 
    --    geometry.path_points_yx(pmosresetleft2:get_anchor("botgatestrap"), {
    --        nmosclockleft:get_anchor("topgatestrapleft")
    --}), _P.sdwidth)
    --geometry.path(comparator, generics.metal(1), 
    --    geometry.path_points_yx(pmosresetright2:get_anchor("botgatestrap"), {
    --        nmosclockright:get_anchor("topgatestrapright")
    --}), _P.sdwidth)

    ---- add ports
    --comparator:add_port("clk", generics.metal(1), point.combine(nmosclockleft:get_anchor("topgatestrap"), nmosclockright:get_anchor("topgatestrap")))
    --comparator:add_port("vinp", generics.metal(1), nmosinputleft:get_anchor("topgatestrap"))
    --comparator:add_port("vinn", generics.metal(1), nmosinputright:get_anchor("topgatestrap"))
    --comparator:add_port("vss", generics.metal(1), nmosclockdummy:get_anchor("sourcestrapmiddlecenter"))
    --comparator:add_port("vdd", generics.metal(1), pmosinvleft:get_anchor("drainstrapmiddlecenter"))
end

-- TODO:
--   * nmos inverter transistors need to be separated, they don't share source/drain
--      -> add dummy between these transistors
--   * no cross coupling, this also needs to be placed
