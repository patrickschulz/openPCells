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

-- FIXME: add option for pmos input
function parameters()
    pcell.add_parameters(
        { "drawoutputlatch", true },
        { "drawoutputbuffer", true, follow = "drawoutputlatch" },
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "pfetvthtype", 1 },
        { "nfetvthtype", 1 },
        { "pfetflippedwell", false },
        { "nfetflippedwell", false },
        { "clockfingers", 4 },
        { "clockdummyfingers", 1 },
        { "clockfwidth", technology.get_dimension("Minimum Gate Width") },
        { "clockinputgatewidth", technology.get_dimension("Minimum M1 Width") },
        { "clockinputgatespace", technology.get_dimension("Minimum M1 Space") },
        { "inputfingers", 2 },
        { "inputfwidth", technology.get_dimension("Minimum Gate Width") },
        { "inputdummyfingers", 1 },
        { "latchfingers", 2 },
        { "latchnfwidth", technology.get_dimension("Minimum Gate Width") },
        { "latchpfwidth", technology.get_dimension("Minimum Gate Width") },
        { "latchcrossingoffset", 0 },
        { "latchgatewidth", technology.get_dimension("Minimum M1 Width") },
        { "latchgatespace", technology.get_dimension("Minimum M1 Space") },
        { "invdummyfingers", 1 },
        { "resetfingers", 2 },
        { "inputclocksdspace", technology.get_dimension("Minimum M1 Space") },
        { "invgstrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "invskip", 200 },
        { "resetgatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "resetgatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "bufferfingers", 2 },
        { "rslatchfingers", 2 },
        { "buffernfwidth", technology.get_dimension("Minimum Gate Width") },
        { "bufferpfwidth", technology.get_dimension("Minimum Gate Width") },
        { "rslatchnfwidth", technology.get_dimension("Minimum Gate Width") },
        { "rslatchpfwidth", technology.get_dimension("Minimum Gate Width") },
        { "gstrwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerwidth", 3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace", 2 * technology.get_dimension("Minimum M1 Space") },
        { "gatecutwidth", 60 },
        { "outerdummyfingers", 0 },
        { "connectdummiesinline", false }
    )
end

function check(_P)
    if _P.drawoutputlatch and not _P.drawoutputbuffer then
        return nil, "'drawoutputbuffer' must be true when 'drawoutputlatch' is true"
    end
    if not ((_P.clockdummyfingers % 2) == (_P.inputdummyfingers % 2) and (_P.inputdummyfingers % 2) == (_P.invdummyfingers % 2)) then
        return nil, "all dummy fingers must be either even or odd, mixtures are not possible"
    end
    return true
end

function layout(comparator, _P)
    local xpitch = _P.gatelength + _P.gatespace
    local separation = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace + _P.sdwidth / 2

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        topgateextendhalfspace = true,
        botgateextendhalfspace = true,
        actext = 100,
        gtopext = separation,
        gbotext = separation,
        topgcutwidth = _P.gatecutwidth,
        topgcutspace = separation - _P.gatecutwidth / 2,
        botgcutwidth = _P.gatecutwidth,
        botgcutspace = separation - _P.gatecutwidth / 2,
    })

    -- create transistor layouts
    local clockrowfingers = _P.clockfingers + _P.clockdummyfingers
    local inputrowfingers = 2 * _P.inputfingers + _P.inputdummyfingers
    local invnfingers = 2 * _P.latchfingers + _P.invdummyfingers
    if _P.drawoutputbuffer then
        invnfingers = invnfingers + 4 * _P.resetfingers + 2 * _P.bufferfingers
    end
    if _P.drawoutputlatch then
        invnfingers = invnfingers + 4 * _P.rslatchfingers
    end
    local invpfingers = 2 * _P.latchfingers + 4 * _P.resetfingers + _P.invdummyfingers
    if _P.drawoutputbuffer then
        invpfingers = invpfingers + 2 * _P.bufferfingers
    end
    if _P.drawoutputlatch then
        invpfingers = invpfingers + 4 * _P.rslatchfingers
    end
    -- FIXME: due to errors in basic/mosfet, currently there has to be at least one (1) dummy left and right
    local maxfingers = math.max(clockrowfingers, inputrowfingers, invnfingers, invpfingers) + 2 + 2 * _P.outerdummyfingers
    -- clock tail dummy transistor (split actual clock transistor in two, left and right)
    -- this is not needed, maybe I will get rid of this at some point
    -- the transistor in the middle can be used to equalize the width regarding the input transistors
    local clockdummyref
    if _P.clockdummyfingers > 0 then
        clockdummyref = pcell.create_layout("basic/mosfet", "clockdummy", {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            fingers = _P.clockdummyfingers,
            fwidth = _P.clockfwidth,
            drawbotgate = true,
            botgatestrwidth = _P.powerwidth,
            botgatestrspace = _P.powerspace,
            botgatestrapextendleft = (_P.gatespace - _P.sdwidth) / 2,
            botgatestrapextendright = (_P.gatespace - _P.sdwidth) / 2,
            connectdrain = true,
            connectdraininverse = true,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            connectdrainwidth = _P.powerwidth,
            connectdrainspace = _P.powerspace,
            extendimplantbot = 100,
            gbotext = 2 * _P.powerspace + _P.powerwidth,
        })
    end
    -- clock tail transistor
    local clock = pcell.create_layout("basic/mosfet", "clock", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.clockfingers / 2,
        fwidth = _P.clockfwidth,
        drawtopgate = true,
        topgatestrwidth = _P.clockinputgatewidth,
        topgatestrspace = _P.clockinputgatespace,
        connectdrain = true,
        connectdrainmetal = 2,
        connectdrainwidth = _P.sdwidth,
        connectdrainspace = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace,
        drawdrainvia = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        drawtopgcut = true,
        extendimplantbot = 100,
        gbotext = 2 * _P.powerspace + _P.powerwidth,
    })
    local clockfill = pcell.create_layout("basic/mosfet", "clockfill", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - clockrowfingers) / 2,
        fwidth = _P.clockfwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        extenddrainstrapleft = (_P.gatelength + _P.gatespace) / 2,
        extenddrainstrapright = (_P.gatelength + _P.gatespace) / 2,
        extendsourcestrapleft = (_P.gatelength + _P.gatespace) / 2,
        extendsourcestrapright = (_P.gatelength + _P.gatespace) / 2,
        drawbotgate = true,
        botgatestrspace = _P.powerspace,
        botgatestrwidth = _P.powerwidth,
        drawleftstopgate = true,
        drawstopgatetopgcut = true,
        extendimplantbot = 100,
        leftpolylines = { { length = 40, space = 90 }, { length = 40, space = 90 } },
        gbotext = 2 * _P.powerspace + _P.powerwidth,
    })
    -- input transistors
    local inputdummy = pcell.create_layout("basic/mosfet", "inputdummy", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.inputdummyfingers,
        fwidth = _P.inputfwidth,
    })
    local input = pcell.create_layout("basic/mosfet", "input", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.inputfingers,
        fwidth = _P.inputfwidth,
        connectsource = true,
        connectsourcemetal = 2,
        drawsourcevia = true,
        drawbotgate = true,
        botgatestrwidth = _P.clockinputgatewidth,
        botgatestrspace = _P.clockinputgatespace,
        connectsourcewidth = _P.sdwidth,
        connectsourcespace = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace,
        connectdrain = true,
        connectdrainwidth = _P.sdwidth,
        connectdrainspace = separation - _P.sdwidth / 2,
        drawtopgcut = true
    })
    local inputfill = pcell.create_layout("basic/mosfet", "inputfill", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - inputrowfingers) / 2,
        fwidth = _P.inputfwidth,
        drawleftstopgate = true,
        drawstopgatebotgcut = true,
        drawstopgatetopgcut = true,
        leftpolylines = { { length = 40, space = 90 }, { length = 40, space = 90 } },
        drawextrabotstrap = not _P.connectdummiesinline,
        extrabotstrapwidth = _P.sdwidth,
        extrabotstrapspace = _P.clockinputgatespace,
        extrabotstraprightalign = (maxfingers - inputrowfingers) / 2,
    })
    -- CMOS inverter
    local nmosdummy = pcell.create_layout("basic/mosfet", "nmosdummy", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.invdummyfingers,
        fwidth = _P.latchnfwidth,
        extendimplanttop = -_P.invskip,
        extendvthtop = -_P.invskip,
        drawtopgcut = true,
    })
    local nmosinv = pcell.create_layout("basic/mosfet", "nmosinv", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.invgstrapwidth,
        topgatestrspace = separation - _P.invgstrapwidth / 2,
        fingers = _P.latchfingers,
        fwidth = _P.latchnfwidth,
        connectsource = true,
        connectsourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = _P.sdwidth,
        connectsourcespace = separation - _P.sdwidth / 2,
        connectdrain = true,
        connectdrainmetal = 2,
        drawdrainvia = true,
        --connectdraininline = true,
        --connectdraininlineoffset = (_P.latchnfwidth - _P.sdwidth) // 2,
        connectdrainwidth = _P.invgstrapwidth,
        connectdrainspace = _P.latchgatespace,
        extendimplanttop = -_P.invgstrapwidth / 2,
        extendvthtop = -_P.invgstrapwidth / 2,
        drawbotgcut = true
    })
    local nmosinvfill = pcell.create_layout("basic/mosfet", "nmosinvfill", {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - invnfingers) / 2,
        fwidth = _P.latchnfwidth,
        cliptop = true,
        drawtopgcut = true,
        drawleftstopgate = true,
        drawstopgatebotgcut = true,
        drawstopgatetopgcut = true,
        leftpolylines = { { length = 40, space = 90 }, { length = 40, space = 90 } },
        drawextrabotstrap = not _P.connectdummiesinline,
        extrabotstrapwidth = _P.sdwidth,
        extrabotstrapspace = _P.clockinputgatespace,
        extrabotstraprightalign = (maxfingers - invnfingers) / 2,
    })
    local pmosinv = pcell.create_layout("basic/mosfet", "pmosinv", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = _P.latchfingers,
        fwidth = _P.latchpfwidth,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        connectdrainmetal = 2,
        drawdrainvia = true,
        --connectdraininline = true,
        --connectdraininlineoffset = (_P.latchnfwidth - _P.sdwidth) // 2,
        connectdrainwidth = _P.invgstrapwidth,
        connectdrainspace = _P.latchgatespace,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100,
    })
    local pmosinvfill = pcell.create_layout("basic/mosfet", "pmosinvfill", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = (maxfingers - invpfingers) / 2,
        fwidth = _P.latchpfwidth,
        drawleftstopgate = true,
        drawstopgatebotgcut = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100,
        leftpolylines = { { length = 40, space = 90 }, { length = 40, space = 90 } },
    })

    local pmosdummy = pcell.create_layout("basic/mosfet", "pmosdummy", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = _P.invdummyfingers,
        fwidth = _P.latchpfwidth,
        drawtopgate = true,
        topgatestrwidth = _P.powerwidth,
        topgatestrspace = _P.powerspace,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        extenddrainstrapleft = (_P.gatelength + _P.gatespace) / 2,
        extenddrainstrapright = (_P.gatelength + _P.gatespace) / 2,
        extendsourcestrapleft = (_P.gatelength + _P.gatespace) / 2,
        extendsourcestrapright = (_P.gatelength + _P.gatespace) / 2,
        drawbotgcut = true,
        extendimplanttop = 100,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
    })
    -- reset switches
    local pmosresetref = pcell.create_layout("basic/mosfet", "pmosresetref", {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.resetgatestrapwidth,
        botgatestrspace = _P.resetgatestrapspace,
        fingers = _P.resetfingers,
        fwidth = _P.latchpfwidth,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        connectdrainmetal = 2,
        drawdrainvia = true,
        connectdraininline = false,
        connectdraininlineoffset = (_P.latchpfwidth - _P.sdwidth) // 2,
        clipbot = true,
        extendimplanttop = 100,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
    })

    local pmosbuf
    local nmosbufspacer
    local nmosbuf
    if _P.drawoutputbuffer then
        nmosbufspacer = pcell.create_layout("basic/mosfet", "nmosbufspacer", {
            fingers = 2 * _P.resetfingers,
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            fwidth = _P.latchnfwidth,
        })
        nmosbuf = pcell.create_layout("basic/mosfet", "nmosbuf", {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            drawtopgate = true,
            topgatestrwidth = _P.invgstrapwidth,
            topgatestrspace = _P.latchgatespace,
            fingers = _P.bufferfingers,
            fwidth = _P.latchnfwidth,
            sourcesize = _P.latchnfwidth / 2,
            drainsize = _P.latchpfwidth / 2,
            connectsource = true,
            connectsourcemetal = 1,
            drawsourcevia = true,
            connectsourcewidth = _P.sdwidth,
            connectsourcespace = _P.clockinputgatespace,
            drawdrainvia = true,
            connectdraininline = true,
            drawbotgcut = true
        })
        pmosbuf = pcell.create_layout("basic/mosfet", "pmosbuf", {
            channeltype = "pmos",
            flippedwell = _P.pfetflippedwell,
            vthtype = _P.pfetvthtype,
            fingers = _P.bufferfingers,
            fwidth = _P.latchpfwidth,
            sourcesize = _P.latchpfwidth / 2,
            sourcealign = "top",
            drainsize = _P.latchpfwidth / 2,
            drainalign = "bottom",
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            drawdrainvia = true,
            gtopext = 2 * _P.powerspace + _P.powerwidth,
            extendimplanttop = 100,
        })
    end

    local nmosrslatch1
    local pmosrslatch1
    if _P.drawoutputlatch then
        nmosrslatch1 = pcell.create_layout("basic/mosfet", "nmosrslatch", {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            drawtopgate = true,
            topgatestrwidth = _P.invgstrapwidth,
            topgatestrspace = _P.latchgatespace,
            fingers = _P.rslatchfingers,
            fwidth = _P.latchnfwidth,
            sourcesize = _P.latchnfwidth / 2,
            drainsize = _P.latchpfwidth / 2,
            connectsource = true,
            connectsourcemetal = 1,
            drawsourcevia = true,
            connectsourcewidth = _P.sdwidth,
            connectsourcespace = _P.clockinputgatespace,
            drawdrainvia = true,
            drawbotgcut = true
        })
        pmosrslatch1 = pcell.create_layout("basic/mosfet", "pmosrslatch", {
            channeltype = "pmos",
            flippedwell = _P.pfetflippedwell,
            vthtype = _P.pfetvthtype,
            fingers = _P.rslatchfingers,
            fwidth = _P.latchpfwidth,
            sourcesize = _P.latchpfwidth / 2,
            sourcealign = "top",
            drainsize = _P.latchpfwidth / 2,
            drainalign = "bottom",
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            drawdrainvia = true,
            gtopext = 2 * _P.powerspace + _P.powerwidth,
            extendimplanttop = 100,
        })
    end

    pcell.pop_overwrites("basic/mosfet")

    local halfref = object.create("half")

    -- place clock row
    local clockdummy
    if _P.clockdummyfingers > 0 then
        clockdummy = clockdummyref
        halfref:merge_into(clockdummy)
        clock:align_right(clockdummy)
        halfref:merge_into(clock)
    else -- FIXME: this is currently broken
        halfref:merge_into(clock)
    end
    local pmosreset1 = pmosresetref:copy()
    local pmosreset2 = pmosresetref:copy()

    -- place input row
    if _P.clockdummyfingers % 2 == 0 then
        inputdummy:abut_area_anchor_top(
            string.format("gate%d", _P.inputdummyfingers / 2),
            clockdummy,
            string.format("gate%d", _P.clockdummyfingers / 2)
        )
    else
        inputdummy:abut_area_anchor_top(
            string.format("gate%d", (_P.inputdummyfingers + 1) / 2),
            clockdummy,
            string.format("gate%d", (_P.inputdummyfingers + 1) / 2)
        )
    end
    input:align_area_anchor_left("sourcedrainright", inputdummy, "sourcedrainleft")
    input:align_area_anchor_top("gate1", inputdummy, "gate1")
    halfref:merge_into(inputdummy)
    halfref:merge_into(input)

    -- place nmos inverter row
    if _P.inputdummyfingers % 2 == 0 then
        nmosdummy:abut_area_anchor_top(
            string.format("gate%d", _P.invdummyfingers / 2),
            inputdummy,
            string.format("gate%d", _P.inputdummyfingers / 2)
        )
    else
        nmosdummy:abut_area_anchor_top(
            string.format("gate%d", (_P.invdummyfingers + 1) / 2),
            inputdummy,
            string.format("gate%d", (_P.inputdummyfingers + 1) / 2)
        )
    end
    nmosinv:align_area_anchor_left("sourcedrainright", nmosdummy, "sourcedrainleft")
    nmosinv:align_area_anchor_top("gate1", nmosdummy, "gate1")
    halfref:merge_into(nmosdummy)
    halfref:merge_into(nmosinv)

    -- place pmos inverter + reset row
    pmosinv:abut_area_anchor_top("gate1", nmosinv, "gate1")
    pmosinv:align_area_anchor_left("gate1", nmosinv, "gate1")
    pmosinv:translate(0, -_P.invgstrapwidth / 2) -- compensate for displacement due to gate strap (FIXME: should be fixed in basic/mosfet?)
    pmosdummy:align_area_anchor("sourcedrainleft", pmosinv, "sourcedrainright")
    pmosreset1:align_area_anchor("sourcedrainright", pmosinv, "sourcedrainleft")
    pmosreset2:align_area_anchor("sourcedrainright", pmosreset1, "sourcedrainleft")
    halfref:merge_into(pmosdummy)
    halfref:merge_into(pmosinv)
    halfref:merge_into(pmosreset1)
    halfref:merge_into(pmosreset2)

    -- place nmos buffer + latch
    if _P.drawoutputbuffer then
        nmosbufspacer:align_area_anchor("sourcedrainright", nmosinv, "sourcedrainleft")
        halfref:merge_into(nmosbufspacer)
        nmosbuf:align_area_anchor("sourcedrainright", nmosbufspacer, "sourcedrainleft")
        halfref:merge_into(nmosbuf)
        nmosrslatch1:align_area_anchor("sourcedrainright", nmosbuf, "sourcedrainleft")
    end
    if _P.drawoutputlatch then
        halfref:merge_into(nmosrslatch1)
        local nmosrslatch2 = nmosrslatch1:copy()
        nmosrslatch2:align_area_anchor("sourcedrainright", nmosrslatch2, "sourcedrainleft")
        halfref:merge_into(nmosrslatch2)
    end

    -- place pmos buffer + latch
    if _P.drawoutputbuffer then
        pmosbuf:align_area_anchor("sourcedrainright", pmosreset2, "sourcedrainleft")
        halfref:merge_into(pmosbuf)
        pmosrslatch1:align_area_anchor("sourcedrainright", pmosbuf, "sourcedrainleft")
    end
    if _P.drawoutputlatch then
        halfref:merge_into(pmosrslatch1)
        pmosrslatch2 = pmosrslatch1:copy()
        pmosrslatch2:align_area_anchor("sourcedrainright", pmosrslatch2, "sourcedrainleft")
        halfref:merge_into(pmosrslatch2)
    end

    -- fill up clock row
    clockfill:align_area_anchor("sourcedrainright", clock, "sourcedrainleft")
    halfref:merge_into(clockfill)

    -- fill up input row
    inputfill:align_area_anchor("sourcedrainright", input, "sourcedrainleft")
    halfref:merge_into(inputfill)

    -- fill up nmos inv row
    if _P.drawoutputlatch then
        nmosinvfill:align_area_anchor("sourcedrainright", nmosrslatch2, "sourcedrainleft")
    elseif _P.drawoutputbuffer then
        nmosinvfill:align_area_anchor("sourcedrainright", nmosbuf, "sourcedrainleft")
    else
        nmosinvfill:align_area_anchor("sourcedrainright", nmosinv, "sourcedrainleft")
    end
    halfref:merge_into(nmosinvfill)

    -- fill up input row
    if _P.drawoutputlatch then
        pmosinvfill:align_area_anchor("sourcedrainright", pmosrslatch2, "sourcedrainleft")
    elseif _P.drawoutputbuffer then
        pmosinvfill:align_area_anchor("sourcedrainright", pmosbuf, "sourcedrainleft")
    else
        pmosinvfill:align_area_anchor("sourcedrainright", pmosreset2, "sourcedrainleft")
    end
    halfref:merge_into(pmosinvfill)

    -- connect reset gates
    geometry.rectanglebltr(halfref, generics.metal(1),
        pmosreset2:get_area_anchor("botgatestrap").bl,
        pmosreset1:get_area_anchor("botgatestrap").tr
    )

    -- connect latch drains and inner reset transistors
    geometry.polygon(halfref, generics.metal(2), {
        pmosinv:get_area_anchor("drainstrap").tl,
        (pmosreset1:get_area_anchor("drainstrap").br .. pmosinv:get_area_anchor("drainstrap").tr):translate(-_P.sdwidth, 0),
        (pmosreset1:get_area_anchor("drainstrap").br .. nmosinv:get_area_anchor("drainstrap").br):translate(-_P.sdwidth, 0),
        nmosinv:get_area_anchor("drainstrap").bl,
        nmosinv:get_area_anchor("drainstrap").tl,
        pmosreset1:get_area_anchor("drainstrap").br .. nmosinv:get_area_anchor("drainstrap").tl,
        pmosreset1:get_area_anchor("drainstrap").br .. pmosinv:get_area_anchor("drainstrap").bl,
        pmosinv:get_area_anchor("drainstrap").bl,
    })

    -- connect outer reset transistors
    geometry.polygon(halfref, generics.metal(2), {
        nmosinv:get_area_anchor("sourcestrap").tl,
        pmosreset2:get_area_anchor(string.format("sourcedrain%d", _P.resetfingers)).br .. nmosinv:get_area_anchor("sourcestrap").tl,
        pmosreset2:get_area_anchor(string.format("sourcedrain%d", _P.resetfingers)).br,
        pmosreset2:get_area_anchor(string.format("sourcedrain%d", _P.resetfingers)).bl,
        pmosreset2:get_area_anchor(string.format("sourcedrain%d", _P.resetfingers)).bl .. nmosinv:get_area_anchor("sourcestrap").bl,
        nmosinv:get_area_anchor("sourcestrap").bl
    })
    geometry.viabltr(halfref, 1, 2,
        nmosinv:get_area_anchor("sourcestrap").bl,
        nmosinv:get_area_anchor("sourcestrap").tr
    )

    -- connect clock gates (symmetric part)
    geometry.polygon(halfref, generics.metal(2), {
        pmosreset2:get_area_anchor("botgatestrap").tl,
        pmosreset2:get_area_anchor("botgatestrap").tl:translate(-500, 0),
        pmosreset2:get_area_anchor("botgatestrap").tl:translate(-500, 0) .. clock:get_area_anchor("topgatestrap").bl,
        clock:get_area_anchor("topgatestrap").bl,
        clock:get_area_anchor("topgatestrap").tl,
        pmosreset2:get_area_anchor("botgatestrap").tl:translate(-500 + _P.sdwidth, 0) .. clock:get_area_anchor("topgatestrap").tl,
        pmosreset2:get_area_anchor("botgatestrap").bl:translate(-500 + _P.sdwidth, 0),
        pmosreset2:get_area_anchor("botgatestrap").bl
    })

    -- connect input row fill dummies
    -- 'shortdevice' can't be used on these as the inner source is shared with the input transistors
    if _P.connectdummiesinline then
        geometry.rectanglebltr(halfref, generics.metal(1),
            inputfill:get_area_anchor("sourcedrainleft").br,
            inputfill:get_area_anchor(string.format("sourcedrain%d", (maxfingers - inputrowfingers) / 2)).bl:translate(0, _P.sdwidth)
        )
    else
        for i = 1, (maxfingers - inputrowfingers) / 2 do
            geometry.rectanglebltr(halfref, generics.metal(1),
                inputfill:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate(0, -_P.clockinputgatespace),
                inputfill:get_area_anchor(string.format("sourcedrain%d", i)).br
            )
        end
    end

    -- connect nmos inverter row fill dummies
    -- 'shortdevice' can't be used on these as the inner source is shared with the inverter transistors
    if _P.connectdummiesinline then
        geometry.rectanglebltr(halfref, generics.metal(1),
            nmosinvfill:get_area_anchor("sourcedrainleft").br,
            nmosinvfill:get_area_anchor(string.format("sourcedrain%d", (maxfingers - invnfingers) / 2)).bl:translate(0, _P.sdwidth)
        )
    else
        for i = 1, (maxfingers - invnfingers) / 2 do
            geometry.rectanglebltr(halfref, generics.metal(1),
                nmosinvfill:get_area_anchor(string.format("sourcedrain%d", i)).bl:translate(0, -_P.clockinputgatespace),
                nmosinvfill:get_area_anchor(string.format("sourcedrain%d", i)).br
            )
        end
    end

    geometry.viabltr(halfref, 1, 2,
        nmosinv:get_area_anchor("topgatestrap").bl,
        nmosinv:get_area_anchor("topgatestrap").tr
    )

    ------------------
    -- connect comparator to buffer
    if _P.drawoutputbuffer then
        geometry.viabltr(halfref, 1, 2,
            nmosbuf:get_area_anchor("topgatestrap").bl,
            nmosbuf:get_area_anchor("topgatestrap").tr
        )
        --geometry.path(comparator, generics.metal(2), {
        --    pmosbuf1left:get_anchor("botgatestrapbr"),
        --    point.combine_12(pmosbuf1left:get_anchor("botgatestrapbr"), pmosresetleft1:get_anchor("sourcedrain2tc"):translate(0, 2 * _P.sdwidth)),
        --    pmosresetleft1:get_anchor("sourcedrain2tc"):translate(0, 2 * _P.sdwidth),
        --    pmosresetleft1:get_anchor("sourcedrain2tc")
        --},  _P.sdwidth)
    end

    -- connect buffer to output latch
    if _P.drawoutputlatch then
        geometry.path_cshape(halfref, generics.metal(1),
            pmosbuf:get_area_anchor(string.format("sourcedrain%d", 2)).br:translate(0, _P.sdwidth / 2),
            nmosbuf:get_area_anchor(string.format("sourcedrain%d", 2)).tr:translate(0, -_P.sdwidth / 2),
            nmosrslatch1:get_area_anchor("topgate2").br,
        _P.sdwidth)
    end

    -- connect output latch nets
    if _P.drawoutputlatch then
        geometry.rectanglebltr(halfref, generics.metal(1),
            pmosrslatch2:get_area_anchor("sourcedrain2").br,
            pmosrslatch1:get_area_anchor("sourcedrain2").bl:translate(0, _P.sdwidth)
        )
        --geometry.path(comparator, generics.metal(1),{
        --    nmosrslatch1:get_area_anchor(string.format("sourcedrain%d", 2)).cc,
        --    nmosrslatch1:get_area_anchor(string.format("sourcedrain%d", 2)).cc:translate( -2 * xpitch, 0),
        --    nmosrslatch2:get_area_anchor(string.format("sourcedrain%d", _P.rslatchfingers + 1)).tc
        --}, _P.sdwidth)
        geometry.path_cshape(comparator, generics.metal(1),
            pmosrslatch2:get_area_anchor("sourcedrain2").br:translate(0, _P.sdwidth / 2),
            nmosrslatch2:get_area_anchor("sourcedrain2").tr:translate(0, -_P.sdwidth / 2),
            nmosrslatch2:get_area_anchor("sourcedrain2").tl:translate(-2 * _P.gatespace, 0),
        _P.sdwidth)
    end
    ------------------

    -- copy needed anchors
    halfref:add_anchor_area_bltr("clock", clock:get_area_anchor("topgatestrap").bl, clock:get_area_anchor("topgatestrap").tr)
    halfref:add_anchor("vin", input:get_area_anchor("botgatestrap").bl)
    halfref:add_anchor_area_bltr("vtail", input:get_area_anchor("sourcestrap").bl, input:get_area_anchor("sourcestrap").tr)
    halfref:add_anchor_area_bltr("vss", clockfill:get_area_anchor("sourcestrap").bl, clockfill:get_area_anchor("sourcestrap").tr)
    halfref:add_anchor_area_bltr("vdd", pmosinvfill:get_area_anchor("sourcestrap").bl, pmosinvfill:get_area_anchor("sourcestrap").tr)
    halfref:add_anchor_area_bltr("invgate", nmosinv:get_area_anchor("topgatestrap").bl, nmosinv:get_area_anchor("topgatestrap").tr)
    halfref:add_anchor_area_bltr("invpdrain", pmosinv:get_area_anchor("drainstrap").bl, pmosinv:get_area_anchor("drainstrap").tr)
    halfref:add_anchor_area_bltr("invndrain", nmosinv:get_area_anchor("drainstrap").bl, nmosinv:get_area_anchor("drainstrap").tr)

    -- place left and right comparator half
    halfref:inherit_alignment_box(clockdummy) -- align at clock dummy
    local lefthalf = comparator:add_child(halfref, "lefthalf")
    local righthalf = comparator:add_child(halfref, "righthalf")
    righthalf:mirror_at_yaxis()
    righthalf:abut_right(lefthalf)
    -- compensate for center dummies
    righthalf:translate(-_P.clockdummyfingers * xpitch, 0)

    -- connect vtail
    geometry.rectanglebltr(comparator, generics.metal(2),
        lefthalf:get_area_anchor("vtail").br,
        righthalf:get_area_anchor("vtail").tl
    )

    -- connect latch gates
    geometry.polygon(comparator, generics.metal(2), {
        righthalf:get_area_anchor("invgate").tl,
        righthalf:get_area_anchor("invgate").tl:translate(-_P.latchcrossingoffset, 0),
        (righthalf:get_area_anchor("invgate").tl .. lefthalf:get_area_anchor("invpdrain").tr):translate(-_P.latchcrossingoffset, 0),
        lefthalf:get_area_anchor("invpdrain").tr,
        lefthalf:get_area_anchor("invpdrain").br,
        (righthalf:get_area_anchor("invgate").bl .. lefthalf:get_area_anchor("invpdrain").br):translate(-_P.latchcrossingoffset - _P.sdwidth, 0),
        righthalf:get_area_anchor("invgate").bl:translate(-_P.latchcrossingoffset - _P.sdwidth, 0),
        righthalf:get_area_anchor("invgate").bl,
    })
    geometry.polygon(comparator, generics.metal(2), {
        lefthalf:get_area_anchor("invgate").tr,
        lefthalf:get_area_anchor("invgate").tr:translate(_P.latchcrossingoffset + _P.sdwidth, 0),
        (lefthalf:get_area_anchor("invgate").tr .. righthalf:get_area_anchor("invndrain").tl):translate(_P.latchcrossingoffset + _P.sdwidth, 0),
        righthalf:get_area_anchor("invndrain").tl,
        righthalf:get_area_anchor("invndrain").bl,
        (lefthalf:get_area_anchor("invgate").br .. righthalf:get_area_anchor("invndrain").bl):translate(_P.latchcrossingoffset, 0),
        lefthalf:get_area_anchor("invgate").br:translate(_P.latchcrossingoffset, 0),
        lefthalf:get_area_anchor("invgate").br,
    })

    -- connect clock gates (asymmetric part)
    geometry.rectanglebltr(comparator, generics.metal(1),
        lefthalf:get_area_anchor("clock").br,
        righthalf:get_area_anchor("clock").tl
    )

    -- alternative clock wiring (FIXME: not updated)
    --[[
    geometry.rectanglebltr(comparator, generics.metal(3),
        pmosresetleft1:get_anchor("botgatestrapbr"),
        pmosresetright1:get_anchor("botgatestraptl")
    )
    geometry.path(comparator, generics.metal(3), {
        point.combine(pmosresetleft2:get_anchor("botgatestraptc"), pmosresetright2:get_anchor("botgatestraptc")),
        point.combine(clockleft:get_anchor("topgatestrapbc"), clockright:get_anchor("topgatestrapbc"))
    }, _P.sdwidth)
    --]]


    -- add ports
    comparator:add_port("clk", generics.metalport(1), clock:get_area_anchor("topgatestrap").br)
    comparator:add_port("vinp", generics.metalport(1), lefthalf:get_anchor("vin"))
    comparator:add_port("vinn", generics.metalport(1), righthalf:get_anchor("vin"))
    comparator:add_port("vss", generics.metalport(1), lefthalf:get_area_anchor("vss").bl)
    comparator:add_port("vdd", generics.metalport(1), lefthalf:get_area_anchor("vdd").bl)
end
