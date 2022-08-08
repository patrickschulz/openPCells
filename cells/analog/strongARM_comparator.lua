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
        { "clockfingers", 4 },
        { "clockdummyfingers", 1 },
        { "clockfwidth", tech.get_dimension("Minimum Gate Width") },
        { "clockinputgatewidth", tech.get_dimension("Minimum M1 Width") },
        { "clockinputgatespace", tech.get_dimension("Minimum M1 Space") },
        { "inputfingers", 2 },
        { "inputfwidth", tech.get_dimension("Minimum Gate Width") },
        { "inputdummyfingers", 1 },
        { "latchfingers", 2 },
        { "latchnfwidth", tech.get_dimension("Minimum Gate Width") },
        { "latchpfwidth", tech.get_dimension("Minimum Gate Width") },
        { "invdummyfingers", 1 },
        { "resetfingers", 2 },
        { "inputclocksdspace", tech.get_dimension("Minimum M1 Space") },
        { "invinputsdspace", tech.get_dimension("Minimum M1 Space") },
        { "invgstrapwidth", tech.get_dimension("Minimum M1 Width") },
        { "invgstrapspace", tech.get_dimension("Minimum M1 Space") },
        { "sdwidth", tech.get_dimension("Minimum M1 Width") },
        { "powerwidth", tech.get_dimension("Minimum M1 Width") },
        { "powerspace", tech.get_dimension("Minimum M1 Space") }
    )
end

