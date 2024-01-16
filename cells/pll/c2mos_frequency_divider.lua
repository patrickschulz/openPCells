--[[
        Latch implementation:
  VDD ───────────────────────────────────────┬──────────────────────────────────┬───────────────────┐
                                             │                                  │                   │
                                         ║───┘                                  │                   │
                                       ─o║                                      │                   │
                                         ║───┐                                  │                   │
                                             │                                  │                   │
                                   ┌─────────┴─────────┐                        │                   │
                                   │                   │                        └───║           ║───┘
                               ║───┘                   └───║                        ║o──┐   ┌──o║
                      Dp o────o║                           ║o────o Dn           ┌───║   │   │   ║───┐
                               ║───┐                   ┌───║                    │       │   │       │
                                   │                   │               voutp ───┼───────────┤       │
                                   ├── voutp   voutn ──┤                        │       │   │       │
                                   │                   │                        │       ├───────────┼───── voutn
                               ║───┘                   └───║                    │       │   │       │
                      Dp o─────║                           ║o────o Dn           └───║   │   │   ║───┘
                               ║───┐                   ┌───║                        ║───┘   └───║
                                   │                   │                        ┌───║           ║───┐
                                   └─────────┬─────────┘                        │                   │
                                             │                                  │                   │
                                         ║───┘                                  │                   │
                               vclk o────║                                      │                   │
                                         ║───┐                                  │                   │
                                             │                                  │                   │
  VSS ───────────────────────────────────────┴──────────────────────────────────┴───────────────────┘


        Divider implementation:
                                   ┌─────────────┐             ┌─────────────┐
          inversion here ---> ~B ──┤             ├── A     A ──┤             ├── B
                               B ──┤             ├── ~A   ~A ──┤             ├── ~B
                                   │    Latch    │             │    Latch    │
                             inp ──┤             │       inn ──┤             │
                             inn ──┤             │       inp ──┤             │
                                   └─────────────┘             └─────────────┘
--]]

function parameters()
    pcell.add_parameters(
        { "divisionfactor", 1 }, -- as power-of-two (e.g. 1 -> division by 2, 3 -> division by 8)
        { "gatelength", technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "separation", 0 },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "interconnectionwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "clockfingers", 40 },
        { "inputfingers", 32 },
        { "latchinnersepfingers", 2 },
        { "latchoutersepfingers", 2 },
        { "latchfingers", 6 },
        { "latchinterconnectwidth", 60 },
        { "outerdummies", 2 },
        { "nmosclockfingerwidth", 500 },
        { "pmosclockfingerwidth", 500 },
        { "nmosinputfingerwidth", 500 },
        { "pmosinputfingerwidth", 500 },
        { "nmosclockdrainsourcesize", 500, follow = "nmosclockfingerwidth" },
        { "nmoslatchdrainsourcesize", 500, follow = "nmosclockfingerwidth" },
        { "nmosclockdummydrainsourcesize", 500, follow = "nmosclockfingerwidth" },
        { "nmosinputdrainsourcesize", 500, follow = "nmosinputfingerwidth" },
        { "nmosinputdummydrainsourcesize", 500, follow = "nmosinputfingerwidth" },
        { "nmosinputdummygatewidth", technology.get_dimension("Minimum M1 Width") },
        { "nmosinputdummygatespace", technology.get_dimension("Minimum M1 Space") },
        { "pmosclockdrainsourcesize", 500, follow = "pmosclockfingerwidth" },
        { "pmoslatchdrainsourcesize", 500, follow = "pmosclockfingerwidth" },
        { "pmosclockdummydrainsourcesize", 500, follow = "pmosclockfingerwidth" },
        { "pmosinputdrainsourcesize", 500, follow = "pmosinputfingerwidth" },
        { "pmosinputdummygatewidth", technology.get_dimension("Minimum M1 Width") },
        { "pmosinputdummygatespace", technology.get_dimension("Minimum M1 Space") },
        { "powerwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "inputlinewidth", 500 },
        { "drainwidth", 80 },
        { "latchgatestrapwidth", 60 },
        { "latchgatestrapspace", 70 },
        { "inputgatewidth", 60 },
        { "inputdrainsourcespace", 60 },
        { "inputdrainsourcewidth", 80 },
        { "clockgatewidth", 60 },
        { "dummygatecontactwidth", technology.get_dimension("Minimum M1 Width") },
        { "nmosvthtype", 1 },
        { "pmosvthtype", 1 },
        { "nmosflippedwell", false },
        { "pmosflippedwell", false },
        { "clockviaextension", 0 },
        { "latchstartmetal", 4 },
        { "latchendmetal", 5 },
        { "implantleftextension", 0 },
        { "implantrightextension", 0 },
        { "implanttopextension", 0 },
        { "implantbotextension", 0 },
        { "vthtypeleftextension", 0 },
        { "vthtyperightextension", 0 },
        { "vthtypetopextension", 0 },
        { "vthtypebotextension", 0 },
        { "wellleftextension", 0 },
        { "wellrightextension", 0 },
        { "welltopextension", 0 },
        { "wellbotextension", 0 },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "gatestopextension", 0 },
        { "gatesbotextension", 0 },
        { "gatecutheight", 100 },
        { "leftpolylines", {} },
        { "rightpolylines", {} },
        { "flat", true },
        { "addgatemetalnum", 0 },
        { "addinputconnectionmetalnum", 0 }
    )
end

function check(_P)
    if _P.clockfingers % 2 ~= 0 then
        return false, string.format("clockfingers must be divisible by 4 (got: %d)", _P.clockfingers)
    end
    if (_P.inputfingers % 2) ~= ((_P.clockfingers / 2) % 2) then
        return false, string.format("inputfingers must be even if clockfingers / 2 is even and vice versa (odd/odd) (inputfingers = %d, clockfingers / 2 = %d)", _P.inputfingers, _P.clockfingers / 2)
    end
    return true
end

