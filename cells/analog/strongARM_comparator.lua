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
        { "invskip", 200 },
        { "gstrwidth", tech.get_dimension("Minimum M1 Width") },
        { "sdwidth", tech.get_dimension("Minimum M1 Width") },
        { "powerwidth", 3 * tech.get_dimension("Minimum M1 Width") },
        { "powerspace", 2 * tech.get_dimension("Minimum M1 Space") }
    )
end

function layout(comparator, _P)
    local xpitch = _P.gatelength + _P.gatespace

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        topgateextendhalfspace = true,
        botgateextendhalfspace = true,
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
            botgatestrwidth = _P.powerwidth,
            botgatestrspace = _P.powerspace,
            gtopext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
            gbotext = _P.powerwidth + 2 * _P.powerspace,
            botgatecompsd = false,
            connectdrain = true,
            connectdraininverse = true,
            connectsource = true,
            connsourcewidth = _P.powerwidth,
            connsourcespace = _P.powerspace,
            conndrainwidth = _P.powerwidth,
            conndrainspace = _P.powerspace,
            extenddrainconnection = true,
            extendsourceconnection = true,
            extendimplantbot = 100,
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
        topgatestrwidth = _P.clockinputgatewidth,
        topgatestrspace = _P.clockinputgatespace,
        topgatecompsd = false,
        connectdrain = true,
        conndrainmetal = 2,
        conndrainwidth = _P.sdwidth,
        conndrainspace = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace,
        drawdrainvia = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        gtopext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
        gbotext = _P.powerwidth + 2 * _P.powerspace,
        extendimplantbot = 100,
    })
    local clockfillleftref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - clockrowfingers) / 2,
        fwidth = _P.clockfwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        conndrainwidth = _P.powerwidth,
        conndrainspace = _P.powerspace,
        extenddrainconnection = true,
        extendsourceconnection = true,
        drawbotgate = true,
        botgatestrspace = _P.powerspace,
        botgatestrwidth = _P.powerwidth,
        gtopext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
        botgatecompsd = false,
        drawleftstopgate = true,
        drawstopgatetopgcut = true,
        gbotext = _P.powerwidth + 2 * _P.powerspace,
        extendimplantbot = 100,
        leftpolylines = { { 40, 90 }, { 40, 90 } },
    })
    local clockfillrightref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - clockrowfingers) / 2,
        fwidth = _P.clockfwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        conndrainwidth = _P.powerwidth,
        conndrainspace = _P.powerspace,
        extenddrainconnection = true,
        extendsourceconnection = true,
        drawbotgate = true,
        botgatestrspace = _P.powerspace,
        botgatestrwidth = _P.powerwidth,
        gtopext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
        botgatecompsd = false,
        drawrightstopgate = true,
        drawstopgatetopgcut = true,
        gbotext = _P.powerwidth + 2 * _P.powerspace,
        extendimplantbot = 100,
        rightpolylines = { { 40, 90 }, { 40, 90 } },
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
        gbotext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
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
        botgatestrwidth = _P.clockinputgatewidth,
        botgatestrspace = _P.clockinputgatespace,
        connsourcespace = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace,
        connectdrain = true,
        conndrainwidth = _P.sdwidth,
        conndrainspace = _P.invinputsdspace,
        botgatecompsd = false,
        gtopext = _P.invinputsdspace + _P.sdwidth / 2,
        gbotext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
        drawtopgcut = true
    })
    local inputfillleftref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - inputrowfingers) / 2,
        fwidth = _P.inputfwidth,
        gbotext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
        gtopext = (inputrowfingers == invnfingers) and _P.invinputsdspace + _P.sdwidth / 2,
        drawleftstopgate = true,
        drawstopgatebotgcut = true,
        drawstopgatetopgcut = true,
        leftpolylines = { { 40, 90 }, { 40, 90 } },
    })
    local inputfillrightref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - inputrowfingers) / 2,
        fwidth = _P.inputfwidth,
        gbotext = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2,
        gtopext = (inputrowfingers == invnfingers) and _P.invinputsdspace + _P.sdwidth / 2,
        drawrightstopgate = true,
        drawstopgatebotgcut = true,
        drawstopgatetopgcut = true,
        rightpolylines = { { 40, 90 }, { 40, 90 } },
    })
    -- CMOS inverter
    local nmosdummyref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.invdummyfingers,
        fwidth = _P.latchnfwidth,
        gtopext = _P.invgstrapwidth + _P.invgstrapspace / 2 + _P.invskip,
        gbotext = _P.invinputsdspace + _P.sdwidth / 2,
        extendimplanttop = -_P.invskip,
        extendvthtop = -_P.invskip,
        drawtopgcut = true,
    })
    local nmosinvref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.invgstrapwidth,
        topgatestrspace = _P.invgstrapspace + _P.invskip,
        fingers = _P.latchfingers,
        fwidth = _P.latchnfwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = _P.sdwidth,
        connsourcespace = _P.invinputsdspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = -_P.invskip,
        extendvthtop = -_P.invskip,
        gbotext = _P.invinputsdspace + _P.sdwidth / 2,
        drawbotgcut = true
    })
    local nmosinvfillleftref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - invnfingers) / 2,
        fwidth = _P.latchnfwidth,
        gtopext = _P.invgstrapwidth + _P.invgstrapspace,
        cliptop = true,
        gbotext = (inputrowfingers == invnfingers) and _P.invinputsdspace + _P.sdwidth / 2,
        drawtopgcut = true,
        drawleftstopgate = true,
        drawstopgatebotgcut = true,
        drawstopgatetopgcut = true,
        leftpolylines = { { 40, 90 }, { 40, 90 } },
    })
    local nmosinvfillrightref = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - invnfingers) / 2,
        fwidth = _P.latchnfwidth,
        gtopext = _P.invgstrapwidth + _P.invgstrapspace,
        cliptop = true,
        gbotext = (inputrowfingers == invnfingers) and _P.invinputsdspace + _P.sdwidth / 2,
        drawtopgcut = true,
        drawrightstopgate = true,
        drawstopgatebotgcut = true,
        drawstopgatetopgcut = true,
        rightpolylines = { { 40, 90 }, { 40, 90 } },
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
        connsourcespace = _P.powerspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = -_P.invgstrapwidth + _P.invskip,
        extendvthbot = -_P.invgstrapwidth + _P.invskip,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100,
    })
    local pmosinvfillleftref = pcell.create_layout("basic/mosfet", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = (maxfingers - invpfingers) / 2,
        fwidth = _P.latchpfwidth,
        drawleftstopgate = true,
        drawstopgatebotgcut = true,
        gbotext = _P.invgstrapwidth + _P.invskip,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100,
        leftpolylines = { { 40, 90 }, { 40, 90 } },
    })
    local pmosinvfillrightref = pcell.create_layout("basic/mosfet", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = (maxfingers - invpfingers) / 2,
        fwidth = _P.latchpfwidth,
        drawrightstopgate = true,
        drawstopgatebotgcut = true,
        gbotext = _P.invgstrapwidth + _P.invskip,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100,
        rightpolylines = { { 40, 90 }, { 40, 90 } },
    })
    local pmosdummyref = pcell.create_layout("basic/mosfet", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = _P.invdummyfingers,
        fwidth = _P.latchpfwidth,
        clipbot = true,
        drawtopgate = true,
        topgatestrwidth = _P.powerwidth,
        topgatestrspace = _P.powerspace,
        topgatecompsd = false,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        conndrainwidth = _P.powerwidth,
        conndrainspace = _P.powerspace,
        extenddrainconnection = true,
        extendsourceconnection = true,
        drawbotgcut = true,
        gbotext = _P.invgstrapwidth + _P.invgstrapspace / 2,
        extendimplanttop = 100,
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
        connsourcespace = _P.powerspace,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        clipbot = true,
        gbotext = _P.invgstrapwidth + _P.invskip,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100,
    })
    pcell.pop_overwrites("basic/mosfet")

    local clockdummyname
    if _P.clockdummyfingers > 0 then
        clockdummyname = pcell.add_cell_reference(clockdummyref, "clockdummy")
    end
    local clockname = pcell.add_cell_reference(clockref, "clock")
    local clockfillleftname = pcell.add_cell_reference(clockfillleftref, "clockfillleft")
    local clockfillrightname = pcell.add_cell_reference(clockfillrightref, "clockfillright")
    local inputdummyname = pcell.add_cell_reference(inputdummyref, "nmosinputdummy")
    local inputname = pcell.add_cell_reference(inputref, "nmosinput")
    local inputfillleftname = pcell.add_cell_reference(inputfillleftref, "inputfillleft")
    local inputfillrightname = pcell.add_cell_reference(inputfillrightref, "inputfillright")
    local nmosdummyname = pcell.add_cell_reference(nmosdummyref, "nmosdummy")
    local nmosinvfillleftname = pcell.add_cell_reference(nmosinvfillleftref, "nmosinvleftfill")
    local nmosinvfillrightname = pcell.add_cell_reference(nmosinvfillrightref, "nmosinvrightfill")
    local nmosinvname = pcell.add_cell_reference(nmosinvref, "nmosinv")
    local pmosdummyname = pcell.add_cell_reference(pmosdummyref, "pmosdummy")
    local pmosinvname = pcell.add_cell_reference(pmosinvref, "pmosinv")
    local pmosresetname = pcell.add_cell_reference(pmosresetref, "pmosreset")
    local pmosinvfillleftname = pcell.add_cell_reference(pmosinvfillleftref, "pmosinvfillleft")
    local pmosinvfillrightname = pcell.add_cell_reference(pmosinvfillrightref, "pmosinvfillright")

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
    local clockfillleft = comparator:add_child(clockfillleftname)
    clockfillleft:move_anchor("sourcedrainrightcc", clockleft:get_anchor("sourcedrainleftcc"))
    local clockfillright = comparator:add_child(clockfillrightname)
    clockfillright:move_anchor("sourcedrainleftcc", clockright:get_anchor("sourcedrainrightcc"))

    -- fill up input row
    local inputfillleft = comparator:add_child(inputfillleftname)
    inputfillleft:move_anchor("sourcedrainrightcc", inputleft:get_anchor("sourcedrainleftcc"))
    local inputfillright = comparator:add_child(inputfillrightname)
    inputfillright:move_anchor("sourcedrainleftcc", inputright:get_anchor("sourcedrainrightcc"))

    -- fill up nmos inv row
    local nmosinvfillleft = comparator:add_child(nmosinvfillleftname)
    nmosinvfillleft:move_anchor("sourcedrainrightcc", nmosinvleft:get_anchor("sourcedrainleftcc"))
    local nmosinvfillright = comparator:add_child(nmosinvfillrightname)
    nmosinvfillright:move_anchor("sourcedrainleftcc", nmosinvright:get_anchor("sourcedrainrightcc"))

    -- fill up input row
    local pmosinvfillleft = comparator:add_child(pmosinvfillleftname)
    pmosinvfillleft:move_anchor("sourcedrainrightcc", pmosresetleft2:get_anchor("sourcedrainleftcc"))
    local pmosinvfillright = comparator:add_child(pmosinvfillrightname)
    pmosinvfillright:move_anchor("sourcedrainleftcc", pmosresetright2:get_anchor("sourcedrainrightcc"))

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
    geometry.path(comparator, generics.metal(2), geometry.path_points_xy(
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", _P.latchfingers)), {
            (_P.invdummyfingers + 1) * xpitch,
            nmosinvright:get_anchor("topgatestrapcr"),
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(2), geometry.path_points_xy(
        nmosinvright:get_anchor("sourcedrain2cc"), {
            -(_P.invdummyfingers + 1) * xpitch,
            nmosinvleft:get_anchor("topgatestrapcl"),
    }), _P.sdwidth)
    geometry.viabltr(comparator, 1, 2,
        nmosinvleft:get_anchor("topgatestrapll"),
        nmosinvleft:get_anchor("topgatestrapur")
    )
    geometry.viabltr(comparator, 1, 2,
        nmosinvright:get_anchor("topgatestrapll"),
        nmosinvright:get_anchor("topgatestrapur")
    )

    -- connect latch drains
    geometry.path(comparator, generics.metal(2), {
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)),
        pmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)):translate(-2 * xpitch, 0),
        nmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)):translate(-2 * xpitch, 0),
        nmosinvleft:get_anchor(string.format("sourcedrain%dcc", 2)),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(2), {
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
            0,
            -500,
            clockleft:get_anchor("topgatestrapcc")
    }), _P.sdwidth)
    geometry.path(comparator, generics.metal(1),
        geometry.path_points_yx(pmosresetright2:get_anchor("botgatestrapcc"), {
            0,
            500,
            clockright:get_anchor("topgatestrapcc")
    }), _P.sdwidth)

    -- connect input row fill dummies
    geometry.path(comparator, generics.metal(1), {
        inputfillleft:get_anchor("sourcedrainleftcc"),
        inputfillleft:get_anchor(string.format("sourcedrain%dcc", (maxfingers - inputrowfingers) / 2)),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(1), {
        inputfillright:get_anchor(string.format("sourcedrain%dcc", 2)),
        inputfillright:get_anchor("sourcedrainrightcc"),
    }, _P.sdwidth)

    -- connect nmos inverter row fill dummies
    geometry.path(comparator, generics.metal(1), {
        nmosinvfillleft:get_anchor("sourcedrainleftcc"),
        nmosinvfillleft:get_anchor(string.format("sourcedrain%dcc", (maxfingers - invnfingers) / 2)),
    }, _P.sdwidth)
    geometry.path(comparator, generics.metal(1), {
        nmosinvfillright:get_anchor(string.format("sourcedrain%dcc", 2)),
        nmosinvfillright:get_anchor("sourcedrainrightcc"),
    }, _P.sdwidth)

    -- add ports
    comparator:add_port("clk", generics.metalport(1), point.combine(clockleft:get_anchor("topgatestrapcc"), clockright:get_anchor("topgatestrapcc")))
    comparator:add_port("vinp", generics.metalport(1), inputleft:get_anchor("botgatestrapcc"))
    comparator:add_port("vinn", generics.metalport(1), inputright:get_anchor("botgatestrapcc"))
    comparator:add_port("vss", generics.metalport(1), clockdummy:get_anchor("sourcestrapcc"))
    comparator:add_port("vdd", generics.metalport(1), pmosdummy:get_anchor("sourcestrapcc"))
end