function layout(comparator, _P)
    local xpitch = _P.gatelength + _P.gatespace

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
    })

    local clockrowfingers = _P.clockfingers + _P.clockdummyfingers
    local inputrowfingers = 2 * _P.inputfingers + _P.inputdummyfingers
    local invnfingers = 2 * _P.latchfingers + _P.invdummyfingers
    local invpfingers = 2 * _P.latchfingers + 4 * _P.resetfingers + _P.invdummyfingers
    local maxfingers = math.max(clockrowfingers, inputrowfingers, invnfingers, invpfingers)
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
        topgatestrspace = _P.clockinputgatewidth,
        topgatestrwidth = _P.clockinputgatespace,
        topgatecompsd = false,
        connectdrain = true,
        conndrainmetal = 2,
        conndrainwidth = _P.sdwidth,
        conndrainspace = _P.inputclocksdspace,
        drawdrainvia = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        gbotext = _P.powerwidth + _P.powerspace,
    })
    local clockfillref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fwidth = _P.clockfwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        conndrainwidth = _P.powerwidth,
        extenddrainconnection = true,
        extendsourceconnection = true,
        gtopext = (clockrowfingers == inputrowfingers) and _P.inputclocksdspace + _P.sdwidth / 2,
        drawbotgate = true,
        gtopext = _P.inputclocksdspace + _P.sdwidth / 2,
        botgatecompsd = false,
    })
    local clockendleftref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fwidth = _P.clockfwidth,
        drawleftstopgate = true,
        drawsourcedrain = "none",
        drawtopgcut = true,
    })
    local clockendrightref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fwidth = _P.clockfwidth,
        drawrightstopgate = true,
        drawsourcedrain = "none",
        drawtopgcut = true,
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
    local inputfillref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fwidth = _P.inputfwidth,
        drawsourcedrain = "none",
        gbotext = (clockrowfingers == inputrowfingers) and _P.inputclocksdspace + _P.sdwidth / 2,
        gtopext = (inputrowfingers == invnfingers) and _P.invinputsdspace + _P.sdwidth / 2,
    })
    local inputendleftref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fwidth = _P.inputfwidth,
        drawleftstopgate = true,
        drawsourcedrain = "none",
    })
    local inputendrightref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fwidth = _P.inputfwidth,
        drawrightstopgate = true,
        drawsourcedrain = "none",
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
        topgatestrwidth = _P.invgstrapwidth,
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
    local nmosinvfillref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fwidth = _P.latchnfwidth,
        drawsourcedrain = "none",
        gtopext = _P.invgstrapwidth + _P.invgstrapspace / 2,
        cliptop = true,
        gbotext = (inputrowfingers == invnfingers) and _P.invinputsdspace + _P.sdwidth / 2,
    })
    local nmosinvendleftref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fwidth = _P.latchnfwidth,
        drawleftstopgate = true,
        drawsourcedrain = "none",
    })
    local nmosinvendrightref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fwidth = _P.latchnfwidth,
        drawrightstopgate = true,
        drawsourcedrain = "none",
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
    local pmosinvfillref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fwidth = _P.latchpfwidth,
        drawsourcedrain = "none",
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
    local pmosinvendleftref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fwidth = _P.latchpfwidth,
        drawleftstopgate = true,
        drawsourcedrain = "none",
    })
    local pmosinvendrightref = pcell.create_layout("basic/mosfet", {
        fingers = 0,
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fwidth = _P.latchpfwidth,
        drawrightstopgate = true,
        drawsourcedrain = "none",
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
    local clockfillname = pcell.add_cell_reference(clockfillref, "clockfill")
    local clockendleftname = pcell.add_cell_reference(clockendleftref, "clockendleft")
    local clockendrightname = pcell.add_cell_reference(clockendrightref, "clockendright")
    local inputdummyname = pcell.add_cell_reference(inputdummyref, "nmosinputdummy")
    local inputname = pcell.add_cell_reference(inputref, "nmosinput")
    local inputfillname = pcell.add_cell_reference(inputfillref, "inputfill")
    local inputendleftname = pcell.add_cell_reference(inputendleftref, "inputendleft")
    local inputendrightname = pcell.add_cell_reference(inputendrightref, "inputendright")
    local nmosdummyname = pcell.add_cell_reference(nmosdummyref, "nmosdummy")
    local nmosinvfillname = pcell.add_cell_reference(nmosinvfillref, "nmosinvfill")
    local nmosinvname = pcell.add_cell_reference(nmosinvref, "nmosinv")
    local nmosinvendleftname = pcell.add_cell_reference(nmosinvendleftref, "nmosinvendleft")
    local nmosinvendrightname = pcell.add_cell_reference(nmosinvendrightref, "nmosinvendright")
    local pmosdummyname = pcell.add_cell_reference(pmosdummyref, "pmosdummy")
    local pmosinvname = pcell.add_cell_reference(pmosinvref, "pmosinv")
    local pmosresetname = pcell.add_cell_reference(pmosresetref, "pmosreset")
    local pmosinvfillname = pcell.add_cell_reference(pmosinvfillref, "pmosinvfill")
    local pmosinvendleftname = pcell.add_cell_reference(pmosinvendleftref, "pmosinvendleft")
    local pmosinvendrightname = pcell.add_cell_reference(pmosinvendrightref, "pmosinvendright")

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

    -- fill up clock row
    local leftend, rightend
    if clockrowfingers < maxfingers then
        local lastanchor = clockleft:get_anchor("sourcedrainleftcc")
        -- left
        for i = 1, (maxfingers - clockrowfingers) / 2 do
            local clockfill = comparator:add_child(clockfillname)
            clockfill:move_anchor("sourcedrainrightcc", lastanchor)
            lastanchor = clockfill:get_anchor("sourcedrainleftcc")
        end
        leftend = lastanchor
        -- right
        lastanchor = clockright:get_anchor("sourcedrainrightcc")
        for i = 1, (maxfingers - clockrowfingers) / 2 do
            local clockfill = comparator:add_child(clockfillname)
            clockfill:move_anchor("sourcedrainleftcc", lastanchor)
            lastanchor = clockfill:get_anchor("sourcedrainrightcc")
        end
        rightend = lastanchor
    else -- no fill, but save anchors for end transistors
        leftend = clockleft:get_anchor("sourcedrainleftcc")
        rightend = clockright:get_anchor("sourcedrainrightcc")
    end
    local clockendleft = comparator:add_child(clockendleftname)
    clockendleft:move_anchor("sourcedrainrightcc", leftend)
    local clockendright = comparator:add_child(clockendrightname)
    clockendright:move_anchor("sourcedrainleftcc", rightend)

    -- fill up input row
    leftend = nil
    rightend = nil
    if inputrowfingers < maxfingers then
        -- left
        local lastanchor = inputleft:get_anchor("sourcedrainleftcc")
        for i = 1, (maxfingers - inputrowfingers) / 2 do
            local inputfill = comparator:add_child(inputfillname)
            inputfill:move_anchor("sourcedrainrightcc", lastanchor)
            lastanchor = inputfill:get_anchor("sourcedrainleftcc")
        end
        leftend = lastanchor
        -- right
        lastanchor = inputright:get_anchor("sourcedrainrightcc")
        for i = 1, (maxfingers - inputrowfingers) / 2 do
            local inputfill = comparator:add_child(inputfillname)
            inputfill:move_anchor("sourcedrainleftcc", lastanchor)
            lastanchor = inputfill:get_anchor("sourcedrainrightcc")
        end
        rightend = lastanchor
    else
        leftend = inputleft:get_anchor("sourcedrainleftcc")
        rightend = inputright:get_anchor("sourcedrainrightcc")
    end
    local inputendleft = comparator:add_child(inputendleftname)
    inputendleft:move_anchor("sourcedrainrightcc", leftend)
    local inputendright = comparator:add_child(inputendrightname)
    inputendright:move_anchor("sourcedrainleftcc", rightend)

    -- fill up nmos inv row
    leftend = nil
    rightend = nil
    if invnfingers < maxfingers then
        -- left
        local lastanchor = nmosinvleft:get_anchor("sourcedrainleftcc")
        for i = 1, (maxfingers - invnfingers) / 2 do
            local nmosinvfill = comparator:add_child(nmosinvfillname)
            nmosinvfill:move_anchor("sourcedrainrightcc", lastanchor)
            lastanchor = nmosinvfill:get_anchor("sourcedrainleftcc")
        end
        leftend = lastanchor
        -- right
        lastanchor = nmosinvright:get_anchor("sourcedrainrightcc")
        for i = 1, (maxfingers - invnfingers) / 2 do
            local nmosinvfill = comparator:add_child(nmosinvfillname)
            nmosinvfill:move_anchor("sourcedrainleftcc", lastanchor)
            lastanchor = nmosinvfill:get_anchor("sourcedrainrightcc")
        end
        rightend = lastanchor
    end
    if not leftend then
        leftend = nmosinvendleft:get_anchor("sourcedrainleftcc")
        rightend = nmosinvendright:get_anchor("sourcedrainrightcc")
    end
    local nmosinvendleft = comparator:add_child(nmosinvendleftname)
    nmosinvendleft:move_anchor("sourcedrainrightcc", leftend)
    local nmosinvendright = comparator:add_child(nmosinvendrightname)
    nmosinvendright:move_anchor("sourcedrainleftcc", rightend)

    -- fill up input row
    leftend = nil
    rightend = nil
    if invpfingers < maxfingers then
        -- left
        local lastanchor = pmosresetleft2:get_anchor("sourcedrainleftcc")
        for i = 1, (maxfingers - invpfingers) / 2 do
            local pmosinvfill = comparator:add_child(pmosinvfillname)
            pmosinvfill:move_anchor("sourcedrainrightcc", lastanchor)
            lastanchor = pmosinvfill:get_anchor("sourcedrainleftcc")
        end
        leftend = lastanchor
        -- right
        lastanchor = pmosresetright2:get_anchor("sourcedrainrightcc")
        for i = 1, (maxfingers - invpfingers) / 2 do
            local pmosinvfill = comparator:add_child(pmosinvfillname)
            pmosinvfill:move_anchor("sourcedrainleftcc", lastanchor)
            lastanchor = pmosinvfill:get_anchor("sourcedrainrightcc")
        end
        rightend = lastanchor
    end
    if not leftend then
        leftend = pmosresetleft2:get_anchor("sourcedrainleftcc")
        rightend = pmosresetright2:get_anchor("sourcedrainrightcc")
    end
    local pmosinvendleft = comparator:add_child(pmosinvendleftname)
    pmosinvendleft:move_anchor("sourcedrainrightcc", leftend)
    local pmosinvendright = comparator:add_child(pmosinvendrightname)
    pmosinvendright:move_anchor("sourcedrainleftcc", rightend)

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