local function _insert_before(rowdefinition, name, entry)
    for rownum, row in ipairs(rowdefinition) do
        for devicenum, device in ipairs(row.devices) do
            if device.name == name then
                table.insert(row.devices, devicenum, entry)
                return
            end
        end
    end
end

local function _insert_after(rowdefinition, name, entry)
    for rownum, row in ipairs(rowdefinition) do
        for devicenum, device in ipairs(row.devices) do
            if device.name == name then
                table.insert(row.devices, devicenum + 1, entry)
                return
            end
        end
    end
end

function layout(divider, _P)
    local xpitch = _P.gatelength + _P.gatespace
    local equalizationdummies = (_P.inputfingers - _P.clockfingers / 2) / 2
    local middledummyfingers = 2 * _P.latchoutersepfingers + _P.latchinnersepfingers + 2 * _P.latchfingers

    local baseoptions = {
        -- base mosfet options
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        -- gate strap settings
        topgateleftextension = xpitch / 2,
        topgaterightextension = xpitch / 2,
        botgateleftextension = xpitch / 2,
        botgaterightextension = xpitch / 2,
        -- gate cut settings
        topgatecutheight = _P.gatecutheight,
        topgatecutspace = (_P.separation - _P.gatecutheight) / 2,
        topgatecutrightext = _P.gatespace / 2,
        topgatecutleftext = _P.gatespace / 2,
        botgatecutheight = _P.gatecutheight,
        botgatecutspace = (_P.separation - _P.gatecutheight) / 2,
        botgatecutrightext = _P.gatespace / 2,
        botgatecutleftext = _P.gatespace / 2,
        stopgatecutheight = _P.gatecutheight,
        -- marker extensions
        extendimplantleft = _P.implantleftextension,
        extendimplantright = _P.implantrightextension,
        extendimplanttop = _P.implanttopextension,
        extendimplantbottom = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension + _P.implantbotextension,
        extendvthtypeleft = _P.vthtypeleftextension,
        extendvthtyperight = _P.vthtyperightextension,
        extendvthtypetop = _P.vthtypetopextension,
        extendvthtypebottom = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension + _P.vthtypebotextension,
        extendwellleft = _P.wellleftextension,
        extendwellright = _P.wellrightextension,
        extendwelltop = _P.welltopextension,
        extendwellbottom = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension + _P.vthtypebotextension,
    }

    local nmosoptions = util.add_options(baseoptions, {
        channeltype = "nmos",
        vthtype = _P.nmosvthtype,
        flippedwell = _P.nmosflippedwell,
        sourcealign = "bottom",
        drainalign = "top",
    })

    local pmosoptions = util.add_options(baseoptions, {
        channeltype = "pmos",
        vthtype = _P.pmosvthtype,
        flippedwell = _P.pmosflippedwell,
        drainalign = "bottom",
        sourcealign = "top",
    })

    local rowdefinition = { -- without equalization dummies, these are added after this table definition
        util.add_options(nmosoptions, { -- first nmos row (clock)
            width = _P.nmosclockfingerwidth,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            gbotext = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension,
            sourcesize = _P.nmosclockdrainsourcesize,
            drainsize = _P.nmosclockdrainsourcesize,
            devices = {
                {
                    name = "outerclockndummyleft",
                    fingers = _P.outerdummies,
                    drainmetal = 2,
                    connectdrain = true,
                    connectdraininverse = true,
                    drainalign = "bottom",
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    sourcesize = _P.nmosclockdummydrainsourcesize,
                    drainsize = _P.nmosclockdummydrainsourcesize,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                    drawstopgatetopgatecut = true,
                    drawtopgatecut = false,
                    drawbotgatecut = false,
                },
                {
                    name = "clocknleft",
                    fingers = _P.clockfingers / 2,
                    drawtopgate = true,
                    topgatewidth = _P.clockgatewidth,
                    topgatespace = _P.gatestrapspace,
                    topgatemetal = 2,
                    drawtopgatevia = true,
                    connectdrain = true,
                    connectdrainwidth = _P.inputdrainsourcewidth,
                    connectdrainspace = _P.separation - _P.inputdrainsourcewidth - _P.inputdrainsourcespace,
                    drainmetal = 3,
                    drawtopgatecut = true,
                    drawbotgatecut = true,
                },
                {
                    name = "clockndummymiddle",
                    fingers = middledummyfingers,
                    connectdrain = true,
                    connectdraininverse = true,
                    drainalign = "bottom",
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    sourcesize = _P.nmosclockdummydrainsourcesize,
                    drainsize = _P.nmosclockdummydrainsourcesize,
                    drainmetal = 2,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    drawbotgatecut = false,
                },
                {
                    name = "clocknright",
                    fingers = _P.clockfingers / 2,
                    drawtopgate = true,
                    topgatewidth = _P.clockgatewidth,
                    topgatespace = _P.gatestrapspace,
                    topgatemetal = 2,
                    drawtopgatevia = true,
                    connectdrain = true,
                    connectdrainwidth = _P.inputdrainsourcewidth,
                    connectdrainspace = _P.separation - _P.inputdrainsourcewidth - _P.inputdrainsourcespace,
                    drainmetal = 3,
                    connectsource = true,
                    drawtopgatecut = true,
                    drawbotgatecut = true,
                },
                {
                    name = "outerclockndummyright",
                    fingers = _P.outerdummies,
                    connectdrain = true,
                    connectdraininverse = true,
                    drainalign = "bottom",
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    sourcesize = _P.nmosclockdummydrainsourcesize,
                    drainsize = _P.nmosclockdummydrainsourcesize,
                    drainmetal = 2,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                    drawstopgatetopgatecut = true,
                    drawbotgatecut = false,
                    drawtopgatecut = false,
                },
            },
        }),
        util.add_options(nmosoptions, { -- second nmos row (input)
            width = _P.nmosinputfingerwidth,
            sourceviasize = _P.nmosinputdrainsourcesize,
            drainviasize = _P.nmosinputdrainsourcesize,
            devices = {
                {
                    name = "outerinputndummyleft",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                    drawstopgatetopgatecut = true,
                    drawstopgatebotgatecut = true,
                    drawbotgatecut = false,
                },
                {
                    name = "ninleft",
                    fingers = _P.inputfingers,
                    drawtopgate = true,
                    topgatewidth = _P.inputgatewidth,
                    topgatespace = (_P.separation - _P.inputgatewidth) / 2,
                    connectsource = true,
                    connectsourcewidth = _P.inputdrainsourcewidth,
                    connectsourcespace = _P.inputdrainsourcespace,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = _P.latchinterconnectwidth,
                    connectdrainspace = (_P.separation - _P.latchinterconnectwidth) / 2,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drawtopgatecut = false,
                },
                {
                    name = "ninputseparation1",
                    fingers = _P.latchoutersepfingers,
                    drawtopgatecut = true,
                    drawsourcedrain = "none",
                },
                {
                    name = "nlatchleft",
                    fingers = _P.latchfingers,
                    drawtopgate = true,
                    topgatewidth = _P.latchgatestrapwidth,
                    topgatespace = _P.latchgatestrapspace,
                    connectdrain = true,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drainviasize = _P.nmosclockdrainsourcesize,
                    sourceviasize = _P.nmosclockdrainsourcesize,
                    connectdrainwidth = _P.latchgatestrapwidth,
                    connectdrainspace = _P.separation - _P.latchgatestrapwidth - _P.latchgatestrapspace,
                    drawbotgatecut = true,
                },
                {
                    name = "ninputseparation2",
                    fingers = _P.latchinnersepfingers,
                    drawtopgatecut = true,
                    drawsourcedrain = "none",
                },
                {
                    name = "nlatchright",
                    fingers = _P.latchfingers,
                    drawtopgate = true,
                    topgatewidth = _P.latchgatestrapwidth,
                    topgatespace = _P.separation - _P.latchgatestrapwidth - _P.latchgatestrapspace,
                    connectdrain = true,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drainviasize = _P.nmosclockdrainsourcesize,
                    sourceviasize = _P.nmosclockdrainsourcesize,
                    connectdrainwidth = _P.latchgatestrapwidth,
                    connectdrainspace = _P.latchgatestrapspace,
                    drawbotgatecut = true,
                },
                {
                    name = "ninputseparation3",
                    fingers = _P.latchoutersepfingers,
                    drawtopgatecut = true,
                    drawsourcedrain = "none",
                },
                {
                    name = "ninright",
                    fingers = _P.inputfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = (_P.separation - 60) / 2,
                    connectsource = true,
                    connectsourcewidth = _P.inputdrainsourcewidth,
                    connectsourcespace = _P.inputdrainsourcespace,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = _P.latchinterconnectwidth,
                    connectdrainspace = (_P.separation - _P.latchinterconnectwidth) / 2,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drawtopgatecut = false,
                },
                {
                    name = "outerinputndummyright",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                    drawstopgatetopgatecut = true,
                    drawstopgatebotgatecut = true,
                    drawbotgatecut = false,
                },
            },
        }),
        util.add_options(pmosoptions, { -- first pmos row (input)
            width = _P.pmosinputfingerwidth,
            sourceviasize = _P.pmosinputdrainsourcesize,
            drainviasize = _P.pmosinputdrainsourcesize,
            devices = {
                {
                    name = "outerinputpdummyleft",
                    fingers = _P.outerdummies,
                    drawleftstopgate = _P.drawleftstopgate,
                    drawstopgatetopgatecut = true,
                    drawstopgatebotgatecut = true,
                    leftpolylines = _P.leftpolylines,
                },
                {
                    name = "pinleft",
                    fingers = _P.inputfingers,
                    connectsource = true,
                    connectsourcewidth = _P.inputdrainsourcewidth,
                    connectsourcespace = _P.inputdrainsourcespace,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = _P.latchinterconnectwidth,
                    connectdrainspace = (_P.separation - _P.latchinterconnectwidth) / 2,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drawbotgatecut = false,
                },
                {
                    name = "pinputseparation1",
                    fingers = _P.latchoutersepfingers,
                    drawbotgatecut = true,
                    drawsourcedrain = "none",
                },
                {
                    name = "platchleft",
                    fingers = _P.latchfingers,
                    connectdrain = true,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drainviasize = _P.pmosclockdrainsourcesize,
                    sourceviasize = _P.pmosclockdrainsourcesize,
                    connectdrainwidth = _P.latchgatestrapwidth,
                    connectdrainspace = _P.latchgatestrapspace,
                    drawtopgatecut = true,
                },
                {
                    name = "pinputseparation2",
                    fingers = _P.latchinnersepfingers,
                    drawbotgatecut = true,
                    drawsourcedrain = "none",
                },
                {
                    name = "platchright",
                    fingers = _P.latchfingers,
                    connectdrain = true,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drainviasize = _P.pmosclockdrainsourcesize,
                    sourceviasize = _P.pmosclockdrainsourcesize,
                    connectdrainwidth = _P.latchgatestrapwidth,
                    connectdrainspace = _P.separation - _P.latchgatestrapwidth - _P.latchgatestrapspace,
                    drawtopgatecut = true,
                },
                {
                    name = "pinputseparation3",
                    fingers = _P.latchoutersepfingers,
                    drawbotgatecut = true,
                    drawsourcedrain = "none",
                },
                {
                    name = "pinright",
                    fingers = _P.inputfingers,
                    connectsource = true,
                    connectsourcewidth = _P.inputdrainsourcewidth,
                    connectsourcespace = _P.inputdrainsourcespace,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = _P.latchinterconnectwidth,
                    connectdrainspace = (_P.separation - _P.latchinterconnectwidth) / 2,
                    drainstartmetal = _P.latchstartmetal,
                    drainendmetal = _P.latchendmetal,
                    drawbotgatecut = false,
                },
                {
                    name = "outerinputpdummyright",
                    fingers = _P.outerdummies,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                    drawstopgatetopgatecut = true,
                    drawstopgatebotgatecut = true,
                },
            },
        }),
        util.add_options(pmosoptions, { -- second pmos row (clock)
            width = _P.pmosclockfingerwidth,
            drainalign = "top",
            gtopext = _P.separation / 2,
            sourceviasize = _P.pmosclockdrainsourcesize,
            drainviasize = _P.pmosclockdrainsourcesize,
            devices = {
                {
                    name = "outerclockpdummyleft",
                    fingers = _P.outerdummies,
                    sourcesize = _P.pmosclockdummydrainsourcesize,
                    drainsize = _P.pmosclockdummydrainsourcesize,
                    sourceviasize = _P.pmosclockdummydrainsourcesize,
                    drainviasize = _P.pmosclockdummydrainsourcesize,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    drainmetal = 2,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    connectdraininverse = true,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                    drawstopgatetopgatecut = true,
                    drawstopgatebotgatecut = true,
                    drawtopgatecut = false,
                },
                {
                    name = "clockpleft",
                    fingers = _P.clockfingers / 2,
                    drawbotgate = true,
                    botgatewidth = _P.clockgatewidth,
                    botgatespace = 70,
                    botgatemetal = 2,
                    drawbotgatevia = true,
                    connectdrain = true,
                    connectdrainwidth = _P.inputdrainsourcewidth,
                    connectdrainspace = _P.separation - _P.inputdrainsourcewidth - _P.inputdrainsourcespace,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawbotgatecut = true,
                    botgatecutheight = _P.gatecutheight,
                    drawtopgatecut = true,
                    topgatecutheight = _P.gatecutheight,
                },
                {
                    name = "clockpdummymiddle",
                    fingers = middledummyfingers,
                    sourcesize = _P.pmosclockdummydrainsourcesize,
                    drainsize = _P.pmosclockdummydrainsourcesize,
                    sourceviasize = _P.pmosclockdummydrainsourcesize,
                    drainviasize = _P.pmosclockdummydrainsourcesize,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    connectdraininverse = true,
                    drainmetal = 2,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    drawtopgatecut = false,
                },
                {
                    name = "clockpright",
                    fingers = _P.clockfingers / 2,
                    drawbotgate = true,
                    botgatewidth = _P.clockgatewidth,
                    botgatespace = 70,
                    botgatemetal = 2,
                    drawbotgatevia = true,
                    connectdrain = true,
                    connectdrainwidth = _P.inputdrainsourcewidth,
                    connectdrainspace = _P.separation - _P.inputdrainsourcewidth - _P.inputdrainsourcespace,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawbotgatecut = true,
                    drawtopgatecut = true,
                },
                {
                    name = "outerclockpdummyright",
                    fingers = _P.outerdummies,
                    sourcesize = _P.pmosclockdummydrainsourcesize,
                    drainsize = _P.pmosclockdummydrainsourcesize,
                    sourceviasize = _P.pmosclockdummydrainsourcesize,
                    drainviasize = _P.pmosclockdummydrainsourcesize,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    connectdraininverse = true,
                    drainmetal = 2,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                    drawstopgatetopgatecut = true,
                    drawstopgatebotgatecut = true,
                    drawtopgatecut = false,
                },
            },
        }),
    }

    local clockequalizationdummyntemplate = {
        fingers = equalizationdummies,
        sourcesize = _P.nmosclockdummydrainsourcesize,
        drainsize = _P.nmosclockdummydrainsourcesize,
        sourceviasize = _P.nmosclockdummydrainsourcesize,
        drainviasize = _P.nmosclockdummydrainsourcesize,
        connectsource = true,
        connectsourcespace = _P.powerspace,
        connectsourcewidth = _P.powerwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        drainmetal = 2,
        drawtopgatecut = true,
        drawbotgatecut = false,
        drawbotgate = true,
        drawbotgate = true,
        botgatewidth = _P.dummygatecontactwidth,
        botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
        drainalign = "bottom",
    }
    local inputequalizationdummyntemplate = {
        fingers = -equalizationdummies,
        sourcesize = _P.nmosinputfingerwidth,
        drainsize = _P.nmosinputfingerwidth,
        drawbotgate = true,
        botgatewidth = _P.nmosinputdummygatewidth,
        botgatespace = _P.nmosinputdummygatespace,
        botgateleftextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        botgaterightextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        drawtopgatecut = true,
    }
    local clockequalizationdummyptemplate = {
        fingers = equalizationdummies,
        sourcesize = _P.pmosclockdummydrainsourcesize,
        drainsize = _P.pmosclockdummydrainsourcesize,
        sourceviasize = _P.pmosclockdummydrainsourcesize,
        drainviasize = _P.pmosclockdummydrainsourcesize,
        connectsource = true,
        connectsourcespace = _P.powerspace,
        connectsourcewidth = _P.powerwidth,
        drainmetal = 2,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        drawbotgatecut = true,
        drawtopgate = true,
        drawtopgatecut = false,
        topgatewidth = _P.dummygatecontactwidth,
        topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
        drainalign = "top",
    }
    local inputequalizationdummyptemplate = {
        fingers = -equalizationdummies,
        sourcesize = _P.pmosinputfingerwidth,
        drainsize = _P.pmosinputfingerwidth,
        drawtopgate = true,
        topgatewidth = _P.pmosinputdummygatewidth,
        topgatespace = _P.pmosinputdummygatespace,
        topgateleftextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        topgaterightextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        drawbotgatecut = true,
    }

    if equalizationdummies > 0 then -- insert dummies in clock rows
        local entry = aux.clone_shallow(clockequalizationdummyntemplate)
        entry.name = "clockndummyleftleft"
        _insert_before(rowdefinition, "clocknleft", entry)

        local entry = aux.clone_shallow(clockequalizationdummyntemplate)
        entry.name = "clockndummyleftright"
        _insert_after(rowdefinition, "clocknleft", entry)

        local entry = aux.clone_shallow(clockequalizationdummyntemplate)
        entry.name = "clockndummyrightleft"
        _insert_before(rowdefinition, "clocknright", entry)

        local entry = aux.clone_shallow(clockequalizationdummyntemplate)
        entry.name = "clockndummyrightright"
        _insert_after(rowdefinition, "clocknright", entry)

        local entry = aux.clone_shallow(clockequalizationdummyptemplate)
        entry.name = "clockpdummyleftleft"
        _insert_before(rowdefinition, "clockpleft", entry)

        local entry = aux.clone_shallow(clockequalizationdummyptemplate)
        entry.name = "clockpdummyleftright"
        _insert_after(rowdefinition, "clockpleft", entry)

        local entry = aux.clone_shallow(clockequalizationdummyptemplate)
        entry.name = "clockpdummyrightleft"
        _insert_before(rowdefinition, "clockpright", entry)

        local entry = aux.clone_shallow(clockequalizationdummyptemplate)
        entry.name = "clockpdummyrightright"
        _insert_after(rowdefinition, "clockpright", entry)
    elseif equalizationdummies < 0 then -- insert dummies in input rows
        local entry = aux.clone_shallow(inputequalizationdummyntemplate)
        entry.botgaterightextension = xpitch / 2
        entry.name = "clockndummyleftleft"
        _insert_before(rowdefinition, "ninleft", entry)

        local entry = aux.clone_shallow(inputequalizationdummyntemplate)
        entry.botgateleftextension = xpitch / 2
        entry.name = "inputndummyleftright"
        _insert_after(rowdefinition, "ninleft", entry)

        local entry = aux.clone_shallow(inputequalizationdummyntemplate)
        entry.botgaterightextension = xpitch / 2
        entry.name = "inputndummyrightleft"
        _insert_before(rowdefinition, "ninright", entry)

        local entry = aux.clone_shallow(inputequalizationdummyntemplate)
        entry.botgateleftextension = xpitch / 2
        entry.name = "inputndummyrightright"
        _insert_after(rowdefinition, "ninright", entry)

        local entry = aux.clone_shallow(inputequalizationdummyptemplate)
        entry.name = "inputpdummyleftleft"
        entry.topgaterightextension = xpitch / 2
        _insert_before(rowdefinition, "pinleft", entry)

        local entry = aux.clone_shallow(inputequalizationdummyptemplate)
        entry.name = "inputpdummyleftright"
        entry.topgateleftextension = xpitch / 2
        _insert_after(rowdefinition, "pinleft", entry)

        local entry = aux.clone_shallow(inputequalizationdummyptemplate)
        entry.name = "inputpdummyrightleft"
        entry.topgaterightextension = xpitch / 2
        _insert_before(rowdefinition, "pinright", entry)

        local entry = aux.clone_shallow(inputequalizationdummyptemplate)
        entry.name = "inputpdummyrightright"
        entry.topgateleftextension = xpitch / 2
        _insert_after(rowdefinition, "pinright", entry)
    end

    local latch = pcell.create_layout("basic/stacked_mosfet_array", "latch", {
        sdwidth = _P.sdwidth,
        separation = _P.separation,
        rows = rowdefinition,
        splitgates = false,
    })

    -- latch cross-coupling
    geometry.viabltr(latch, 1, _P.latchendmetal,
        latch:get_area_anchor("nlatchleft_drainstrap").bl,
        latch:get_area_anchor("nlatchleft_drainstrap").tr
    )
    geometry.viabltr(latch, 1, _P.latchendmetal,
        latch:get_area_anchor("nlatchright_drainstrap").bl,
        latch:get_area_anchor("nlatchright_drainstrap").tr
    )
    geometry.rectanglebltr(latch, generics.metal(1),
        latch:get_area_anchor("nlatchleft_topgatestrap").br,
        latch:get_area_anchor("nlatchright_drainstrap").tl
    )
    geometry.rectanglebltr(latch, generics.metal(1),
        latch:get_area_anchor("nlatchleft_drainstrap").br,
        latch:get_area_anchor("nlatchright_topgatestrap").tl
    )

    -- latch source connections
    for i = 1, _P.latchfingers + 1, 2 do
        geometry.rectanglebltr(latch, generics.metal(1),
            point.combine_12(
                latch:get_area_anchor(string.format("nlatchleft_sourcedrain%d", i)).bl,
                latch:get_area_anchor("clockndummymiddle_sourcedrain1").tl
            ),
            latch:get_area_anchor(string.format("nlatchleft_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            point.combine_12(
                latch:get_area_anchor(string.format("nlatchright_sourcedrain%d", i)).bl,
                latch:get_area_anchor("clockndummymiddle_sourcedrain1").tl
            ),
            latch:get_area_anchor(string.format("nlatchright_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchleft_sourcedrain%d", i)).tl,
            point.combine_12(
                latch:get_area_anchor(string.format("platchleft_sourcedrain%d", i)).tr,
                latch:get_area_anchor("clockpdummymiddle_sourcedrain1").bl
            )
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchright_sourcedrain%d", i)).tl,
            point.combine_12(
                latch:get_area_anchor(string.format("platchright_sourcedrain%d", i)).tr,
                latch:get_area_anchor("clockpdummymiddle_sourcedrain1").bl
            )
        )
    end

    -- outer dummies source connections
    for i = 1, _P.outerdummies do
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyleft_sourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("outerinputndummyleft_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyright_sourcedrain%d", i + 1)).tl,
            latch:get_area_anchor(string.format("outerinputndummyright_sourcedrain%d", i + 1)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerinputpdummyleft_sourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("outerclockpdummyleft_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerinputpdummyright_sourcedrain%d", i + 1)).tl,
            latch:get_area_anchor(string.format("outerclockpdummyright_sourcedrain%d", i + 1)).br
        )
    end

    -- connect input equalization dummies gates
    if equalizationdummies < 0 then
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor("clockndummymiddle_sourcedrainactive2").bl,
            latch:get_area_anchor("clockndummymiddle_sourcedrainactive2").tr:translate_y(_P.separation - _P.nmosinputdummygatespace)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor("clockndummymiddle_sourcedrainactive-2").bl,
            latch:get_area_anchor("clockndummymiddle_sourcedrainactive-2").tr:translate_y(_P.separation - _P.nmosinputdummygatespace)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor("clockpdummymiddle_sourcedrainactive2").bl:translate_y(-_P.separation + _P.pmosinputdummygatespace),
            latch:get_area_anchor("clockpdummymiddle_sourcedrainactive2").tr
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor("clockpdummymiddle_sourcedrainactive-2").bl:translate_y(-_P.separation + _P.pmosinputdummygatespace),
            latch:get_area_anchor("clockpdummymiddle_sourcedrainactive-2").tr
        )
    end

    -- connect voutp and voutn
    for metal = _P.latchstartmetal, _P.latchendmetal do
        geometry.polygon(latch, generics.metal(metal), {
            latch:get_area_anchor("ninleft_drainstrap").br,
            latch:get_area_anchor("ninleft_drainstrap").br:translate_x(2 * xpitch + _P.latchinterconnectwidth / 2),
            (latch:get_area_anchor("ninleft_drainstrap").br .. latch:get_area_anchor("nlatchleft_drainstrap").bl):translate_x(2 * xpitch + _P.latchinterconnectwidth / 2),
            latch:get_area_anchor("nlatchleft_drainstrap").bl,
            latch:get_area_anchor("nlatchleft_drainstrap").tl,
            (latch:get_area_anchor("ninleft_drainstrap").tr .. latch:get_area_anchor("nlatchleft_drainstrap").tl):translate_x(2 * xpitch - _P.latchinterconnectwidth / 2),
            latch:get_area_anchor("ninleft_drainstrap").tr:translate_x(2 * xpitch - _P.latchinterconnectwidth / 2),
            latch:get_area_anchor("ninleft_drainstrap").tr,
        })
        geometry.polygon(latch, generics.metal(metal), {
            latch:get_area_anchor("nlatchright_drainstrap").br,
            (latch:get_area_anchor("ninright_drainstrap").bl .. latch:get_area_anchor("nlatchright_drainstrap").br):translate_x(-2 * xpitch + _P.latchinterconnectwidth / 2),
            latch:get_area_anchor("ninright_drainstrap").bl:translate_x(-2 * xpitch + _P.latchinterconnectwidth / 2),
            latch:get_area_anchor("ninright_drainstrap").bl,
            latch:get_area_anchor("ninright_drainstrap").tl,
            latch:get_area_anchor("ninright_drainstrap").tl:translate_x(-2 * xpitch - _P.latchinterconnectwidth / 2),
            (latch:get_area_anchor("ninright_drainstrap").tl .. latch:get_area_anchor("nlatchright_drainstrap").tr):translate_x(-2 * xpitch - _P.latchinterconnectwidth / 2),
            latch:get_area_anchor("nlatchright_drainstrap").tr,
        })
    end

    -- clock anchors
    latch:add_area_anchor_bltr("clknleft", latch:get_area_anchor("clocknleft_topgatestrap").bl, latch:get_area_anchor("clocknleft_topgatestrap").tr)
    latch:add_area_anchor_bltr("clknright", latch:get_area_anchor("clockpleft_botgatestrap").bl, latch:get_area_anchor("clockpleft_botgatestrap").tr)
    latch:add_area_anchor_bltr("clkpleft", latch:get_area_anchor("clocknright_topgatestrap").bl, latch:get_area_anchor("clocknright_topgatestrap").tr)
    latch:add_area_anchor_bltr("clkpright", latch:get_area_anchor("clockpright_botgatestrap").bl, latch:get_area_anchor("clockpright_botgatestrap").tr)

    -- input anchors
    latch:add_area_anchor_bltr("Dpgate", latch:get_area_anchor("ninleft_topgatestrap").bl, latch:get_area_anchor("ninleft_topgatestrap").tr)
    latch:add_area_anchor_bltr("Dngate", latch:get_area_anchor("ninright_topgatestrap").bl, latch:get_area_anchor("ninright_topgatestrap").tr)

    -- power rail vias
    geometry.viabltr(latch, 1, 2,
        latch:get_area_anchor("outerclockndummyleft_sourcestrap").bl,
        latch:get_area_anchor("outerclockndummyright_sourcestrap").tr
    )
    geometry.viabltr(latch, 1, 2,
        latch:get_area_anchor("outerclockpdummyleft_sourcestrap").bl,
        latch:get_area_anchor("outerclockpdummyright_sourcestrap").tr
    )

    latch:clear_alignment_box()
    latch:set_alignment_box(
        point.combine_12(
            latch:get_area_anchor("outerclockndummyleft_sourcedrain1").bl,
            latch:get_area_anchor("outerclockndummyleft_sourcestrap").bl
        ),
        point.combine_12(
            latch:get_area_anchor("outerclockpdummyright_sourcedrain-1").br,
            latch:get_area_anchor("outerclockpdummyright_sourcestrap").tr
        ),
        point.combine_12(
            latch:get_area_anchor("outerclockndummyleft_sourcedrain1").br,
            latch:get_area_anchor("outerclockndummyleft_sourcestrap").tl
        ),
        point.combine_12(
            latch:get_area_anchor("outerclockpdummyright_sourcedrain-1").bl,
            latch:get_area_anchor("outerclockpdummyright_sourcestrap").br
        )
    )

    -- internal output anchors
    latch:add_area_anchor_bltr("internal_outp",
        latch:get_area_anchor("platchleft_sourcedrain2").bl,
        latch:get_area_anchor("platchleft_sourcedrain2").tr
    )
    latch:add_area_anchor_bltr("internal_outn",
        latch:get_area_anchor("platchright_sourcedrain-2").bl,
        latch:get_area_anchor("platchright_sourcedrain-2").tr
    )

    -- gate vias
    latch:add_area_anchor_bltr("Dp",
        point.create(
            (
                latch:get_area_anchor(string.format("ninputseparation1_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).l +
                latch:get_area_anchor(string.format("ninputseparation1_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).r
            ) / 2 - _P.clockgatewidth / 2,
            latch:get_area_anchor("pinleft_sourcedrain1").b
        ),
        point.create(
            (
                latch:get_area_anchor(string.format("ninputseparation1_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).l +
                latch:get_area_anchor(string.format("ninputseparation1_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).r
            ) / 2 + _P.clockgatewidth / 2,
            latch:get_area_anchor("pinleft_sourcedrain1").t
        )
    )
    geometry.viabltr(latch, 1, 3,
        latch:get_area_anchor("Dp").bl,
        latch:get_area_anchor("Dp").tr
    )
    geometry.path_2x(latch, generics.metal(1),
        point.combine(
            latch:get_area_anchor("ninleft_topgatestrap").br,
            latch:get_area_anchor("ninleft_topgatestrap").tr
        ),
        point.combine(
            latch:get_area_anchor("Dp").bl,
            latch:get_area_anchor("Dp").br
        ),
        _P.clockgatewidth
    )
    latch:add_area_anchor_bltr("Dn",
        point.create(
            (
                latch:get_area_anchor(string.format("ninputseparation3_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).l +
                latch:get_area_anchor(string.format("ninputseparation3_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).r
            ) / 2 - _P.clockgatewidth / 2,
            latch:get_area_anchor("pinright_sourcedrain1").b
        ),
        point.create(
            (
                latch:get_area_anchor(string.format("ninputseparation3_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).l +
                latch:get_area_anchor(string.format("ninputseparation3_sourcedrainactive%d", math.ceil(_P.latchoutersepfingers / 2) + 1)).r
            ) / 2 + _P.clockgatewidth / 2,
            latch:get_area_anchor("pinright_sourcedrain1").t
        )
    )
    geometry.viabltr(latch, 1, 3,
        latch:get_area_anchor("Dn").bl,
        latch:get_area_anchor("Dn").tr
    )
    geometry.path_2x(latch, generics.metal(1),
        point.combine(
            latch:get_area_anchor("ninright_topgatestrap").bl,
            latch:get_area_anchor("ninright_topgatestrap").tl
        ),
        point.combine(
            latch:get_area_anchor("Dn").bl,
            latch:get_area_anchor("Dn").br
        ),
        _P.clockgatewidth
    )

    -- input gate connections
    for i = 0, _P.addgatemetalnum do
        geometry.rectanglebltr(latch, generics.metal(2 + i),
            latch:get_area_anchor("clocknleft_topgatestrap").bl,
            latch:get_area_anchor("clocknright_topgatestrap").tr
        )
        geometry.rectanglebltr(latch, generics.metal(2 + i),
            latch:get_area_anchor("clockpleft_botgatestrap").bl,
            latch:get_area_anchor("clockpright_botgatestrap").tr
        )
    end

    -- connect left and right parts of latch
    for i = 0, _P.addinputconnectionmetalnum do
        geometry.rectanglebltr(latch, generics.metal(3 + i),
            latch:get_area_anchor("ninleft_sourcestrap").bl,
            latch:get_area_anchor("ninright_sourcestrap").tr
        )
        geometry.rectanglebltr(latch, generics.metal(3 + i),
            latch:get_area_anchor("pinleft_sourcestrap").bl,
            latch:get_area_anchor("pinright_sourcestrap").tr
        )
    end


    -- latch ports (for non-flat layout)
    -- clock ports
    latch:add_port_with_anchor("inp", generics.metalport(2), latch:get_area_anchor("clocknleft_topgatestrap").bl)
    latch:add_port_with_anchor("inn", generics.metalport(2), latch:get_area_anchor("clockpleft_botgatestrap").bl)

    -- data ports
    latch:add_port_with_anchor("Dp", generics.metalport(1), latch:get_area_anchor("Dpgate").bl)
    latch:add_port_with_anchor("Dn", generics.metalport(1), latch:get_area_anchor("Dngate").bl)

    -- power ports
    latch:add_port("vss", generics.metalport(1), latch:get_area_anchor("outerclockndummyleft_sourcestrap").bl)
    latch:add_port("vdd", generics.metalport(1), latch:get_area_anchor("outerclockpdummyleft_sourcestrap").bl)

    -- output ports
    latch:add_port_with_anchor("outp", generics.metalport(4), latch:get_area_anchor("nlatchright_sourcedrain2").tl)
    latch:add_port_with_anchor("outn", generics.metalport(4), latch:get_area_anchor("nlatchleft_sourcedrain2").tl)

    -- placement
    local numlatches = 2^_P.divisionfactor
    local latches = {}
    for i = 1, numlatches do
        if _P.flat then
            latches[i] = latch:copy()
        else
            latches[i] = divider:add_child(latch, string.format("latch_%d", i))
        end
        if i % 2 == 0 then
            latches[i]:mirror_at_xaxis()
        end
        if i > 1 then
            latches[i]:abut_top(latches[i - 1])
            latches[i]:align_left(latches[i - 1])
        end
        divider:inherit_alignment_box(latches[i])
        if _P.flat then
            divider:merge_into(latches[i])
        end
    end

    -- internal connections between latches
    -- FIXME: only done for two latches
    geometry.viabltr(divider, 4, 5,
        latches[2]:get_area_anchor("internal_outp").bl,
        latches[2]:get_area_anchor("internal_outp").tr
    )
    geometry.viabltr(divider, 3, 5,
        latches[1]:get_area_anchor("Dp").bl,
        latches[1]:get_area_anchor("Dp").tr
    )
    geometry.path_3y(divider, generics.metal(5),
        point.combine(
            latches[2]:get_area_anchor("internal_outp").bl,
            latches[2]:get_area_anchor("internal_outp").br
        ),
        point.combine(
            latches[1]:get_area_anchor("Dp").tl,
            latches[1]:get_area_anchor("Dp").tr
        ),
        _P.interconnectionwidth,
        0.95
    )
    geometry.viabltr(divider, 4, 5,
        latches[2]:get_area_anchor("internal_outn").bl,
        latches[2]:get_area_anchor("internal_outn").tr
    )
    geometry.viabltr(divider, 3, 5,
        latches[1]:get_area_anchor("Dn").bl,
        latches[1]:get_area_anchor("Dn").tr
    )
    geometry.path_3y(divider, generics.metal(5),
        point.combine(
            latches[2]:get_area_anchor("internal_outn").bl,
            latches[2]:get_area_anchor("internal_outn").br
        ),
        point.combine(
            latches[1]:get_area_anchor("Dn").tl,
            latches[1]:get_area_anchor("Dn").tr
        ),
        _P.interconnectionwidth,
        0.95
    )
    geometry.viabltr(divider, 3, 4,
        latches[2]:get_area_anchor("Dn").bl,
        latches[2]:get_area_anchor("Dn").tr
    )
    geometry.path_3y(divider, generics.metal(4),
        point.combine(
            latches[1]:get_area_anchor("internal_outp").tl,
            latches[1]:get_area_anchor("internal_outp").tr
        ),
        point.combine(
            latches[2]:get_area_anchor("Dn").bl,
            latches[2]:get_area_anchor("Dn").br
        ),
        _P.interconnectionwidth,
        0.95
    )
    geometry.viabltr(divider, 4, 6,
        latches[1]:get_area_anchor("internal_outn").bl,
        latches[1]:get_area_anchor("internal_outn").tr
    )
    geometry.viabltr(divider, 3, 6,
        latches[2]:get_area_anchor("Dp").bl,
        latches[2]:get_area_anchor("Dp").tr
    )
    geometry.path_3y(divider, generics.metal(6),
        point.combine(
            latches[1]:get_area_anchor("internal_outn").tl,
            latches[1]:get_area_anchor("internal_outn").tr
        ),
        point.combine(
            latches[2]:get_area_anchor("Dp").bl,
            latches[2]:get_area_anchor("Dp").br
        ),
        _P.interconnectionwidth,
        0.95
    )

    -- input lines
    divider:add_area_anchor_bltr("inp_line",
        point.create(
            latches[1]:get_area_anchor("ninputseparation1_sourcedrainactive-2").l - _P.inputlinewidth,
            latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").b
        ),
        point.create(
            latches[1]:get_area_anchor("ninputseparation1_sourcedrainactive-2").l,
            latches[numlatches]:get_area_anchor("outerclockndummyleft_sourcestrap").t
        )
    )
    divider:add_area_anchor_bltr("inn_line",
        point.create(
            latches[1]:get_area_anchor("ninputseparation3_sourcedrainactive2").r,
            latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").b
        ),
        point.create(
            latches[1]:get_area_anchor("ninputseparation3_sourcedrainactive2").r + _P.inputlinewidth,
            latches[numlatches]:get_area_anchor("outerclockndummyleft_sourcestrap").t
        )
    )
    geometry.rectanglebltr(divider, generics.metal(8),
        divider:get_area_anchor("inp_line").bl,
        divider:get_area_anchor("inp_line").tr
    )
    geometry.rectanglebltr(divider, generics.metal(8),
        divider:get_area_anchor("inn_line").bl,
        divider:get_area_anchor("inn_line").tr
    )

    -- input gate connections
    for i = 1, numlatches do
        local clockpidentifier
        local clocknidentifier
        local ptarget
        local ntarget
        if i % 2 == 0 then
            clockpidentifier = "p"
            clocknidentifier = "n"
            ptarget = "bot"
            ntarget = "top"
        else
            clockpidentifier = "n"
            clocknidentifier = "p"
            ptarget = "top"
            ntarget = "bot"
        end
        -- clockp
        geometry.viabltr(divider, 7, 8,
            point.create(
                divider:get_area_anchor("inp_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).b
            ):translate_y(-_P.clockviaextension),
            point.create(
                divider:get_area_anchor("inp_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).t
            ):translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, 2, 7,
            point.create(
                divider:get_area_anchor("inp_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).b
            ),
            point.create(
                divider:get_area_anchor("inp_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).t
            )
        )
        -- clockn
        geometry.viabltr(divider, 7, 8,
            point.create(
                divider:get_area_anchor("inn_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).b
            ):translate_y(-_P.clockviaextension),
            point.create(
                divider:get_area_anchor("inn_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).t
            ):translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, 2, 7,
            point.create(
                divider:get_area_anchor("inn_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).b
            ),
            point.create(
                divider:get_area_anchor("inn_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).t
            )
        )
    end

    -- vdd/vss bar anchors
    for i = 1, numlatches do
        divider:add_area_anchor_bltr(
            string.format("vssbar_%d", i),
            latches[i]:get_area_anchor("outerclockndummyleft_sourcestrap").bl,
            latches[i]:get_area_anchor("outerclockndummyright_sourcestrap").tr
        )
        divider:add_area_anchor_bltr(
            string.format("vddbar_%d", i),
            latches[i]:get_area_anchor("outerclockpdummyleft_sourcestrap").bl,
            latches[i]:get_area_anchor("outerclockpdummyright_sourcestrap").tr
        )
    end

    -- clock ports -- FIXME: hard-coded for numlatches == 2
    divider:add_port_with_anchor("inn", generics.metalport(8), divider:get_area_anchor("inp_line").bl)
    divider:add_port_with_anchor("inp", generics.metalport(8), divider:get_area_anchor("inn_line").bl)

    -- power ports
    for i = 1, numlatches do
        divider:add_port("vss", generics.metalport(1), latches[i]:get_area_anchor("outerclockndummyleft_sourcestrap").bl)
        divider:add_port("vdd", generics.metalport(1), latches[i]:get_area_anchor("outerclockpdummyright_sourcestrap").bl)
    end

    -- output ports
    divider:add_port_with_anchor("outp", generics.metalport(4), latches[numlatches]:get_area_anchor("nlatchleft_sourcedrain2").tl)
    divider:add_port_with_anchor("outn", generics.metalport(4), latches[numlatches]:get_area_anchor("nlatchright_sourcedrain2").tl)
end
