--[[
        Comparator Core:

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
        { "crossingswitchmetal", true },
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "pfetvthtype", 1 },
        { "nfetvthtype", 1 },
        { "pfetflippedwell", false },
        { "nfetflippedwell", false },
        { "clockfingers", 4 },
        { "clockdummyfingers", 1 },
        { "clockfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "clockinputgatewidth", technology.get_dimension("Minimum M1 Width") },
        { "clockinputgatespace", technology.get_dimension("Minimum M1 Space") },
        { "inputfingers", 2 },
        { "inputfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "inputdummyfingers", 1 },
        { "latchfingers", 2 },
        { "latchnfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "latchpfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "latchcrossingoffset", 0 },
        { "latchgatewidth", technology.get_dimension("Minimum M1 Width") },
        { "latchgatespace", technology.get_dimension("Minimum M1 Space") },
        { "invdummyfingers", 1 },
        { "resetfingers", 2 },
        { "inputclocksdspace", technology.get_dimension("Minimum M1 Space") },
        { "invskip", 200 },
        { "resetgatewidth", technology.get_dimension("Minimum M1 Width") },
        { "resetgatespace", technology.get_dimension("Minimum M1 Space") },
        { "bufferfingers", 2 },
        { "buffernfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "bufferpfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "rslatchnfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "rslatchpfingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "gstrwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerwidth", 3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace", 2 * technology.get_dimension("Minimum M1 Space") },
        { "gatecutheight", 60 },
        { "outerdummyfingers", 0 },
        { "connectdummiesinline", false },
        { "alternativeclockconnection", false },
        { "leftpolylines", {} },
        { "rightpolylines", {} }
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

    local baseopt = {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        topgateleftextension = _P.gatespace / 2,
        topgaterightextension = _P.gatespace / 2,
        botgateleftextension = _P.gatespace / 2,
        botgaterightextension = _P.gatespace / 2,
        actext = 100, -- FIXME: should be a parameter
        gtopext = separation,
        gbotext = separation,
        topgatecutheight = _P.gatecutheight,
        topgatecutspace = separation - _P.gatecutheight / 2,
        botgatecutheight = _P.gatecutheight,
        botgatecutspace = separation - _P.gatecutheight / 2,
        topgatecutleftext = _P.gatespace / 2,
        topgatecutrightext = _P.gatespace / 2,
        botgatecutleftext = _P.gatespace / 2,
        botgatecutrightext = _P.gatespace / 2,
        extendoxidetypeleft = 3 * xpitch,
        extendoxidetyperight = 3 * xpitch,
        extendvthtypeleft = 3 * xpitch,
        extendvthtyperight = 3 * xpitch,
        extendimplantleft = 3 * xpitch,
        extendimplantright = 3 * xpitch,
        extendwellleft = 3 * xpitch,
        extendwellright = 3 * xpitch,
        extendwelltop = separation,
        extendwellbottom = separation,
        extendlvsmarkerleft = 3 * xpitch,
        extendlvsmarkerright = 3 * xpitch,
    }

    -- create transistor layouts
    local rslatchfingers = 1
    local clockrowfingers = _P.clockfingers + _P.clockdummyfingers
    local inputrowfingers = 2 * _P.inputfingers + _P.inputdummyfingers
    local invnfingers = 2 * _P.latchfingers + _P.invdummyfingers
    if _P.drawoutputbuffer then
        invnfingers = invnfingers + 4 * _P.resetfingers + 2 * _P.bufferfingers
    end
    if _P.drawoutputlatch then
        invnfingers = invnfingers + 4 * rslatchfingers
    end
    local invpfingers = 2 * _P.latchfingers + 4 * _P.resetfingers + _P.invdummyfingers
    if _P.drawoutputbuffer then
        invpfingers = invpfingers + 2 * _P.bufferfingers
    end
    if _P.drawoutputlatch then
        invpfingers = invpfingers + 4 * rslatchfingers
    end
    -- FIXME: due to errors in basic/mosfet, currently there has to be at least one (1) dummy left and right
    local maxfingers = math.max(clockrowfingers, inputrowfingers, invnfingers, invpfingers) + 2 + 2 * _P.outerdummyfingers
    -- clock tail dummy transistor (split actual clock transistor in two, left and right)
    -- this is not needed, maybe I will get rid of this at some point
    -- the transistor in the middle can be used to equalize the width regarding the input transistors
    local clockdummyref
    if _P.clockdummyfingers > 0 then
        clockdummyref = pcell.create_layout("basic/mosfet", "clockdummy", util.add_options(baseopt, {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            fingers = _P.clockdummyfingers,
            fingerwidth = _P.clockfingerwidth,
            drawbotgate = true,
            botgatewidth = _P.powerwidth,
            botgatespace = _P.powerspace,
            botgateleftextension = (_P.gatespace - _P.sdwidth) / 2,
            botgaterightextension = (_P.gatespace - _P.sdwidth) / 2,
            connectdrain = true,
            connectdraininverse = true,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            connectdrainwidth = _P.powerwidth,
            connectdrainspace = _P.powerspace,
            extendimplantbottom = 100, -- FIXME
            extendwellbottom = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
            gbotext = 2 * _P.powerspace + _P.powerwidth,
        }))
    end
    -- clock tail transistor
    local clock = pcell.create_layout("basic/mosfet", "clock", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.clockfingers / 2,
        fingerwidth = _P.clockfingerwidth,
        drawtopgate = true,
        topgatewidth = _P.clockinputgatewidth,
        topgatespace = _P.clockinputgatespace,
        connectdrain = true,
        drainmetal = 2,
        connectdrainwidth = _P.sdwidth,
        connectdrainspace = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace,
        drawdrainvia = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        drawtopgatecut = true,
        extendimplantbottom = 100,
        extendwellbottom = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        gbotext = 2 * _P.powerspace + _P.powerwidth,
    }))
    local clockfill = pcell.create_layout("basic/mosfet", "clockfill", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - clockrowfingers) / 2,
        fingerwidth = _P.clockfingerwidth,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        connectdrainrightext = xpitch,
        connectsourcerightext = xpitch,
        drawbotgate = true,
        botgatespace = _P.powerspace,
        botgatewidth = _P.powerwidth,
        drawleftstopgate = true,
        drawstopgatetopgatecut = true,
        extendimplantbottom = 100,
        extendwellbottom = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        leftpolylines = _P.leftpolylines,
        gbotext = 2 * _P.powerspace + _P.powerwidth,
    }))
    -- input transistors
    local inputdummy = pcell.create_layout("basic/mosfet", "inputdummy", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.inputdummyfingers,
        fingerwidth = _P.inputfingerwidth,
    }))
    local input = pcell.create_layout("basic/mosfet", "input", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.inputfingers,
        fingerwidth = _P.inputfingerwidth,
        connectsource = true,
        sourcemetal = 2,
        drawsourcevia = true,
        drawbotgate = true,
        botgatewidth = _P.clockinputgatewidth,
        botgatespace = _P.clockinputgatespace,
        connectsourcewidth = _P.sdwidth,
        connectsourcespace = _P.clockinputgatespace + _P.clockinputgatewidth + _P.inputclocksdspace,
        connectdrain = true,
        connectdrainwidth = _P.sdwidth,
        connectdrainspace = separation - _P.sdwidth / 2,
        drawtopgatecut = true
    }))
    local inputfill = pcell.create_layout("basic/mosfet", "inputfill", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - inputrowfingers) / 2,
        fingerwidth = _P.inputfingerwidth,
        drawleftstopgate = true,
        drawstopgatebotgatecut = true,
        drawstopgatetopgatecut = true,
        leftpolylines = _P.leftpolylines,
        drawextrabotstrap = not _P.connectdummiesinline,
        extrabotstrapwidth = _P.sdwidth,
        extrabotstrapspace = _P.clockinputgatespace,
        extrabotstraprightalign = (maxfingers - inputrowfingers) / 2,
    }))
    -- CMOS inverter
    local nmosdummy = pcell.create_layout("basic/mosfet", "nmosdummy", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = _P.invdummyfingers,
        fingerwidth = _P.latchnfingerwidth,
        extendimplanttop = -_P.invskip,
        extendvthtypetop = -_P.invskip,
        drawtopgatecut = true,
    }))
    local nmosinv = pcell.create_layout("basic/mosfet", "nmosinv", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatewidth = _P.latchgatewidth,
        topgatespace = separation - _P.latchgatewidth / 2,
        fingers = _P.latchfingers,
        fingerwidth = _P.latchnfingerwidth,
        connectsource = true,
        sourcemetal = 1,
        drawsourcevia = true,
        connectsourcewidth = _P.sdwidth,
        connectsourcespace = separation - _P.sdwidth / 2,
        connectdrain = true,
        drainmetal = _P.crossingswitchmetal and 3 or 2,
        drawdrainvia = true,
        connectdrainwidth = _P.latchgatewidth,
        connectdrainspace = _P.latchgatespace,
        extendimplanttop = -_P.latchgatewidth / 2,
        extendvthtypetop = -_P.latchgatewidth / 2,
        drawbotgatecut = true
    }))
    local nmosinvfill = pcell.create_layout("basic/mosfet", "nmosinvfill", util.add_options(baseopt, {
        channeltype = "nmos",
        flippedwell = _P.nfetflippedwell,
        vthtype = _P.nfetvthtype,
        fingers = (maxfingers - invnfingers) / 2,
        fingerwidth = _P.latchnfingerwidth,
        drawtopgatecut = true,
        drawleftstopgate = true,
        drawstopgatebotgatecut = true,
        drawstopgatetopgatecut = true,
        leftpolylines = _P.leftpolylines,
        drawextrabotstrap = not _P.connectdummiesinline,
        extrabotstrapwidth = _P.sdwidth,
        extrabotstrapspace = _P.clockinputgatespace,
        extrabotstraprightalign = (maxfingers - invnfingers) / 2,
    }))
    local pmosinv = pcell.create_layout("basic/mosfet", "pmosinv", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = _P.latchfingers,
        fingerwidth = _P.latchpfingerwidth,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        drainmetal = _P.crossingswitchmetal and 3 or 2,
        drawdrainvia = true,
        connectdrainwidth = _P.latchgatewidth,
        connectdrainspace = _P.latchgatespace,
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100, -- FIXME
        extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
    }))
    local pmosinvfill = pcell.create_layout("basic/mosfet", "pmosinvfill", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = (maxfingers - invpfingers) / 2,
        fingerwidth = _P.latchpfingerwidth,
        drawtopgate = true,
        topgatewidth = _P.powerwidth,
        topgatespace = _P.powerspace,
        drawleftstopgate = true,
        drawstopgatebotgatecut = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectsourcerightext = xpitch, -- only needed when fingers == 1, but still valid otherwise
        gtopext = 2 * _P.powerspace + _P.powerwidth,
        extendimplanttop = 100, -- FIXME
        extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        leftpolylines = _P.leftpolylines,
    }))

    local pmosdummy = pcell.create_layout("basic/mosfet", "pmosdummy", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        fingers = _P.invdummyfingers,
        fingerwidth = _P.latchpfingerwidth,
        drawtopgate = true,
        topgatewidth = _P.powerwidth,
        topgatespace = _P.powerspace,
        connectdrain = true,
        connectdraininverse = true,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        connectdrainspace = _P.powerspace,
        connectsourcerightext = xpitch,
        drawbotgatecut = true,
        extendimplanttop = 100, -- FIXME
        extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        gtopext = 2 * _P.powerspace + _P.powerwidth,
    }))
    -- reset switches
    local pmosresetref = pcell.create_layout("basic/mosfet", "pmosresetref", util.add_options(baseopt, {
        channeltype = "pmos",
        flippedwell = _P.pfetflippedwell,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatewidth = _P.resetgatewidth,
        botgatespace = _P.resetgatespace,
        fingers = _P.resetfingers,
        fingerwidth = _P.latchpfingerwidth,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        drainmetal = 3,
        --connectdrainwidth = _P.latchgatewidth,
        --connectdrainspace = separation - _P.latchgatewidth / 2,
        drawdrainvia = true,
        extendimplanttop = 100, -- FIXME
        extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        gtopext = 2 * _P.powerspace + _P.powerwidth,
    }))

    local pmosbuf
    local nmosbufspacer
    local nmosbuf
    if _P.drawoutputbuffer then
        nmosbufspacer = pcell.create_layout("basic/mosfet", "nmosbufspacer", util.add_options(baseopt, {
            fingers = 2 * _P.resetfingers,
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            fingerwidth = _P.latchnfingerwidth,
        }))
        nmosbuf = pcell.create_layout("basic/mosfet", "nmosbuf", util.add_options(baseopt, {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            drawtopgate = true,
            topgatewidth = _P.latchgatewidth,
            topgatespace = separation - _P.latchgatewidth / 2,
            fingers = _P.bufferfingers,
            fingerwidth = _P.latchnfingerwidth,
            connectsource = true,
            sourcemetal = 1,
            drawsourcevia = true,
            connectsourcewidth = _P.sdwidth,
            connectsourcespace = _P.clockinputgatespace,
            drawdrainvia = true,
            connectdrain = true,
            drawbotgatecut = true
        }))
        pmosbuf = pcell.create_layout("basic/mosfet", "pmosbuf", util.add_options(baseopt, {
            channeltype = "pmos",
            flippedwell = _P.pfetflippedwell,
            vthtype = _P.pfetvthtype,
            fingers = _P.bufferfingers,
            fingerwidth = _P.latchpfingerwidth,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            drawdrainvia = true,
            connectdrain = true,
            gtopext = 2 * _P.powerspace + _P.powerwidth,
            extendimplanttop = 100, -- FIXME
            extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        }))
    end

    local nmosrslatch1, nmosrslatch2
    local pmosrslatch1, pmosrslatch2
    if _P.drawoutputlatch then
        nmosrslatch1 = pcell.create_layout("basic/mosfet", "nmosrslatch1", util.add_options(baseopt, {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            drawtopgate = true,
            topgatewidth = _P.latchgatewidth,
            topgatespace = separation - _P.latchgatewidth / 2,
            fingers = rslatchfingers,
            fingerwidth = _P.latchnfingerwidth,
            --drawsourcedrain = "drain", -- optional, but less regular
            drawbotgatecut = true
        }))
        nmosrslatch2 = pcell.create_layout("basic/mosfet", "nmosrslatch2", util.add_options(baseopt, {
            channeltype = "nmos",
            flippedwell = _P.nfetflippedwell,
            vthtype = _P.nfetvthtype,
            drawtopgate = true,
            topgatewidth = _P.latchgatewidth,
            topgatespace = separation - _P.latchgatewidth / 2,
            fingers = rslatchfingers,
            fingerwidth = _P.latchnfingerwidth,
            connectsource = true,
            connectsourceinverse = true,
            connectsourcewidth = _P.sdwidth,
            connectsourcespace = _P.clockinputgatespace,
            connectsourceleftext = xpitch,
            drawbotgatecut = true,
            --drawsourcedrain = "source", -- optional, but less regular
        }))
        pmosrslatch1 = pcell.create_layout("basic/mosfet", "pmosrslatch1", util.add_options(baseopt, {
            channeltype = "pmos",
            flippedwell = _P.pfetflippedwell,
            vthtype = _P.pfetvthtype,
            fingers = rslatchfingers,
            fingerwidth = _P.latchpfingerwidth,
            drawdrainvia = true,
            gtopext = 2 * _P.powerspace + _P.powerwidth,
            extendimplanttop = 100, -- FIXME
            extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        }))
        pmosrslatch2 = pcell.create_layout("basic/mosfet", "pmosrslatch2", util.add_options(baseopt, {
            channeltype = "pmos",
            flippedwell = _P.pfetflippedwell,
            vthtype = _P.pfetvthtype,
            fingers = rslatchfingers,
            fingerwidth = _P.latchpfingerwidth,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            connectsourcerightext = 2 * xpitch - _P.sdwidth,
            connectdrain = true,
            connectdrainwidth = _P.sdwidth,
            connectdrainspace = _P.clockinputgatespace,
            connectdrainleftext = 2 * xpitch,
            drawdrainvia = true,
            gtopext = 2 * _P.powerspace + _P.powerwidth,
            extendimplanttop = 100, -- FIXME
            extendwelltop = 2 * _P.powerspace + _P.powerwidth + 100, -- FIXME
        }))
    end

    local halfref = object.create("half")

    -- place clock row
    local clockdummy
    if _P.clockdummyfingers > 0 then
        clockdummy = clockdummyref
        halfref:merge_into(clockdummy)
        clock:abut_left(clockdummy)
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
    input:align_area_anchor_left("sourcedrainactiveright", inputdummy, "sourcedrainactiveleft")
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
    nmosinv:align_area_anchor_left("sourcedrainactiveright", nmosdummy, "sourcedrainactiveleft")
    nmosinv:align_area_anchor_top("gate1", nmosdummy, "gate1")
    halfref:merge_into(nmosdummy)
    halfref:merge_into(nmosinv)

    -- place pmos inverter + reset row
    pmosinv:abut_area_anchor_top("gate1", nmosinv, "gate1")
    pmosinv:align_area_anchor_left("gate1", nmosinv, "gate1")
    pmosinv:translate(0, -_P.latchgatewidth / 2) -- compensate for displacement due to gate strap (FIXME: should be fixed in basic/mosfet?)
    pmosdummy:align_area_anchor("sourcedrainactiveleft", pmosinv, "sourcedrainactiveright")
    pmosreset1:align_area_anchor("sourcedrainactiveright", pmosinv, "sourcedrainactiveleft")
    pmosreset2:align_area_anchor("sourcedrainactiveright", pmosreset1, "sourcedrainactiveleft")
    halfref:merge_into(pmosdummy)
    halfref:merge_into(pmosinv)
    halfref:merge_into(pmosreset1)
    halfref:merge_into(pmosreset2)

    -- place nmos buffer + latch
    if _P.drawoutputbuffer then
        nmosbufspacer:align_area_anchor("sourcedrainactiveright", nmosinv, "sourcedrainactiveleft")
        halfref:merge_into(nmosbufspacer)
        nmosbuf:align_area_anchor("sourcedrainactiveright", nmosbufspacer, "sourcedrainactiveleft")
        halfref:merge_into(nmosbuf)
        nmosrslatch1:align_area_anchor("sourcedrainactiveright", nmosbuf, "sourcedrainactiveleft")
    end
    if _P.drawoutputlatch then
        halfref:merge_into(nmosrslatch1)
        nmosrslatch2:align_area_anchor("sourcedrainactiveright", nmosrslatch1, "sourcedrainactiveleft")
        halfref:merge_into(nmosrslatch2)
    end

    -- place pmos buffer + latch
    if _P.drawoutputbuffer then
        pmosbuf:align_area_anchor("sourcedrainactiveright", pmosreset2, "sourcedrainactiveleft")
        halfref:merge_into(pmosbuf)
        pmosrslatch1:align_area_anchor("sourcedrainactiveright", pmosbuf, "sourcedrainactiveleft")
    end
    if _P.drawoutputlatch then
        halfref:merge_into(pmosrslatch1)
        pmosrslatch2:align_area_anchor("sourcedrainactiveright", pmosrslatch1, "sourcedrainactiveleft")
        halfref:merge_into(pmosrslatch2)
    end

    -- fill up clock row
    clockfill:align_area_anchor("sourcedrainactiveright", clock, "sourcedrainactiveleft")
    halfref:merge_into(clockfill)

    -- fill up input row
    inputfill:align_area_anchor("sourcedrainactiveright", input, "sourcedrainactiveleft")
    halfref:merge_into(inputfill)

    -- fill up nmos inv row
    if _P.drawoutputlatch then
        nmosinvfill:align_area_anchor("sourcedrainactiveright", nmosrslatch2, "sourcedrainactiveleft")
    elseif _P.drawoutputbuffer then
        nmosinvfill:align_area_anchor("sourcedrainactiveright", nmosbuf, "sourcedrainactiveleft")
    else
        nmosinvfill:align_area_anchor("sourcedrainactiveright", nmosinv, "sourcedrainactiveleft")
    end
    halfref:merge_into(nmosinvfill)

    -- fill up input row
    if _P.drawoutputlatch then
        pmosinvfill:align_area_anchor("sourcedrainactiveright", pmosrslatch2, "sourcedrainactiveleft")
    elseif _P.drawoutputbuffer then
        pmosinvfill:align_area_anchor("sourcedrainactiveright", pmosbuf, "sourcedrainactiveleft")
    else
        pmosinvfill:align_area_anchor("sourcedrainactiveright", pmosreset2, "sourcedrainactiveleft")
    end
    halfref:merge_into(pmosinvfill)

    -- connect reset gates
    geometry.rectanglebltr(halfref, generics.metal(1),
        pmosreset2:get_area_anchor("botgatestrap").bl,
        pmosreset1:get_area_anchor("botgatestrap").tr
    )

    -- connect latch drains and inner reset transistors
    if _P.crossingswitchmetal then
        geometry.rectanglebltr(halfref, generics.metal(3),
            pmosreset1:get_area_anchor("drainstrap").br,
            pmosinv:get_area_anchor("drainstrap").tl
        )
        --geometry.rectanglebltr(halfref, generics.metal(2),
        --    pmosreset1:get_area_anchor("drainstrap").br,
        --    nmosinv:get_area_anchor("topgatestrap").tl
        --)
    else
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
    end

    -- connect outer reset transistors
    if _P.resetfingers > 2 then
        geometry.polygon(halfref, generics.metal(3), {
            nmosinv:get_area_anchor("sourcestrap").tl,
            (pmosreset2:get_area_anchor("drainstrap").tr .. nmosinv:get_area_anchor("sourcestrap").tl):translate(_P.sdwidth, 0),
            pmosreset2:get_area_anchor("drainstrap").tr:translate(_P.sdwidth, 0),
            pmosreset2:get_area_anchor("drainstrap").tr,
            pmosreset2:get_area_anchor("drainstrap").br .. nmosinv:get_area_anchor("sourcestrap").bl,
            nmosinv:get_area_anchor("sourcestrap").bl
        })
    else
        geometry.polygon(halfref, generics.metal(3), {
            nmosinv:get_area_anchor("sourcestrap").tl,
            pmosreset2:get_area_anchor("drainstrap").br .. nmosinv:get_area_anchor("sourcestrap").tl,
            pmosreset2:get_area_anchor("drainstrap").br,
            pmosreset2:get_area_anchor("drainstrap").bl,
            pmosreset2:get_area_anchor("drainstrap").bl .. nmosinv:get_area_anchor("sourcestrap").bl,
            nmosinv:get_area_anchor("sourcestrap").bl
        })
    end
    geometry.viabltr(halfref, 1, 3,
        nmosinv:get_area_anchor("sourcestrap").bl,
        nmosinv:get_area_anchor("sourcestrap").tr
    )

    -- connect clock gates (symmetric part)
    if not _P.alternativeclockconnection then
        -- FIXME: vias are missing
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
    else
        geometry.viabltr(halfref, 1, 2,
            pmosreset2:get_area_anchor("botgatestrap").bl,
            pmosreset1:get_area_anchor("botgatestrap").tr
        )
        geometry.polygon(halfref, generics.metal(2), {
            pmosreset2:get_area_anchor("botgatestrap").tl,
            pmosreset2:get_area_anchor("botgatestrap").tl:translate(-_P.sdwidth, 0),
            (pmosreset2:get_area_anchor("botgatestrap").tl .. clock:get_area_anchor("topgatestrap").bl):translate(-_P.sdwidth, 0),
            pmosreset2:get_area_anchor("botgatestrap").bl .. clock:get_area_anchor("topgatestrap").bl,
            pmosreset2:get_area_anchor("botgatestrap").bl .. clock:get_area_anchor("topgatestrap").tl,
            pmosreset2:get_area_anchor("botgatestrap").bl .. clock:get_area_anchor("topgatestrap").tl,
            pmosreset2:get_area_anchor("botgatestrap").bl,
        })
        geometry.rectanglebltr(halfref, generics.metal(1),
            pmosreset1:get_area_anchor("botgatestrap").br .. clock:get_area_anchor("topgatestrap").bl,
            clock:get_area_anchor("topgatestrap").tl
        )
        geometry.viabltr(halfref, 1, 2,
            pmosreset2:get_area_anchor("botgatestrap").bl .. clock:get_area_anchor("topgatestrap").bl,
            pmosreset1:get_area_anchor("botgatestrap").br .. clock:get_area_anchor("topgatestrap").tl
        )
    end

    -- connect input row fill dummies
    -- 'shortdevice' can't be used on these as the inner source is shared with the input transistors
    if _P.connectdummiesinline then
        geometry.rectanglebltr(halfref, generics.metal(1),
            inputfill:get_area_anchor("sourcedrainactiveleft").br,
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
            nmosinvfill:get_area_anchor("sourcedrainactiveleft").br,
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

    -- connect comparator to buffer
    if _P.drawoutputbuffer then
        geometry.rectanglebltr(halfref, generics.metal(1),
            nmosbuf:get_area_anchor("topgatestrap").br,
            nmosinv:get_area_anchor("topgatestrap").tl
        )
    end

    -- connect buffer to output latch
    if _P.drawoutputlatch then
        geometry.polygon(halfref, generics.metal(1), {
            pmosbuf:get_area_anchor("drainstrap").tl,
            nmosrslatch1:get_area_anchor(string.format("topgate%d", rslatchfingers)).br .. pmosbuf:get_area_anchor("drainstrap").tl,
            nmosrslatch1:get_area_anchor(string.format("topgate%d", rslatchfingers)).br .. nmosbuf:get_area_anchor("drainstrap").bl,
            nmosbuf:get_area_anchor("drainstrap").bl,
            nmosbuf:get_area_anchor("drainstrap").tl,
            (nmosrslatch1:get_area_anchor(string.format("topgate%d", rslatchfingers)).br .. nmosbuf:get_area_anchor("drainstrap").tl):translate(_P.sdwidth, 0),
            (nmosrslatch1:get_area_anchor(string.format("topgate%d", rslatchfingers)).br .. pmosbuf:get_area_anchor("drainstrap").bl):translate(_P.sdwidth, 0),
            pmosbuf:get_area_anchor("drainstrap").bl,
        })
    end

    -- connect output latch nets
    if _P.drawoutputlatch then
        geometry.rectanglebltr(halfref, generics.metal(1),
            nmosrslatch2:get_area_anchor("sourcestrap").bl,
            pmosrslatch2:get_area_anchor("drainstrap").tl:translate(_P.sdwidth, 0)
        )
    end

    -- connect output latch nets (symmetric part)
    if _P.drawoutputlatch then
        geometry.viabltr(halfref, 1, 4,
            nmosrslatch2:get_area_anchor("topgatestrap").bl:translate(-xpitch, 0),
            nmosrslatch2:get_area_anchor("topgatestrap").tr
        )
    end

    -- connect latch gates (symmetric part)
    geometry.viabltr(halfref, 1, 2,
        nmosinv:get_area_anchor("topgatestrap").bl,
        nmosinv:get_area_anchor("topgatestrap").tr
    )
    if _P.crossingswitchmetal then
        geometry.rectanglebltr(halfref, generics.metal(3),
            nmosinv:get_area_anchor("sourcedrain2").tl,
            pmosinv:get_area_anchor("sourcedrain2").br
        )
    end

    -- copy needed anchors
    halfref:add_area_anchor_bltr("clockgate", clock:get_area_anchor("topgatestrap").bl, clock:get_area_anchor("topgatestrap").tr)
    halfref:add_anchor("vin", input:get_area_anchor("botgatestrap").bl)
    halfref:add_area_anchor_bltr("vtail", input:get_area_anchor("sourcestrap").bl, input:get_area_anchor("sourcestrap").tr)
    halfref:add_area_anchor_bltr("vss", clockfill:get_area_anchor("sourcestrap").bl, clockfill:get_area_anchor("sourcestrap").tr)
    halfref:add_area_anchor_bltr("vdd", pmosinvfill:get_area_anchor("sourcestrap").bl, pmosinvfill:get_area_anchor("sourcestrap").tr)
    halfref:add_area_anchor_bltr("reset1gate", pmosreset1:get_area_anchor("botgatestrap").bl, pmosreset1:get_area_anchor("botgatestrap").tr)
    halfref:add_area_anchor_bltr("reset2gate", pmosreset2:get_area_anchor("botgatestrap").bl, pmosreset2:get_area_anchor("botgatestrap").tr)
    halfref:add_area_anchor_bltr("invgate", nmosinv:get_area_anchor("topgatestrap").bl, nmosinv:get_area_anchor("topgatestrap").tr)
    halfref:add_area_anchor_bltr("invpdrain", pmosinv:get_area_anchor("drainstrap").bl, pmosinv:get_area_anchor("drainstrap").tr)
    halfref:add_area_anchor_bltr("invndrain", nmosinv:get_area_anchor("drainstrap").bl, nmosinv:get_area_anchor("drainstrap").tr)
    if _P.drawoutputlatch then
        halfref:add_area_anchor_bltr("latchpdrain",
            pmosrslatch2:get_area_anchor("drainstrap").bl,
            pmosrslatch2:get_area_anchor("drainstrap").tr:translate(-xpitch, 0)
        )
        halfref:add_area_anchor_bltr("latchndrain",
            nmosrslatch2:get_area_anchor("sourcestrap").bl,
            nmosrslatch2:get_area_anchor("sourcestrap").tr
        )
        halfref:add_area_anchor_bltr("latchgate", nmosrslatch2:get_area_anchor("topgatestrap").bl, nmosrslatch2:get_area_anchor("topgatestrap").tr)
    end

    -- place left and right comparator half
    -- FIXME: alignment box should contain power rails
    halfref:inherit_alignment_box(clockdummy) -- align at clock dummy
    halfref:inherit_alignment_box(clockfill)
    halfref:inherit_alignment_box(input)
    halfref:inherit_alignment_box(inputfill)
    halfref:inherit_alignment_box(nmosinv)
    halfref:inherit_alignment_box(pmosinv)
    halfref:inherit_alignment_box(pmosreset1)
    halfref:inherit_alignment_box(pmosreset2)
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

    -- connect latch gates (asymmetric part)
    if not _P.crossingswitchmetal then
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
    else
        geometry.viabltr(comparator, 2, 3,
            lefthalf:get_area_anchor("invpdrain").bl,
            lefthalf:get_area_anchor("invpdrain").tr
        )
        geometry.polygon(comparator, generics.metal(2), {
            lefthalf:get_area_anchor("invgate").tr,
            lefthalf:get_area_anchor("invgate").tr:translate(_P.sdwidth, 0),
            lefthalf:get_area_anchor("invgate").tr:translate(_P.sdwidth, 0) .. righthalf:get_area_anchor("invndrain").tl,
            righthalf:get_area_anchor("invndrain").tl,
            righthalf:get_area_anchor("invndrain").bl,
            lefthalf:get_area_anchor("invgate").br .. righthalf:get_area_anchor("invndrain").bl,
        })
        geometry.viabltr(comparator, 2, 3,
            righthalf:get_area_anchor("invndrain").bl,
            righthalf:get_area_anchor("invndrain").tr
        )
        geometry.polygon(comparator, generics.metal(2), {
            righthalf:get_area_anchor("invgate").bl,
            righthalf:get_area_anchor("invgate").bl:translate(-_P.sdwidth, 0),
            righthalf:get_area_anchor("invgate").bl:translate(-_P.sdwidth, 0) .. lefthalf:get_area_anchor("invpdrain").br,
            lefthalf:get_area_anchor("invpdrain").br,
            lefthalf:get_area_anchor("invpdrain").tr,
            righthalf:get_area_anchor("invgate").tl .. lefthalf:get_area_anchor("invpdrain").tr,
        })
    end

    -- connect clock gates (asymmetric part)
    geometry.rectanglebltr(comparator, generics.metal(1),
        lefthalf:get_area_anchor("clockgate").br,
        righthalf:get_area_anchor("clockgate").tl
    )
    if _P.alternativeclockconnection then
        --geometry.rectanglebltr(comparator, generics.metal(3),
        --    lefthalf:get_area_anchor("reset1gate").br,
        --    righthalf:get_area_anchor("reset1gate").tl
        --)
        --geometry.viabltr(comparator, 1, 3,
        --    lefthalf:get_area_anchor("clockgate").bl,
        --    righthalf:get_area_anchor("clockgate").tr
        --)
        --geometry.path(comparator, generics.metal(3), {
        --    point.combine(lefthalf:get_area_anchor("reset1gate").br, righthalf:get_area_anchor("reset1gate").bl),
        --    point.combine(lefthalf:get_area_anchor("clockgate").tr, righthalf:get_area_anchor("clockgate").tl)
        --}, _P.sdwidth)
    end

    -- connect output latch nets (asymmetric part)
    if _P.drawoutputlatch then
        geometry.viabltr(comparator, 1, 4,
            lefthalf:get_area_anchor("latchpdrain").bl,
            lefthalf:get_area_anchor("latchpdrain").tr
        )
        geometry.viabltr(comparator, 1, 4,
            righthalf:get_area_anchor("latchndrain").bl,
            righthalf:get_area_anchor("latchndrain").tr
        )

        geometry.polygon(comparator, generics.metal(4), {
            lefthalf:get_area_anchor("latchpdrain").br,
            (righthalf:get_area_anchor("latchgate").bl .. lefthalf:get_area_anchor("latchpdrain").br):translate(-_P.sdwidth, 0),
            righthalf:get_area_anchor("latchgate").bl:translate(-_P.sdwidth, 0),
            righthalf:get_area_anchor("latchgate").bl,
            righthalf:get_area_anchor("latchgate").tl .. lefthalf:get_area_anchor("latchpdrain").tr,
            lefthalf:get_area_anchor("latchpdrain").tr,
        })
        geometry.polygon(comparator, generics.metal(4), {
            righthalf:get_area_anchor("latchndrain").tl,
            (lefthalf:get_area_anchor("latchgate").tr .. righthalf:get_area_anchor("latchndrain").tl):translate(_P.sdwidth, 0),
            lefthalf:get_area_anchor("latchgate").tr:translate(_P.sdwidth, 0),
            lefthalf:get_area_anchor("latchgate").tr,
            lefthalf:get_area_anchor("latchgate").br,
            lefthalf:get_area_anchor("latchgate").br .. righthalf:get_area_anchor("latchndrain").bl,
            righthalf:get_area_anchor("latchndrain").bl,
        })
    end

    comparator:inherit_alignment_box(lefthalf)
    comparator:inherit_alignment_box(righthalf)

    -- add ports
    comparator:add_port("clk", generics.metalport(1), clock:get_area_anchor("topgatestrap").br)
    comparator:add_port("vinp", generics.metalport(1), lefthalf:get_anchor("vin"))
    comparator:add_port("vinn", generics.metalport(1), righthalf:get_anchor("vin"))
    comparator:add_port("vss", generics.metalport(1), lefthalf:get_area_anchor("vss").bl)
    comparator:add_port("vdd", generics.metalport(1), lefthalf:get_area_anchor("vdd").bl)

    -- anchors
    comparator:add_area_anchor_bltr("vdd", lefthalf:get_area_anchor("vdd").bl, righthalf:get_area_anchor("vdd").tr)
    comparator:add_area_anchor_bltr("vss", lefthalf:get_area_anchor("vss").bl, righthalf:get_area_anchor("vss").tr)
end
