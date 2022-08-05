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
        { "pfetvthtype", 1 },
        { "nfetvthtype", 1 },
        { "pfetflippedwell", false },
        { "nfetflippedwell", false },
        { "clockfingers", 8 },
        { "clockdummyfingers", 1 },
        { "clockfwidth", 500 },
        { "inputfingers", 4 },
        { "inputfwidth", 800 },
        { "inputdummyfingers", 1 },
        { "latchfingers", 8 },
        { "latchnfwidth", 1000 },
        { "latchpfwidth", 1000 },
        { "invdummyfingers", 1 },
        { "resetfingers", 2 },
        { "inputclocksdspace", 800 },
        { "invinputsdspace", 400 },
        { "invgstrapspace", 200 },
        { "sdwidth", tech.get_dimension("Minimum M1 Width") },
        { "powerwidth", 400 }
    )
end

function layout(comparator, _P)
    local xpitch = _P.gatelength + _P.gatespace

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.gatelength, 
        gatespace = _P.gatespace, 
        sdwidth = _P.sdwidth,
    })
    -- clock tail dummy transistor (split actual clock transistor in two, left and right)
    -- this is not needed, maybe I will get rid of this at some point
    -- the transistor in the middle can be used to equalize the width regarding the input transistors
    local clockdummyref
    if _P.clockdummyfingers > 0 then
        clockdummyref = pcell.create_layout("basic/mosfet", { 
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            fingers = _P.clockdummyfingers,
            fwidth = _P.clockfwidth,
            drawbotgate = true,
            gtopext = _P.inputclocksdspace + _P.sdwidth / 2,
            botgatecompsd = false,
            connectdrain = true,
            connectdraininverse = true,
            connectsource = true,
            connsourcewidth = _P.powerwidth,
            conndrainwidth = _P.powerwidth,
            extenddrainconnection = true,
            extendsourceconnection = true
        })
    end
    -- clock tail transistor
    local clockref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.clockfingers / 2,
        fwidth = _P.clockfwidth,
        drawtopgate = true,
        topgatestrspace = 200,
        topgatestrwidth = 200,
        topgatecompsd = false,
        connectdrain = true,
        conndrainmetal = 2,
        conndrainwidth = _P.sdwidth,
        conndrainspace = _P.inputclocksdspace,
        drawdrainvia = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        gbotext = 200 + 200,
    })
    -- input transistors
    local inputdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.inputdummyfingers,
        fwidth = _P.inputfwidth,
        drawtopgate = false,
        drawbotgate = false,
        connectsource = false,
        connectdrain = false,
        drawdrainvia = false,
        gtopext = _P.invinputsdspace + _P.sdwidth / 2,
        gbotext = _P.inputclocksdspace + _P.sdwidth / 2
    })
    local inputref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.inputfingers,
        fwidth = _P.inputfwidth,
        connectsource = true,
        connsourcemetal = 2,
        drawsourcevia = true,
        drawbotgate = true,
        connsourcespace = _P.inputclocksdspace,
        connectdrain = true,
        conndrainwidth = _P.sdwidth,
        conndrainspace = _P.invinputsdspace,
        botgatecompsd = false
    })
    -- CMOS inverter
    local nmosdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.invdummyfingers,
        fwidth = _P.latchnfwidth,
        cliptop = true,
        gbotext = _P.invinputsdspace + _P.sdwidth / 2
    })
    local nmosinvref = pcell.create_layout("basic/mosfet", { 
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrspace = _P.invgstrapspace,
        fingers = _P.latchfingers,
        fwidth = _P.latchnfwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = _P.sdwidth,
        connsourcespace = _P.invinputsdspace,
        connectdrain = true,
        conndrainmetal = 3,
        drawdrainvia = true,
        conndraininline = true,
        cliptop = true
    })
    local pmosinvref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrspace = _P.invgstrapspace,
        fingers = _P.latchfingers,
        fwidth = _P.latchpfwidth,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connectdrain = true,
        conndrainmetal = 3,
        drawdrainvia = true,
        conndraininline = true,
        clipbot = true
    })
    local pmosdummyref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = _P.invdummyfingers,
        fwidth = _P.latchpfwidth,
        clipbot = true,
        drawtopgate = true,
        topgatecompsd = false,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        conndrainwidth = _P.powerwidth,
        extenddrainconnection = true,
        extendsourceconnection = true
    })
    -- reset switches
    local pmosresetref = pcell.create_layout("basic/mosfet", { 
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        fingers = _P.resetfingers,
        fwidth = _P.latchpfwidth,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        clipbot = true
    })
    pcell.pop_overwrites("basic/mosfet")

    local clockdummyname
    if _P.clockdummyfingers > 0 then
        clockdummyname = pcell.add_cell_reference(clockdummyref, "clockdummy")
    end
    local clockname = pcell.add_cell_reference(clockref, "clock")
    local inputdummyname = pcell.add_cell_reference(inputdummyref, "nmosinputdummy")
    local inputname = pcell.add_cell_reference(inputref, "nmosinput")
    local nmosdummyname = pcell.add_cell_reference(nmosdummyref, "nmosdummy")
    local nmosinvname = pcell.add_cell_reference(nmosinvref, "nmosinv")
    local pmosdummyname = pcell.add_cell_reference(pmosdummyref, "pmosdummy")
    local pmosinvname = pcell.add_cell_reference(pmosinvref, "pmosinv")
    local pmosresetname = pcell.add_cell_reference(pmosresetref, "pmosreset")

    local clockdummy
    local clockleft, clockright
    if _P.clockdummyfingers > 0 then
        clockdummy = comparator:add_child(clockdummyname)
        clockleft = comparator:add_child(clockname)
        clockright = comparator:add_child(clockname)
        clockleft:move_anchor("sourcedrainrightcc", clockdummy:get_anchor("sourcedrainleftcc"))
        clockright:move_anchor("sourcedrainleftcc", clockdummy:get_anchor("sourcedrainrightcc"))
        -- connect both gates
        geometry.rectanglebltr(comparator, generics.metal(1),
            clockleft:get_anchor("topgatestrapll"),
            clockright:get_anchor("topgatestrapur")
        )
    else
        clockleft = comparator:add_child(clockname)
        clockright = clockleft
    end
    local inputdummy
    if _P.inputdummyfingers > 0 then
        inputdummy = comparator:add_child(inputdummyname)
    end
    local inputleft = comparator:add_child(inputname)
    local inputright = comparator:add_child(inputname)
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

    inputleft:move_anchor_y("sourcestrapcr", clockleft:get_anchor("drainstrapcr"))
    inputdummy:move_anchor_y("sourcedrainleftcc", inputleft:get_anchor("sourcedrainleftcc"))
    inputleft:move_anchor("sourcedrainrightcc", inputdummy:get_anchor("sourcedrainleftcc"))
    inputright:move_anchor("sourcedrainleftcc", inputdummy:get_anchor("sourcedrainrightcc"))
    nmosinvleft:move_anchor_y("sourcestrapcc", inputleft:get_anchor("drainstrapcc"))
    nmosdummy:move_anchor_y("sourcedrainleftcc", nmosinvleft:get_anchor("sourcedrainrightcc"))
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
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", _P.latchfingers)), {
            (_P.invdummyfingers + 1) * xpitch,
            nmosinvright:get_anchor("topgatestrapcr"),
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(3), geometry.path_points_xy(
        nmosinvright:get_anchor("sourcedrain2cc"), {
            -(_P.invdummyfingers + 1) * xpitch,
            nmosinvleft:get_anchor("topgatestrapcl"),
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
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)),
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)):translate(-2 * xpitch, 0),
        nmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)):translate(-2 * xpitch, 0),
        nmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(3), {
        pmosinvright:get_anchor(string.format("sourcedrain%dcc", _P.latchfingers)),
        pmosinvright:get_anchor(string.format("sourcedrain%dcc", _P.latchfingers)):translate(2 * xpitch, 0),
        nmosinvright:get_anchor(string.format("sourcedrain%dcc", _P.latchfingers)):translate(2 * xpitch, 0),
        nmosinvright:get_anchor(string.format("sourcedrain%dcc", _P.latchfingers)),
    }, _P.sdwidth)

    ---- connect inner reset transistors
    geometry.path(comparator, generics.metal(2), {
        pmosresetleft1:get_anchor(string.format("sourcedrain%dcc", _P.resetfingers)),
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(2), {
        pmosresetright1:get_anchor(string.format("sourcedrain%dcc", 2)),
        pmosinvright:get_anchor(string.format("sourcedrain%dcc", _P.resetfingers)),
    }, _P.sdwidth)

    -- connect outer reset transistors
    geometry.path(comparator, generics.metal(2), 
        geometry.path_points_yx(pmosresetleft2:get_anchor(string.format("sourcedrain%dcc", _P.resetfingers)), {
            nmosinvleft:get_anchor("sourcestrapcr")
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(2), 
        geometry.path_points_yx(pmosresetright2:get_anchor(string.format("sourcedrain%dcc", 2)), {
            nmosinvright:get_anchor("sourcestrapcl")
    }), _P.sdwidth)
    geometry.viabltr(comparator, 1, 2,
        nmosinvright:get_anchor("sourcestrapll"),
        nmosinvright:get_anchor("sourcestrapur")
    )
    geometry.viabltr(comparator, 1, 2,
        nmosinvleft:get_anchor("sourcestrapll"),
        nmosinvleft:get_anchor("sourcestrapur")
    )

    -- connect vtail
    geometry.rectanglebltr(comparator, generics.metal(2),
        inputleft:get_anchor("sourcestraplr"),
        inputright:get_anchor("sourcestrapul")
    )

    -- connect clock gates
    geometry.path(comparator, generics.metal(1), 
        geometry.path_points_yx(pmosresetleft2:get_anchor("botgatestrapcc"), {
            clockleft:get_anchor("topgatestrapcc")
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(1), 
        geometry.path_points_yx(pmosresetright2:get_anchor("botgatestrapcc"), {
            clockright:get_anchor("topgatestrapcc")
    }), _P.sdwidth)

    ---- add ports
    comparator:add_port("clk", generics.metalport(1), point.combine(clockleft:get_anchor("topgatestrapcc"), clockright:get_anchor("topgatestrapcc")))
    comparator:add_port("vinp", generics.metalport(1), inputleft:get_anchor("botgatestrapcc"))
    comparator:add_port("vinn", generics.metalport(1), inputright:get_anchor("botgatestrapcc"))
    comparator:add_port("vss", generics.metalport(1), clockdummy:get_anchor("sourcestrapcc"))
    comparator:add_port("vdd", generics.metalport(1), pmosdummy:get_anchor("sourcestrapcc"))
end
