--[[
        Latch implementation:
  VDD ───────────────────────────────────────┬──────────────────────────────────┬───────────────────┐
                                             │                                  │                   │
                                         ║───┘                                  │                   │
                               vclkn o──o║  clockfingers                        │                   │
                                         ║───┐                                  │   latchfingers    │
                                             │                                  │                   │
                                   ┌─────────┴─────────┐                        │                   │
                                   │                   │                        └───║           ║───┘
                               ║───┘                   └───║                        ║o──┐   ┌──o║
                      Dp o────o║       inputfingers        ║o────o Dn           ┌───║   │   │   ║───┐
                               ║───┐                   ┌───║                    │       │   │       │
                                   │                   │               voutp ───┼───────────┤       │
                                   ├── voutp   voutn ──┤                        │       │   │       │
                                   │                   │                        │       ├───────────┼───── voutn
                               ║───┘                   └───║                    │       │   │       │
                      Dp o─────║        inputfingers       ║o────o Dn           └───║   │   │   ║───┘
                               ║───┐                   ┌───║                        ║───┘   └───║
                                   │                   │                        ┌───║           ║───┐
                                   └─────────┬─────────┘                        │                   │
                                             │                                  │                   │
                                         ║───┘                                  │   latchfingers    │
                              vclkp o────║  clockfingers                        │                   │
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
        { "invfingers", { 4, 8, 16 } },
        { "nmosclockfingerwidth", 500 },
        { "pmosclockfingerwidth", 500 },
        { "nmosinputfingerwidth", 500 },
        { "pmosinputfingerwidth", 500 },
        { "nmosclockdrainsourcesize", 500, follow = "nmosclockfingerwidth" },
        { "nmosclockdummydrainsourcesize", 500, follow = "nmosclockfingerwidth" },
        { "nmosinputdrainsourcesize", 500, follow = "nmosinputfingerwidth" },
        { "nmosinputdummygatewidth", technology.get_dimension("Minimum M1 Width") },
        { "nmosinputdummygatespace", technology.get_dimension("Minimum M1 Space") },
        { "pmosclockdrainsourcesize", 500, follow = "pmosclockfingerwidth" },
        { "pmosclockdummydrainsourcesize", 500, follow = "pmosclockfingerwidth" },
        { "pmosinputdrainsourcesize", 500, follow = "pmosinputfingerwidth" },
        { "pmosinputdummygatewidth", technology.get_dimension("Minimum M1 Width") },
        { "pmosinputdummygatespace", technology.get_dimension("Minimum M1 Space") },
        { "nmosinvfingerwidth", 500 },
        { "pmosinvfingerwidth", 500 },
        { "nmosinvdrainsourcesize", 500, follow = "nmosinvfingerwidth" },
        { "pmosinvdrainsourcesize", 500, follow = "pmosinvfingerwidth" },
        { "nmosinvdummydrainsourcesize", 500, follow = "nmosinvfingerwidth" },
        { "pmosinvdummydrainsourcesize", 500, follow = "pmosinvfingerwidth" },
        { "inputinterweavevias", false },
        { "inputinterweaveviasminspace", 0 },
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
        { "clockgatestrapxshift", 0 },
        { "clockgatestrapyshift", 0 },
        { "dummygatecontactwidth", technology.get_dimension("Minimum M1 Width") },
        { "invgatewidth", 60 },
        { "invgatestrapxshift", 0 },
        { "invgatestrapyshift", 0 },
        { "invdrainsourcespace", 60 },
        { "invdrainsourcewidth", 60 },
        { "drawQbuffer", false },
        { "nmosvthtype", 1 },
        { "pmosvthtype", 1 },
        { "nmosflippedwell", false },
        { "pmosflippedwell", false },
        { "clockviaextension", 0 },
        { "latchstartmetal", 4 },
        { "latchendmetal", 5 },
        { "latchviaminwidth", 200 },
        { "bufsepdummies", 2 },
        { "bufmininnerdummies", 4 },
        { "buffershift", 1000 },
        { "clocklinemetal", 8 },
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
        { "drawleftnmoswelltap", false },
        { "drawrightnmoswelltap", false },
        { "drawleftpmoswelltap", false },
        { "drawrightpmoswelltap", false },
        { "connectnmoswelltab", false },
        { "connectpmoswelltap", false },
        { "welltapwidth", 200 },
        { "welltapshrink", 0 },
        { "welltapshift", 500 },
        { "welltapwellextension", 0 },
        { "flat", true },
        { "addgatemetalnum", 0 },
        { "addinputconnectionmetalnum", 0 }
    )
end

function check(_P)
    if (_P.inputfingers % 2) ~= (_P.clockfingers % 2) then
        return false, string.format("inputfingers must be even if clockfingers is even and vice versa (odd/odd) (inputfingers = %d, clockfingers = %d)", _P.inputfingers, _P.clockfingers)
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

local function _make_vdddummy(name, fingers, _P, outerleft, outerright)
    return {
        name = name,
        fingers = fingers,
        drainmetal = 2,
        connectdrain = true,
        connectdraininverse = true,
        drainalign = "bottom",
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        sourcesize = _P.pmosinvdummydrainsourcesize,
        drainsize = _P.pmosinvdummydrainsourcesize,
        drainalign = "top",
        drawtopgate = true,
        topgatewidth = _P.dummygatecontactwidth,
        topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
        drawbotgatecut = true,
        leftpolylines = outerleft and _P.leftpolylines or nil,
        rightpolylines = outerright and _P.rightpolylines or nil,
        drawleftstopgate = outerleft and _P.drawleftstopgate or nil,
        drawrightstopgate = outerright and _P.drawrightstopgate or nil,
        drawstopgatebotgatecut = outerleft or outerright,
    }
end

local function _make_vssdummy(name, fingers, _P, outerleft, outerright)
    return {
        name = name,
        fingers = fingers,
        drainmetal = 2,
        connectdrain = true,
        connectdraininverse = true,
        drainalign = "bottom",
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        sourcesize = _P.nmosinvdummydrainsourcesize,
        drainsize = _P.nmosinvdummydrainsourcesize,
        drainalign = "top",
        drawbotgate = true,
        botgatewidth = _P.dummygatecontactwidth,
        botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
        drawtopgatecut = true,
        leftpolylines = outerleft and _P.leftpolylines or nil,
        rightpolylines = outerright and _P.rightpolylines or nil,
        drawleftstopgate = outerleft and _P.drawleftstopgate or nil,
        drawrightstopgate = outerright and _P.drawrightstopgate or nil,
        drawstopgatetopgatecut = outerleft or outerright,
    }
end

local function _make_invpmos(name, fingers, _P)
    return {
        name = name,
        fingers = fingers,
        connectdrain = true,
        connectdrainwidth = _P.invdrainsourcewidth,
        connectdrainspace = _P.invdrainsourcespace,
        drainmetal = 3,
        drawbotgate = true,
        botgatewidth = _P.invgatewidth,
        botgatespace = (_P.separation - _P.invgatewidth) / 2,
        botgatemetal = 2,
        drawbotgatevia = true,
    }
end

local function _make_invnmos(name, fingers, _P)
    return {
        name = name,
        fingers = fingers,
        connectdrain = true,
        connectdrainwidth = _P.invdrainsourcewidth,
        connectdrainspace = _P.invdrainsourcespace,
        drainmetal = 3,
        drawtopgate = true,
        topgatewidth = _P.invgatewidth,
        topgatespace = (_P.separation - _P.invgatewidth) / 2,
        topgatemetal = 2,
        drawtopgatevia = true,
    }
end

function layout(divider, _P)
    local xpitch = _P.gatelength + _P.gatespace
    local equalizationdummies = (_P.inputfingers - _P.clockfingers) / 2
    local middledummyfingers = 2 * _P.latchoutersepfingers + _P.latchinnersepfingers + 2 * _P.latchfingers
    local allfingers = 2 * _P.outerdummies + 2 * _P.clockfingers + 2 * _P.latchoutersepfingers + _P.latchinnersepfingers + 2 * _P.latchfingers
    if equalizationdummies > 0 then
        allfingers = allfingers + 4 * equalizationdummies
    end

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
        extendimplanttop = _P.powerspace + _P.powerwidth / 2 + _P.gatestopextension + _P.implanttopextension,
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
                    fingers = _P.clockfingers,
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
                    excludesourcedraincontacts = { 1, middledummyfingers + 1 },
                },
                {
                    name = "clocknright",
                    fingers = _P.clockfingers,
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
                    interweavevias = _P.inputinterweavevias,
                    minviayspace = _P.inputinterweaveviasminspace,
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
                    drainviasize = _P.nmosinputfingerwidth,
                    sourceviasize = _P.nmosinputfingerwidth,
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
                    drainviasize = _P.nmosinputfingerwidth,
                    sourceviasize = _P.nmosinputfingerwidth,
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
                    interweavevias = _P.inputinterweavevias,
                    minviayspace = _P.inputinterweaveviasminspace,
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
                    interweavevias = _P.inputinterweavevias,
                    minviayspace = _P.inputinterweaveviasminspace,
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
                    drainviasize = _P.pmosinputfingerwidth,
                    sourceviasize = _P.pmosinputfingerwidth,
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
                    drainviasize = _P.pmosinputfingerwidth,
                    sourceviasize = _P.pmosinputfingerwidth,
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
                    interweavevias = _P.inputinterweavevias,
                    minviayspace = _P.inputinterweaveviasminspace,
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
                    fingers = _P.clockfingers,
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
                    excludesourcedraincontacts = { 1, middledummyfingers + 1 },
                },
                {
                    name = "clockpright",
                    fingers = _P.clockfingers,
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
        fingers = 2 * equalizationdummies,
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
        excludesourcedraincontacts = { 1, 2 * equalizationdummies + 1 },
    }
    local inputequalizationdummyntemplate = {
        fingers = -2 * equalizationdummies,
        sourcesize = _P.nmosinputfingerwidth,
        drainsize = _P.nmosinputfingerwidth,
        drawbotgate = true,
        botgatewidth = _P.nmosinputdummygatewidth,
        botgatespace = _P.nmosinputdummygatespace,
        botgateleftextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        botgaterightextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        drawtopgatecut = true,
        excludesourcedraincontacts = { 1, 2 * equalizationdummies + 1 },
    }
    local clockequalizationdummyptemplate = {
        fingers = 2 * equalizationdummies,
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
        excludesourcedraincontacts = { 1, 2 * equalizationdummies + 1 },
    }
    local inputequalizationdummyptemplate = {
        fingers = -2 * equalizationdummies,
        sourcesize = _P.pmosinputfingerwidth,
        drainsize = _P.pmosinputfingerwidth,
        drawtopgate = true,
        topgatewidth = _P.pmosinputdummygatewidth,
        topgatespace = _P.pmosinputdummygatespace,
        topgateleftextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        topgaterightextension = (_P.gatespace - _P.sdwidth) / 2 + _P.gatelength + _P.gatespace,
        drawbotgatecut = true,
        excludesourcedraincontacts = { 1, 2 * equalizationdummies + 1 },
    }

    if equalizationdummies > 0 then -- insert dummies in clock rows
        local entry = aux.clone_shallow(clockequalizationdummyntemplate)
        entry.name = "clockndummyleftleft"
        _insert_before(rowdefinition, "clocknleft", entry)

        local entry = aux.clone_shallow(clockequalizationdummyntemplate)
        entry.name = "clockndummyrightright"
        _insert_after(rowdefinition, "clocknright", entry)

        local entry = aux.clone_shallow(clockequalizationdummyptemplate)
        entry.name = "clockpdummyleftleft"
        _insert_before(rowdefinition, "clockpleft", entry)

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
        entry.name = "inputndummyrightright"
        _insert_after(rowdefinition, "ninright", entry)

        local entry = aux.clone_shallow(inputequalizationdummyptemplate)
        entry.name = "inputpdummyleftleft"
        entry.topgaterightextension = xpitch / 2
        _insert_before(rowdefinition, "pinleft", entry)

        local entry = aux.clone_shallow(inputequalizationdummyptemplate)
        entry.name = "inputpdummyrightright"
        entry.topgateleftextension = xpitch / 2
        _insert_after(rowdefinition, "pinright", entry)
    end

    local latch = pcell.create_layout(
        "basic/stacked_mosfet_array",
        string.format("%s_latch", divider:get_name()),
        {
            sdwidth = _P.sdwidth,
            separation = _P.separation,
            rows = rowdefinition,
            splitgates = false,
        }
    )

    -- latch cross-coupling
    if _P.latchfingers * xpitch / 2 + _P.sdwidth < _P.latchviaminwidth then
        geometry.viabltr(latch, 1, _P.latchendmetal,
            point.create(
                latch:get_area_anchor("nlatchleft_drainstrap").r - _P.latchviaminwidth,
                latch:get_area_anchor("nlatchleft_drainstrap").b
            ),
            point.create(
                latch:get_area_anchor("nlatchleft_drainstrap").r,
                latch:get_area_anchor("nlatchleft_drainstrap").t
            )
        )
        geometry.viabltr(latch, 1, _P.latchendmetal,
            point.create(
                latch:get_area_anchor("nlatchright_drainstrap").l,
                latch:get_area_anchor("nlatchright_drainstrap").b
            ),
            point.create(
                latch:get_area_anchor("nlatchright_drainstrap").l + _P.latchviaminwidth,
                latch:get_area_anchor("nlatchright_drainstrap").t
            )
        )
    else
        geometry.viabltr(latch, 1, _P.latchendmetal,
            latch:get_area_anchor("nlatchleft_drainstrap").bl,
            latch:get_area_anchor("nlatchleft_drainstrap").tr
        )
        geometry.viabltr(latch, 1, _P.latchendmetal,
            latch:get_area_anchor("nlatchright_drainstrap").bl,
            latch:get_area_anchor("nlatchright_drainstrap").tr
        )
    end
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

    -- well anchors
    latch:add_area_anchor_bltr("nmos_well",
        latch:get_area_anchor("outerclockndummyleft_well").bl,
        latch:get_area_anchor("outerinputndummyright_well").tr
    )
    latch:add_area_anchor_bltr("pmos_well",
        latch:get_area_anchor("outerinputpdummyleft_well").bl,
        latch:get_area_anchor("outerclockpdummyright_well").tr
    )

    -- implant anchors
    latch:add_area_anchor_bltr("nmos_implant",
        latch:get_area_anchor("outerclockndummyleft_implant").bl,
        latch:get_area_anchor("outerinputndummyright_implant").tr
    )
    latch:add_area_anchor_bltr("pmos_implant",
        latch:get_area_anchor("outerinputpdummyleft_implant").bl,
        latch:get_area_anchor("outerclockpdummyright_implant").tr
    )

    -- power rail anchors and vias
    latch:add_area_anchor_bltr("vssbar",
        latch:get_area_anchor("outerclockndummyleft_sourcestrap").bl,
        latch:get_area_anchor("outerclockndummyright_sourcestrap").tr
    )
    latch:add_area_anchor_bltr("vddbar",
        latch:get_area_anchor("outerclockpdummyleft_sourcestrap").bl,
        latch:get_area_anchor("outerclockpdummyright_sourcestrap").tr
    )
    geometry.viabltr(latch, 1, 2,
        latch:get_area_anchor("vssbar").bl,
        latch:get_area_anchor("vssbar").tr
    )
    geometry.viabltr(latch, 1, 2,
        latch:get_area_anchor("vddbar").bl,
        latch:get_area_anchor("vddbar").tr
    )

    -- well taps
    latch:add_area_anchor_bltr(
        "nmos_well",
        latch:get_area_anchor("outerclockndummyleft_well").bl,
        latch:get_area_anchor("outerclockndummyright_well").tr
    )
    latch:add_area_anchor_bltr(
        "pmos_well",
        latch:get_area_anchor("outerclockpdummyleft_well").bl,
        latch:get_area_anchor("outerclockpdummyright_well").tr
    )
    if _P.drawleftnmoswelltap then
        layouthelpers.place_welltap(
            latch,
            latch:get_area_anchor("nmos_well").bl:translate(-_P.welltapshift - _P.welltapwidth, _P.welltapshrink),
            latch:get_area_anchor("nmos_well").tl:translate(-_P.welltapshift, -_P.welltapshrink),
            "left_nmos_welltap_",
            {
                contype = "n",
            }
        )
        geometry.rectanglebltr(latch, generics.other("nwell"),
            point.create(
                latch:get_area_anchor("left_nmos_welltap_well").l,
                latch:get_area_anchor("nmos_well").b
            ),
            point.create(
                latch:get_area_anchor("nmos_well").l,
                latch:get_area_anchor("nmos_well").t
            )
        )
    end
    if _P.drawleftpmoswelltap then
        layouthelpers.place_welltap(
            latch,
            latch:get_area_anchor("pmos_well").bl:translate(-_P.welltapshift - _P.welltapwidth, _P.welltapshrink),
            latch:get_area_anchor("pmos_well").tl:translate(-_P.welltapshift, -_P.welltapshrink),
            "left_pmos_welltap_",
            {
                contype = "p",
                extendwellleft = _P.welltapwellextension,
            }
        )
        geometry.rectanglebltr(latch, generics.other("pwell"),
            point.create(
                latch:get_area_anchor("left_pmos_welltap_well").l,
                latch:get_area_anchor("pmos_well").b
            ),
            point.create(
                latch:get_area_anchor("pmos_well").l,
                latch:get_area_anchor("pmos_well").t
            )
        )
        geometry.rectanglebltr(latch, generics.other("pimplant"),
            point.create(
                latch:get_area_anchor("left_pmos_welltap_implant").l,
                latch:get_area_anchor("pmos_implant").b
            ),
            point.create(
                latch:get_area_anchor("pmos_implant").l,
                latch:get_area_anchor("pmos_implant").t
            )
        )
        if _P.connectpmoswelltap then
            -- FIXME: currently only support for flipped-well
            if _P.pmosflippedwell then
                geometry.polygon(latch, generics.metal(1), {
                    point.create(
                        latch:get_area_anchor("left_pmos_welltap_boundary").l,
                        latch:get_area_anchor("left_pmos_welltap_boundary").b
                    ),
                    point.create(
                        latch:get_area_anchor("left_pmos_welltap_boundary").l,
                        latch:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        latch:get_area_anchor("vssbar").l,
                        latch:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        latch:get_area_anchor("vssbar").l,
                        latch:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        latch:get_area_anchor("left_pmos_welltap_boundary").r,
                        latch:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        latch:get_area_anchor("left_pmos_welltap_boundary").r,
                        latch:get_area_anchor("left_pmos_welltap_boundary").b
                    ),
                })
            end
        end
    end
    if _P.drawrightnmoswelltap then
        layouthelpers.place_welltap(
            latch,
            latch:get_area_anchor("nmos_well").br:translate(_P.welltapshift, _P.welltapshrink),
            latch:get_area_anchor("nmos_well").tr:translate(_P.welltapshift + _P.welltapwidth, -_P.welltapshrink),
            "right_nmos_welltap_",
            {
                contype = "n",
            }
        )
        geometry.rectanglebltr(latch, generics.other("nwell"),
            point.create(
                latch:get_area_anchor("nmos_well").l,
                latch:get_area_anchor("nmos_well").b
            ),
            point.create(
                latch:get_area_anchor("right_nmos_welltap_well").l,
                latch:get_area_anchor("right_nmos_welltap_well").t
            )
        )
    end
    if _P.drawrightpmoswelltap then
        layouthelpers.place_welltap(
            latch,
            latch:get_area_anchor("pmos_well").br:translate(_P.welltapshift, _P.welltapshrink),
            latch:get_area_anchor("pmos_well").tr:translate(_P.welltapshift + _P.welltapwidth, -_P.welltapshrink),
            "right_pmos_welltap_",
            {
                contype = "p",
                extendwellright = _P.welltapwellextension,
            }
        )
        geometry.rectanglebltr(latch, generics.other("pwell"),
            point.create(
                latch:get_area_anchor("pmos_well").r,
                latch:get_area_anchor("pmos_well").b
            ),
            point.create(
                latch:get_area_anchor("right_pmos_welltap_well").l,
                latch:get_area_anchor("right_pmos_welltap_well").t
            )
        )
        geometry.rectanglebltr(latch, generics.other("pimplant"),
            point.create(
                latch:get_area_anchor("pmos_implant").r,
                latch:get_area_anchor("pmos_implant").b
            ),
            point.create(
                latch:get_area_anchor("right_pmos_welltap_implant").r,
                latch:get_area_anchor("pmos_implant").t
            )
        )
        if _P.connectpmoswelltap then
            -- FIXME: currently only support for flipped-well
            if _P.pmosflippedwell then
                geometry.polygon(latch, generics.metal(1), {
                    point.create(
                        latch:get_area_anchor("right_pmos_welltap_boundary").r,
                        latch:get_area_anchor("right_pmos_welltap_boundary").b
                    ),
                    point.create(
                        latch:get_area_anchor("right_pmos_welltap_boundary").r,
                        latch:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        latch:get_area_anchor("vssbar").r,
                        latch:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        latch:get_area_anchor("vssbar").r,
                        latch:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        latch:get_area_anchor("right_pmos_welltap_boundary").l,
                        latch:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        latch:get_area_anchor("right_pmos_welltap_boundary").l,
                        latch:get_area_anchor("right_pmos_welltap_boundary").b
                    ),
                })
            end
        end
    end

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
        geometry.polygon(latch, generics.metal(2 + i), {
            latch:get_area_anchor("clocknleft_topgatestrap").br,
            latch:get_area_anchor("clocknleft_topgatestrap").br:translate_x(_P.clockgatestrapxshift),
            latch:get_area_anchor("clocknleft_topgatestrap").br:translate(_P.clockgatestrapxshift, -_P.clockgatestrapyshift),
            latch:get_area_anchor("clocknright_topgatestrap").bl:translate(-_P.clockgatestrapxshift, -_P.clockgatestrapyshift),
            latch:get_area_anchor("clocknright_topgatestrap").bl:translate_x(-_P.clockgatestrapxshift),
            latch:get_area_anchor("clocknright_topgatestrap").bl,
            latch:get_area_anchor("clocknright_topgatestrap").tl,
            latch:get_area_anchor("clocknright_topgatestrap").tl:translate_x(-(_P.clockgatestrapxshift + _P.clockgatewidth)),
            latch:get_area_anchor("clocknright_topgatestrap").tl:translate(-(_P.clockgatestrapxshift + _P.clockgatewidth), -_P.clockgatestrapyshift),
            latch:get_area_anchor("clocknleft_topgatestrap").tr:translate((_P.clockgatestrapxshift + _P.clockgatewidth), -_P.clockgatestrapyshift),
            latch:get_area_anchor("clocknleft_topgatestrap").tr:translate_x((_P.clockgatestrapxshift + _P.clockgatewidth)),
            latch:get_area_anchor("clocknleft_topgatestrap").tr,
        })
        geometry.polygon(latch, generics.metal(2 + i), {
            latch:get_area_anchor("clockpleft_botgatestrap").br,
            latch:get_area_anchor("clockpleft_botgatestrap").br:translate_x(_P.clockgatestrapxshift + _P.clockgatewidth),
            latch:get_area_anchor("clockpleft_botgatestrap").br:translate(_P.clockgatestrapxshift + _P.clockgatewidth, _P.clockgatestrapyshift),
            latch:get_area_anchor("clockpright_botgatestrap").bl:translate(-(_P.clockgatestrapxshift + _P.clockgatewidth), _P.clockgatestrapyshift),
            latch:get_area_anchor("clockpright_botgatestrap").bl:translate_x(-(_P.clockgatestrapxshift + _P.clockgatewidth)),
            latch:get_area_anchor("clockpright_botgatestrap").bl,
            latch:get_area_anchor("clockpright_botgatestrap").tl,
            latch:get_area_anchor("clockpright_botgatestrap").tl:translate_x(-_P.clockgatestrapxshift),
            latch:get_area_anchor("clockpright_botgatestrap").tl:translate(-_P.clockgatestrapxshift, _P.clockgatestrapyshift),
            latch:get_area_anchor("clockpleft_botgatestrap").tr:translate(_P.clockgatestrapxshift, _P.clockgatestrapyshift),
            latch:get_area_anchor("clockpleft_botgatestrap").tr:translate_x(_P.clockgatestrapxshift),
            latch:get_area_anchor("clockpleft_botgatestrap").tr,
        })
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

    -- buffer mosfet array
    local numbuf = #_P.invfingers
    local allinvfingers = util.sum(_P.invfingers)
    local bufrowdefinition = {}
    local buffactor = _P.drawQbuffer and 2 or 1
    local bufinnerdummies = _P.bufsepdummies
    local bufouterdummies = (allfingers - 2 * buffactor * allinvfingers - 2 * buffactor * (numbuf - 1) * _P.bufsepdummies - bufinnerdummies) / 2
    while (bufouterdummies % 4 ~= 0) or (bufinnerdummies < _P.bufmininnerdummies) do
        bufouterdummies = bufouterdummies - 1
        bufinnerdummies = bufinnerdummies + 2
    end
    local invndevices = {}
    table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyleft_1", numbuf + 1), bufouterdummies / 2, _P, true, false)) -- outer left dummy
    if _P.drawQbuffer then
        for i = numbuf, 1, -1 do
            local fingers = _P.invfingers[i]
            table.insert(invndevices, _make_invnmos(string.format("invQn%dleft", i), fingers, _P))
            if i > 1 then
                table.insert(invndevices, _make_vssdummy(string.format("invQn%ddummyleft", i), _P.bufsepdummies, _P))
            end
        end
    end
    table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyleft_2", numbuf + 1), bufouterdummies / 2, _P)) -- outer left dummy
    for i = numbuf, 1, -1 do
        local fingers = _P.invfingers[i]
        table.insert(invndevices, _make_invnmos(string.format("invn%dleft", i), fingers, _P))
        if i > 1 then
            table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyleft", i), _P.bufsepdummies, _P))
        end
    end
    table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyright", 1), bufinnerdummies, _P))
    for i = 1, numbuf, 1 do
        local fingers = _P.invfingers[i]
        table.insert(invndevices, _make_invnmos(string.format("invn%dright", i), fingers, _P))
        if i == numbuf then
            table.insert(invndevices, _make_vssdummy(string.format("invxn%ddummyright_1", i + 1), bufouterdummies / 2, _P)) -- outer right dummy
        else
            table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyright", i + 1), _P.bufsepdummies, _P))
        end
    end
    if _P.drawQbuffer then
        for i = 1, numbuf, 1 do
            local fingers = _P.invfingers[i]
            table.insert(invndevices, _make_invnmos(string.format("invQn%dright", i), fingers, _P))
            if i == numbuf then
                table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyright_1", i + 1), bufouterdummies / 2, _P, false, true)) -- outer right dummy
            else
                table.insert(invndevices, _make_vssdummy(string.format("invQn%ddummyright", i + 1), _P.bufsepdummies, _P))
            end
        end
    else
        table.insert(invndevices, _make_vssdummy(string.format("invn%ddummyright_1", numbuf + 1), bufouterdummies / 2, _P, false, true)) -- outer right dummy
    end
    table.insert(bufrowdefinition,
        util.add_options(nmosoptions, {
            width = _P.nmosinvfingerwidth,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            gbotext = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension,
            sourcesize = _P.nmosinvdrainsourcesize,
            drainsize = _P.nmosinvdrainsourcesize,
            devices = invndevices,
        })
    )
    local invpdevices = {}
    table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyleft_1", numbuf + 1), bufouterdummies / 2, _P, true, false)) -- outer left dummy
    if _P.drawQbuffer then
        for i = numbuf, 1, -1 do
            local fingers = _P.invfingers[i]
            table.insert(invpdevices, _make_invpmos(string.format("invQp%dleft", i), fingers, _P))
            if i > 1 then
                table.insert(invpdevices, _make_vdddummy(string.format("invQp%ddummyleft", i), _P.bufsepdummies, _P))
            end
        end
    end
    table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyleft_2", numbuf + 1), bufouterdummies / 2, _P, false, false)) -- outer left dummy
    for i = numbuf, 1, -1 do
        local fingers = _P.invfingers[i]
        table.insert(invpdevices, _make_invpmos(string.format("invp%dleft", i), fingers, _P))
        if i > 1 then
            table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyleft", i), _P.bufsepdummies, _P))
        end
    end
    table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyright", 1), bufinnerdummies, _P))
    for i = 1, numbuf, 1 do
        local fingers = _P.invfingers[i]
        table.insert(invpdevices, _make_invpmos(string.format("invp%dright", i), fingers, _P))
        if i == numbuf then
            table.insert(invpdevices, _make_vdddummy(string.format("invxp%ddummyright_1", i + 1), bufouterdummies / 2, _P)) -- outer right dummy
        else
            table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyright", i + 1), _P.bufsepdummies, _P))
        end
    end
    if _P.drawQbuffer then
        for i = 1, numbuf, 1 do
            local fingers = _P.invfingers[i]
            table.insert(invpdevices, _make_invpmos(string.format("invQp%dright", i), fingers, _P))
            if i == numbuf then
                table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyright_1", i + 1), bufouterdummies / 2, _P, false, true)) -- outer right dummy
            else
                table.insert(invpdevices, _make_vdddummy(string.format("invQp%ddummyright", i + 1), _P.bufsepdummies, _P))
            end
        end
    else
        table.insert(invpdevices, _make_vdddummy(string.format("invp%ddummyright_1", numbuf + 1), bufouterdummies / 2, _P, false, true)) -- outer right dummy
    end
    table.insert(bufrowdefinition,
        util.add_options(pmosoptions, {
            width = _P.pmosinvfingerwidth,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            gtopext = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension,
            sourcesize = _P.pmosinvdrainsourcesize,
            drainsize = _P.pmosinvdrainsourcesize,
            devices = invpdevices,
        })
    )

    local bufferref = pcell.create_layout(
        "basic/stacked_mosfet_array",
        string.format("%s_buffer", divider:get_name()),
        {
            sdwidth = _P.sdwidth,
            separation = _P.separation,
            rows = bufrowdefinition,
            splitgates = false,
        }
    )

    -- buffer power rail anchors and vias
    bufferref:add_area_anchor_bltr("vssbar",
        bufferref:get_area_anchor(string.format("invn%ddummyleft_1_sourcestrap", numbuf + 1)).bl,
        bufferref:get_area_anchor(string.format("invn%ddummyright_1_sourcestrap", numbuf + 1)).tr
    )
    bufferref:add_area_anchor_bltr("vddbar",
        bufferref:get_area_anchor(string.format("invp%ddummyleft_1_sourcestrap", numbuf + 1)).bl,
        bufferref:get_area_anchor(string.format("invp%ddummyright_1_sourcestrap", numbuf + 1)).tr
    )
    geometry.viabltr(bufferref, 1, 2,
        bufferref:get_area_anchor("vssbar").bl,
        bufferref:get_area_anchor("vssbar").tr
    )
    geometry.viabltr(bufferref, 1, 2,
        bufferref:get_area_anchor("vddbar").bl,
        bufferref:get_area_anchor("vddbar").tr
    )

    -- buffer well anchors
    bufferref:add_area_anchor_bltr("nmos_well",
        bufferref:get_area_anchor(string.format("invn%ddummyleft_1_well", numbuf + 1)).bl,
        bufferref:get_area_anchor(string.format("invn%ddummyright_1_well", numbuf + 1)).tr
    )
    bufferref:add_area_anchor_bltr("pmos_well",
        bufferref:get_area_anchor(string.format("invp%ddummyleft_1_well", numbuf + 1)).bl,
        bufferref:get_area_anchor(string.format("invp%ddummyright_1_well", numbuf + 1)).tr
    )

    -- buffer implant anchors
    bufferref:add_area_anchor_bltr("nmos_implant",
        bufferref:get_area_anchor(string.format("invn%ddummyleft_1_implant", numbuf + 1)).bl,
        bufferref:get_area_anchor(string.format("invn%ddummyright_1_implant", numbuf + 1)).tr
    )
    bufferref:add_area_anchor_bltr("pmos_implant",
        bufferref:get_area_anchor(string.format("invp%ddummyleft_1_implant", numbuf + 1)).bl,
        bufferref:get_area_anchor(string.format("invp%ddummyright_1_implant", numbuf + 1)).tr
    )

    -- buffer input anchors
    bufferref:add_area_anchor_bltr("inp",
        bufferref:get_area_anchor(string.format("invn%dleft_topgatestrap", 1)).bl,
        bufferref:get_area_anchor(string.format("invn%dleft_topgatestrap", 1)).tr
    )
    bufferref:add_area_anchor_bltr("inn",
        bufferref:get_area_anchor(string.format("invn%dright_topgatestrap", 1)).bl,
        bufferref:get_area_anchor(string.format("invn%dright_topgatestrap", 1)).tr
    )

    -- buffer output anchors
    for i = 1, numbuf do
        bufferref:add_area_anchor_bltr(string.format("outp_%d", i),
            point.create(
                bufferref:get_area_anchor(string.format("invn%dleft_sourcedrain2", i)).r - 2 * xpitch - _P.invgatewidth,
                bufferref:get_area_anchor(string.format("invn%dleft_drainstrap", i)).t
            ),
            point.create(
                bufferref:get_area_anchor(string.format("invn%dleft_sourcedrain2", i)).r - 2 * xpitch,
                bufferref:get_area_anchor(string.format("invp%dleft_drainstrap", i)).b
            )
        )
        bufferref:add_area_anchor_bltr(string.format("outn_%d", i),
            point.create(
                bufferref:get_area_anchor(string.format("invn%dright_sourcedrain-2", i)).l + 2 * xpitch,
                bufferref:get_area_anchor(string.format("invn%dright_drainstrap", i)).t
            ),
            point.create(
                bufferref:get_area_anchor(string.format("invn%dright_sourcedrain-2", i)).l + 2 * xpitch + _P.invgatewidth,
                bufferref:get_area_anchor(string.format("invp%dright_drainstrap", i)).b
            )
        )
    end

    -- buffer outputs
    for i = 1, numbuf do
        if i < numbuf then
            geometry.viabltr(bufferref, 2, 3,
                bufferref:get_area_anchor(string.format("outp_%d", i)).bl,
                bufferref:get_area_anchor(string.format("outp_%d", i)).tr
            )
        else
            geometry.rectanglebltr(bufferref, generics.metal(3),
                bufferref:get_area_anchor(string.format("outp_%d", i)).bl,
                bufferref:get_area_anchor(string.format("outp_%d", i)).tr
            )
        end
        geometry.rectanglebltr(bufferref, generics.metal(3),
            point.create(
                bufferref:get_area_anchor(string.format("outp_%d", i)).l,
                bufferref:get_area_anchor(string.format("invn%dleft_drainstrap", i)).b
            ),
            bufferref:get_area_anchor(string.format("invn%dleft_drainstrap", i)).tl
        )
        geometry.rectanglebltr(bufferref, generics.metal(3),
            point.create(
                bufferref:get_area_anchor(string.format("outp_%d", i)).l,
                bufferref:get_area_anchor(string.format("invp%dleft_drainstrap", i)).b
            ),
            bufferref:get_area_anchor(string.format("invp%dleft_drainstrap", i)).tl
        )
        if i < numbuf then
            geometry.viabltr(bufferref, 2, 3,
                bufferref:get_area_anchor(string.format("outn_%d", i)).bl,
                bufferref:get_area_anchor(string.format("outn_%d", i)).tr
            )
        else
            geometry.rectanglebltr(bufferref, generics.metal(3),
                bufferref:get_area_anchor(string.format("outn_%d", i)).bl,
                bufferref:get_area_anchor(string.format("outn_%d", i)).tr
            )
        end
        geometry.rectanglebltr(bufferref, generics.metal(3),
            bufferref:get_area_anchor(string.format("invn%dright_drainstrap", i)).bl,
            point.create(
                bufferref:get_area_anchor(string.format("outn_%d", i)).r,
                bufferref:get_area_anchor(string.format("invn%dright_drainstrap", i)).t
            )
        )
        geometry.rectanglebltr(bufferref, generics.metal(3),
            bufferref:get_area_anchor(string.format("invp%dright_drainstrap", i)).br,
            point.create(
                bufferref:get_area_anchor(string.format("outn_%d", i)).r,
                bufferref:get_area_anchor(string.format("invp%dright_drainstrap", i)).t
            )
        )
    end

    -- inputs
    for i = 2, numbuf do
        geometry.rectanglebltr(bufferref, generics.metal(2),
            bufferref:get_area_anchor(string.format("invn%dleft_topgatestrap", i)).bl,
            point.create(
                bufferref:get_area_anchor(string.format("outp_%d", i - 1)).l,
                bufferref:get_area_anchor(string.format("invn%dleft_topgatestrap", i)).t
            )
        )
        geometry.rectanglebltr(bufferref, generics.metal(2),
            point.create(
                bufferref:get_area_anchor(string.format("outn_%d", i - 1)).r,
                bufferref:get_area_anchor(string.format("invn%dright_topgatestrap", i)).b
            ),
            bufferref:get_area_anchor(string.format("invn%dright_topgatestrap", i)).tl
        )
    end

    if _P.drawQbuffer then
        -- buffer input anchors
        bufferref:add_area_anchor_bltr("inQp",
            bufferref:get_area_anchor(string.format("invQn%dleft_topgatestrap", 1)).bl,
            bufferref:get_area_anchor(string.format("invQn%dleft_topgatestrap", 1)).tr
        )
        bufferref:add_area_anchor_bltr("inQn",
            bufferref:get_area_anchor(string.format("invQn%dright_topgatestrap", 1)).bl,
            bufferref:get_area_anchor(string.format("invQn%dright_topgatestrap", 1)).tr
        )

        -- buffer output anchors
        for i = 1, numbuf do
            bufferref:add_area_anchor_bltr(string.format("outQp_%d", i),
                point.create(
                    bufferref:get_area_anchor(string.format("invQn%dleft_sourcedrain2", i)).r - 2 * xpitch - _P.invgatewidth,
                    bufferref:get_area_anchor(string.format("invQn%dleft_drainstrap", i)).t
                ),
                point.create(
                    bufferref:get_area_anchor(string.format("invQn%dleft_sourcedrain2", i)).r - 2 * xpitch,
                    bufferref:get_area_anchor(string.format("invQp%dleft_drainstrap", i)).b
                )
            )
            bufferref:add_area_anchor_bltr(string.format("outQn_%d", i),
                point.create(
                    bufferref:get_area_anchor(string.format("invQn%dright_sourcedrain-2", i)).l + 2 * xpitch,
                    bufferref:get_area_anchor(string.format("invQn%dright_drainstrap", i)).t
                ),
                point.create(
                    bufferref:get_area_anchor(string.format("invQn%dright_sourcedrain-2", i)).l + 2 * xpitch + _P.invgatewidth,
                    bufferref:get_area_anchor(string.format("invQp%dright_drainstrap", i)).b
                )
            )
        end

        -- buffer outputs
        for i = 1, numbuf do
            if i < numbuf then
                geometry.viabltr(bufferref, 2, 3,
                    bufferref:get_area_anchor(string.format("outQp_%d", i)).bl,
                    bufferref:get_area_anchor(string.format("outQp_%d", i)).tr
                )
            else
                geometry.rectanglebltr(bufferref, generics.metal(3),
                    bufferref:get_area_anchor(string.format("outQp_%d", i)).bl,
                    bufferref:get_area_anchor(string.format("outQp_%d", i)).tr
                )
            end
            geometry.rectanglebltr(bufferref, generics.metal(3),
                point.create(
                    bufferref:get_area_anchor(string.format("outQp_%d", i)).l,
                    bufferref:get_area_anchor(string.format("invQn%dleft_drainstrap", i)).b
                ),
                bufferref:get_area_anchor(string.format("invQn%dleft_drainstrap", i)).tl
            )
            geometry.rectanglebltr(bufferref, generics.metal(3),
                point.create(
                    bufferref:get_area_anchor(string.format("outQp_%d", i)).l,
                    bufferref:get_area_anchor(string.format("invQp%dleft_drainstrap", i)).b
                ),
                bufferref:get_area_anchor(string.format("invQp%dleft_drainstrap", i)).tl
            )
            if i < numbuf then
                geometry.viabltr(bufferref, 2, 3,
                    bufferref:get_area_anchor(string.format("outQn_%d", i)).bl,
                    bufferref:get_area_anchor(string.format("outQn_%d", i)).tr
                )
            else
                geometry.rectanglebltr(bufferref, generics.metal(3),
                    bufferref:get_area_anchor(string.format("outQn_%d", i)).bl,
                    bufferref:get_area_anchor(string.format("outQn_%d", i)).tr
                )
            end
            geometry.rectanglebltr(bufferref, generics.metal(3),
                bufferref:get_area_anchor(string.format("invQn%dright_drainstrap", i)).bl,
                point.create(
                    bufferref:get_area_anchor(string.format("outQn_%d", i)).r,
                    bufferref:get_area_anchor(string.format("invQn%dright_drainstrap", i)).t
                )
            )
            geometry.rectanglebltr(bufferref, generics.metal(3),
                bufferref:get_area_anchor(string.format("invQp%dright_drainstrap", i)).br,
                point.create(
                    bufferref:get_area_anchor(string.format("outQn_%d", i)).r,
                    bufferref:get_area_anchor(string.format("invQp%dright_drainstrap", i)).t
                )
            )
        end

        -- inputs
        for i = 2, numbuf do
            geometry.rectanglebltr(bufferref, generics.metal(2),
                bufferref:get_area_anchor(string.format("invQn%dleft_topgatestrap", i)).bl,
                point.create(
                    bufferref:get_area_anchor(string.format("outQp_%d", i - 1)).l,
                    bufferref:get_area_anchor(string.format("invQn%dleft_topgatestrap", i)).t
                )
            )
            geometry.rectanglebltr(bufferref, generics.metal(2),
                point.create(
                    bufferref:get_area_anchor(string.format("outQn_%d", i - 1)).r,
                    bufferref:get_area_anchor(string.format("invQn%dright_topgatestrap", i)).b
                ),
                bufferref:get_area_anchor(string.format("invQn%dright_topgatestrap", i)).tl
            )
        end
    end

    -- buffer well taps
    if _P.drawleftnmoswelltap then
        layouthelpers.place_welltap(
            bufferref,
            bufferref:get_area_anchor("nmos_well").bl:translate(-_P.welltapshift - _P.welltapwidth, _P.welltapshrink),
            bufferref:get_area_anchor("nmos_well").tl:translate(-_P.welltapshift, -_P.welltapshrink),
            "left_nmos_welltap_",
            {
                contype = "n",
            }
        )
        geometry.rectanglebltr(bufferref, generics.other("nwell"),
            point.create(
                bufferref:get_area_anchor("left_nmos_welltap_well").l,
                bufferref:get_area_anchor("nmos_well").b
            ),
            point.create(
                bufferref:get_area_anchor("nmos_well").l,
                bufferref:get_area_anchor("nmos_well").t
            )
        )
    end
    if _P.drawleftpmoswelltap then
        layouthelpers.place_welltap(
            bufferref,
            bufferref:get_area_anchor("pmos_well").bl:translate(-_P.welltapshift - _P.welltapwidth, _P.welltapshrink),
            bufferref:get_area_anchor("pmos_well").tl:translate(-_P.welltapshift, -_P.welltapshrink),
            "left_pmos_welltap_",
            {
                contype = "p",
                extendwellleft = _P.welltapwellextension,
            }
        )
        geometry.rectanglebltr(bufferref, generics.other("pwell"),
            point.create(
                bufferref:get_area_anchor("left_pmos_welltap_well").l,
                bufferref:get_area_anchor("pmos_well").b
            ),
            point.create(
                bufferref:get_area_anchor("pmos_well").l,
                bufferref:get_area_anchor("pmos_well").t
            )
        )
        geometry.rectanglebltr(bufferref, generics.other("pimplant"),
            point.create(
                bufferref:get_area_anchor("left_pmos_welltap_implant").l,
                bufferref:get_area_anchor("pmos_implant").b
            ),
            point.create(
                bufferref:get_area_anchor("pmos_implant").l,
                bufferref:get_area_anchor("pmos_implant").t
            )
        )
        if _P.connectpmoswelltap then
            -- FIXME: currently only support for flipped-well
            if _P.pmosflippedwell then
                geometry.polygon(bufferref, generics.metal(1), {
                    point.create(
                        bufferref:get_area_anchor("left_pmos_welltap_boundary").l,
                        bufferref:get_area_anchor("left_pmos_welltap_boundary").b
                    ),
                    point.create(
                        bufferref:get_area_anchor("left_pmos_welltap_boundary").l,
                        bufferref:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        bufferref:get_area_anchor("vssbar").l,
                        bufferref:get_area_anchor("vssbar").b
                    ),
                    point.create(
                        bufferref:get_area_anchor("vssbar").l,
                        bufferref:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        bufferref:get_area_anchor("left_pmos_welltap_boundary").r,
                        bufferref:get_area_anchor("vssbar").t
                    ),
                    point.create(
                        bufferref:get_area_anchor("left_pmos_welltap_boundary").r,
                        bufferref:get_area_anchor("left_pmos_welltap_boundary").b
                    ),
                })
            end
        end
    end
    if _P.drawrightnmoswelltap then
        layouthelpers.place_welltap(
            bufferref,
            bufferref:get_area_anchor("nmos_well").br:translate(_P.welltapshift, _P.welltapshrink),
            bufferref:get_area_anchor("nmos_well").tr:translate(_P.welltapshift + _P.welltapwidth, -_P.welltapshrink),
            "right_nmos_welltap_",
            {
                contype = "n",
            }
        )
        geometry.rectanglebltr(bufferref, generics.other("nwell"),
            point.create(
                bufferref:get_area_anchor("nmos_well").l,
                bufferref:get_area_anchor("nmos_well").b
            ),
            point.create(
                bufferref:get_area_anchor("right_nmos_welltap_well").l,
                bufferref:get_area_anchor("right_nmos_welltap_well").t
            )
        )
    end
    if _P.drawrightpmoswelltap then
        layouthelpers.place_welltap(
            bufferref,
            bufferref:get_area_anchor("pmos_well").br:translate(_P.welltapshift, _P.welltapshrink),
            bufferref:get_area_anchor("pmos_well").tr:translate(_P.welltapshift + _P.welltapwidth, -_P.welltapshrink),
            "right_pmos_welltap_",
            {
                contype = "p",
                extendwellright = _P.welltapwellextension,
            }
        )
        geometry.rectanglebltr(bufferref, generics.other("pwell"),
            point.create(
                bufferref:get_area_anchor("pmos_well").r,
                bufferref:get_area_anchor("pmos_well").b
            ),
            point.create(
                bufferref:get_area_anchor("right_pmos_welltap_well").r,
                bufferref:get_area_anchor("pmos_well").t
            )
        )
        geometry.rectanglebltr(bufferref, generics.other("pimplant"),
            point.create(
                bufferref:get_area_anchor("pmos_implant").r,
                bufferref:get_area_anchor("pmos_implant").b
            ),
            point.create(
                bufferref:get_area_anchor("right_pmos_welltap_implant").r,
                bufferref:get_area_anchor("pmos_implant").t
            )
        )
        if _P.pmosflippedwell then
            geometry.polygon(bufferref, generics.metal(1), {
                point.create(
                    bufferref:get_area_anchor("right_pmos_welltap_boundary").r,
                    bufferref:get_area_anchor("right_pmos_welltap_boundary").b
                ),
                point.create(
                    bufferref:get_area_anchor("right_pmos_welltap_boundary").r,
                    bufferref:get_area_anchor("vssbar").b
                ),
                point.create(
                    bufferref:get_area_anchor("vssbar").r,
                    bufferref:get_area_anchor("vssbar").b
                ),
                point.create(
                    bufferref:get_area_anchor("vssbar").r,
                    bufferref:get_area_anchor("vssbar").t
                ),
                point.create(
                    bufferref:get_area_anchor("right_pmos_welltap_boundary").l,
                    bufferref:get_area_anchor("vssbar").t
                ),
                point.create(
                    bufferref:get_area_anchor("right_pmos_welltap_boundary").l,
                    bufferref:get_area_anchor("right_pmos_welltap_boundary").b
                ),
            })
        end
    end

    bufferref:clear_alignment_box()
    bufferref:set_alignment_box(
        point.create(
            bufferref:get_area_anchor(string.format("invn%ddummyleft_1_sourcedrain1", numbuf + 1)).l,
            bufferref:get_area_anchor(string.format("invn%ddummyleft_1_sourcestrap", numbuf + 1)).b
        ),
        point.create(
            bufferref:get_area_anchor(string.format("invp%ddummyright_sourcedrain-1", numbuf)).r,
            bufferref:get_area_anchor(string.format("invp%ddummyright_sourcestrap", numbuf)).t
        ),
        point.create(
            bufferref:get_area_anchor(string.format("invn%ddummyleft_1_sourcedrain1", numbuf + 1)).r,
            bufferref:get_area_anchor(string.format("invn%ddummyleft_1_sourcestrap", numbuf + 1)).t
        ),
        point.create(
            bufferref:get_area_anchor(string.format("invp%ddummyright_sourcedrain-1", numbuf)).l,
            bufferref:get_area_anchor(string.format("invp%ddummyright_sourcestrap", numbuf)).b
        )
    )

    local buffer
    if _P.flat then
        buffer = bufferref
    else
        buffer = divider:add_child(bufferref, "buffer")
    end
    buffer:abut_top(latches[numlatches])
    buffer:align_left(latches[numlatches])
    buffer:translate_y(_P.buffershift)
    divider:inherit_alignment_box(buffer)
    if _P.flat then
        divider:merge_into(buffer)
    end

    -- internal connections between latches
    -- FIXME: only done for two latches
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
    geometry.viabltr(divider, 5, 6,
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
            latches[1]:get_area_anchor("clocknleft_topgatestrap").r + _P.clockgatestrapxshift,
            latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").b
        ),
        point.create(
            latches[1]:get_area_anchor("clocknleft_topgatestrap").r + _P.clockgatestrapxshift + _P.inputlinewidth,
            latches[numlatches]:get_area_anchor("outerclockndummyleft_sourcestrap").t
        )
    )
    divider:add_area_anchor_bltr("inn_line",
        point.create(
            latches[1]:get_area_anchor("clocknright_topgatestrap").l - _P.clockgatestrapxshift - _P.inputlinewidth,
            latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").b
        ),
        point.create(
            latches[1]:get_area_anchor("clocknright_topgatestrap").l - _P.clockgatestrapxshift,
            latches[numlatches]:get_area_anchor("outerclockndummyleft_sourcestrap").t
        )
    )
    geometry.rectanglebltr(divider, generics.metal(_P.clocklinemetal),
        divider:get_area_anchor("inp_line").bl,
        divider:get_area_anchor("inp_line").tr
    )
    geometry.rectanglebltr(divider, generics.metal(_P.clocklinemetal),
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
        divider:add_area_anchor_bltr(string.format("clockpvia_%d", i),
            point.create(
                divider:get_area_anchor("inp_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).b
            ):translate_y(-_P.clockviaextension),
            point.create(
                divider:get_area_anchor("inp_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).t
            ):translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, _P.clocklinemetal - 1, _P.clocklinemetal,
            divider:get_area_anchor(string.format("clockpvia_%d", i)).bl,
            divider:get_area_anchor(string.format("clockpvia_%d", i)).tr
        )
        geometry.viabltr(divider, 2, 7,
            point.create(
                divider:get_area_anchor("inp_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).b - _P.clockgatestrapyshift
            ),
            point.create(
                divider:get_area_anchor("inp_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).t - _P.clockgatestrapyshift
            )
        )
        -- clockn
        divider:add_area_anchor_bltr(string.format("clocknvia_%d", i),
            point.create(
                divider:get_area_anchor("inn_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).b
            ):translate_y(-_P.clockviaextension),
            point.create(
                divider:get_area_anchor("inn_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).t
            ):translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, _P.clocklinemetal - 1, _P.clocklinemetal,
            divider:get_area_anchor(string.format("clocknvia_%d", i)).bl,
            divider:get_area_anchor(string.format("clocknvia_%d", i)).tr
        )
        geometry.viabltr(divider, 2, 7,
            point.create(
                divider:get_area_anchor("inn_line").l,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).b + _P.clockgatestrapyshift
            ),
            point.create(
                divider:get_area_anchor("inn_line").r,
                latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).t + _P.clockgatestrapyshift
            )
        )
    end

    -- connect divider to buffers
    geometry.rectanglebltr(divider, generics.metal(4),
        latches[numlatches]:get_area_anchor(string.format("nlatchleft_sourcedrain%d", _P.latchfingers)).tl,
        point.create(
            latches[numlatches]:get_area_anchor(string.format("nlatchleft_sourcedrain%d", _P.latchfingers)).r,
            buffer:get_area_anchor("inp").t
        )
    )
    geometry.rectanglebltr(divider, generics.metal(4),
        latches[numlatches]:get_area_anchor(string.format("nlatchright_sourcedrain%d", 2)).tl,
        point.create(
            latches[numlatches]:get_area_anchor(string.format("nlatchright_sourcedrain%d", 2)).r,
            buffer:get_area_anchor("inn").t
        )
    )
    geometry.viabltr(divider, 2, 4,
        buffer:get_area_anchor("inp").bl,
        point.create(
            latches[numlatches]:get_area_anchor(string.format("nlatchleft_sourcedrain%d", _P.latchfingers)).l,
            buffer:get_area_anchor("inp").t
        )
    )
    geometry.viabltr(divider, 2, 4,
        point.create(
            latches[numlatches]:get_area_anchor(string.format("nlatchright_sourcedrain%d", 2)).r,
            buffer:get_area_anchor("inn").b
        ),
        buffer:get_area_anchor("inn").tr
    )

    -- connect divider to buffers (Q)
    if _P.drawQbuffer then
        geometry.rectanglebltr(divider, generics.metal(6),
            latches[numlatches]:get_area_anchor(string.format("platchleft_sourcedrain%d", _P.latchfingers)).tl,
            point.create(
                latches[numlatches]:get_area_anchor(string.format("nlatchleft_sourcedrain%d", _P.latchfingers)).r,
                buffer:get_area_anchor("inQp").t
            )
        )
        geometry.rectanglebltr(divider, generics.metal(6),
            latches[numlatches]:get_area_anchor(string.format("platchright_sourcedrain%d", 2)).tl,
            point.create(
                latches[numlatches]:get_area_anchor(string.format("nlatchright_sourcedrain%d", 2)).r,
                buffer:get_area_anchor("inQn").t
            )
        )
        geometry.rectanglebltr(divider, generics.metal(6),
            buffer:get_area_anchor("inQp").br,
            point.create(
                latches[numlatches]:get_area_anchor(string.format("nlatchleft_sourcedrain%d", _P.latchfingers)).r,
                buffer:get_area_anchor("inQp").t
            )
        )
        geometry.rectanglebltr(divider, generics.metal(6),
            point.create(
                latches[numlatches]:get_area_anchor(string.format("nlatchright_sourcedrain%d", 2)).l,
                buffer:get_area_anchor("inQn").b
            ),
            buffer:get_area_anchor("inQn").tl
        )
        geometry.viabltr(divider, 3, 6,
            latches[2]:get_area_anchor("Dp").bl,
            latches[2]:get_area_anchor("Dp").tr
        )
        geometry.viabltr(divider, 3, 6,
            latches[2]:get_area_anchor("Dn").bl,
            latches[2]:get_area_anchor("Dn").tr
        )
        geometry.rectanglebltr(divider, generics.metal(6),
            latches[2]:get_area_anchor("Dp").tl,
            point.create(
                latches[numlatches]:get_area_anchor(string.format("platchleft_sourcedrain%d", _P.latchfingers)).r,
                latches[numlatches]:get_area_anchor(string.format("platchleft_sourcedrain%d", _P.latchfingers)).t + _P.sdwidth
            )
        )
        geometry.rectanglebltr(divider, generics.metal(6),
            latches[numlatches]:get_area_anchor(string.format("platchright_sourcedrain%d", _P.latchfingers)).tl,
            point.create(
                latches[2]:get_area_anchor("Dn").r,
                latches[2]:get_area_anchor("Dn").t + _P.sdwidth
            )
        )
        geometry.viabltr(divider, 2, 6,
            buffer:get_area_anchor("inQp").bl,
            buffer:get_area_anchor("inQp").tr
        )
        geometry.viabltr(divider, 2, 6,
            buffer:get_area_anchor("inQn").bl,
            buffer:get_area_anchor("inQn").tr
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
    divider:add_area_anchor_bltr(
        "vssbar_bottom",
        divider:get_area_anchor(string.format("vssbar_%d", 1)).bl,
        divider:get_area_anchor(string.format("vssbar_%d", 1)).tr
    )
    divider:add_area_anchor_bltr(
        "vssbar_top",
        divider:get_area_anchor(string.format("vssbar_%d", numlatches)).bl,
        divider:get_area_anchor(string.format("vssbar_%d", numlatches)).tr
    )
    divider:inherit_area_anchor_as(buffer, "vssbar", "vssbar_buf")
    divider:inherit_area_anchor_as(buffer, "vddbar", "vddbar_buf")

    -- well, implant and soiopen anchors (latch)
    for i = 1, numlatches do
        divider:inherit_area_anchor_as(latches[i], "nmos_well", string.format("nmos_well_%d", i))
        divider:inherit_area_anchor_as(latches[i], "pmos_well", string.format("pmos_well_%d", i))
        divider:inherit_area_anchor_as(latches[i], "nmos_implant", string.format("nmos_implant_%d", i))
        divider:inherit_area_anchor_as(latches[i], "pmos_implant", string.format("pmos_implant_%d", i))
        if _P.drawleftnmoswelltap then
            divider:inherit_area_anchor_as(latches[i], "left_nmos_welltap_boundary", string.format("left_nmos_welltap_boundary_%d", i))
            divider:inherit_area_anchor_as(latches[i], "left_nmos_welltap_implant", string.format("left_nmos_welltap_implant_%d", i))
            divider:inherit_area_anchor_as(latches[i], "left_nmos_welltap_soiopen", string.format("left_nmos_welltap_soiopen_%d", i))
        end
        if _P.drawleftpmoswelltap then
            divider:inherit_area_anchor_as(latches[i], "left_pmos_welltap_boundary", string.format("left_pmos_welltap_boundary_%d", i))
            divider:inherit_area_anchor_as(latches[i], "left_pmos_welltap_implant", string.format("left_pmos_welltap_implant_%d", i))
            divider:inherit_area_anchor_as(latches[i], "left_pmos_welltap_soiopen", string.format("left_pmos_welltap_soiopen_%d", i))
        end
        if _P.drawrightnmoswelltap then
            divider:inherit_area_anchor_as(latches[i], "right_nmos_welltap_boundary", string.format("right_nmos_welltap_boundary_%d", i))
            divider:inherit_area_anchor_as(latches[i], "right_nmos_welltap_implant", string.format("right_nmos_welltap_implant_%d", i))
            divider:inherit_area_anchor_as(latches[i], "right_nmos_welltap_implant", string.format("right_nmos_wellsoiopen_%d", i))
        end
        if _P.drawrightpmoswelltap then
            divider:inherit_area_anchor_as(latches[i], "right_pmos_welltap_boundary", string.format("right_pmos_welltap_boundary_%d", i))
            divider:inherit_area_anchor_as(latches[i], "right_pmos_welltap_implant", string.format("right_pmos_welltap_implant_%d", i))
            divider:inherit_area_anchor_as(latches[i], "right_pmos_welltap_soiopen", string.format("right_pmos_welltap_soiopen_%d", i))
        end
    end

    -- well, implant and soiopen anchors (buffer)
    divider:inherit_area_anchor_as(buffer, "nmos_well", "nmos_well_buf")
    divider:inherit_area_anchor_as(buffer, "pmos_well", "pmos_well_buf")
    divider:inherit_area_anchor_as(buffer, "nmos_implant", "nmos_implant_buf")
    divider:inherit_area_anchor_as(buffer, "pmos_implant", "pmos_implant_buf")
    if _P.drawleftnmoswelltap then
        divider:inherit_area_anchor_as(buffer, "left_nmos_welltap_boundary", "left_nmos_welltap_boundary_buf")
        divider:inherit_area_anchor_as(buffer, "left_nmos_welltap_implant", "left_nmos_welltap_implant_buf")
        divider:inherit_area_anchor_as(buffer, "left_nmos_welltap_soiopen", "left_nmos_welltap_soiopen_buf")
    end
    if _P.drawleftpmoswelltap then
        divider:inherit_area_anchor_as(buffer, "left_pmos_welltap_boundary", "left_pmos_welltap_boundary_buf")
        divider:inherit_area_anchor_as(buffer, "left_pmos_welltap_implant", "left_pmos_welltap_implant_buf")
        divider:inherit_area_anchor_as(buffer, "left_pmos_welltap_soiopen", "left_pmos_welltap_soiopen_buf")
    end
    if _P.drawrightnmoswelltap then
        divider:inherit_area_anchor_as(buffer, "right_nmos_welltap_boundary", "right_nmos_welltap_boundary_buf")
        divider:inherit_area_anchor_as(buffer, "right_nmos_welltap_implant", "right_nmos_welltap_implant_buf")
        divider:inherit_area_anchor_as(latches[i], "right_nmos_welltap_implant", "right_nmos_wellsoiopen_buf")
    end
    if _P.drawrightpmoswelltap then
        divider:inherit_area_anchor_as(buffer, "right_pmos_welltap_boundary", "right_pmos_welltap_boundary_buf")
        divider:inherit_area_anchor_as(buffer, "right_pmos_welltap_implant", "right_pmos_welltap_implant_buf")
        divider:inherit_area_anchor_as(buffer, "right_pmos_welltap_soiopen", "right_pmos_welltap_soiopen_buf")
    end


    -- clock ports -- FIXME: hard-coded for numlatches == 2
    divider:add_port_with_anchor("inn", generics.metalport(_P.clocklinemetal),
        point.create(
            (divider:get_area_anchor("inp_line").l + divider:get_area_anchor("inp_line").r) / 2,
            divider:get_area_anchor("inp_line").b
        )
    )
    divider:add_port_with_anchor("inp", generics.metalport(_P.clocklinemetal),
        point.create(
            (divider:get_area_anchor("inn_line").l + divider:get_area_anchor("inn_line").r) / 2,
            divider:get_area_anchor("inn_line").b
        )
    )

    -- power ports
    for i = 1, numlatches do
        divider:add_port("vss", generics.metalport(1), latches[i]:get_area_anchor("outerclockndummyleft_sourcestrap").bl)
        divider:add_port("vdd", generics.metalport(1), latches[i]:get_area_anchor("outerclockpdummyright_sourcestrap").bl)
    end

    -- output ports
    divider:add_port_with_anchor("outp", generics.metalport(4),
        point.create(
            buffer:get_area_anchor(string.format("outp_%d", numbuf)).r,
            (buffer:get_area_anchor(string.format("outp_%d", numbuf)).b + buffer:get_area_anchor(string.format("outp_%d", numbuf)).t) / 2
        )
    )
    divider:add_port_with_anchor("outn", generics.metalport(4),
        point.create(
            buffer:get_area_anchor(string.format("outn_%d", numbuf)).l,
            (buffer:get_area_anchor(string.format("outn_%d", numbuf)).b + buffer:get_area_anchor(string.format("outn_%d", numbuf)).t) / 2
        )
    )
    if _P.drawQbuffer then
        divider:add_port_with_anchor("outQp", generics.metalport(4),
            point.create(
                buffer:get_area_anchor(string.format("outQp_%d", numbuf)).r,
                (buffer:get_area_anchor(string.format("outQp_%d", numbuf)).b + buffer:get_area_anchor(string.format("outQp_%d", numbuf)).t) / 2
            )
        )
        divider:add_port_with_anchor("outQn", generics.metalport(4),
            point.create(
                buffer:get_area_anchor(string.format("outQn_%d", numbuf)).l,
                (buffer:get_area_anchor(string.format("outQn_%d", numbuf)).b + buffer:get_area_anchor(string.format("outQn_%d", numbuf)).t) / 2
            )
        )
    end

    -- layer boundaries
    divider:add_layer_boundary(
        generics.metal(_P.clocklinemetal),
        util.rectangle_to_polygon(
            divider:get_area_anchor("inp_line").bl,
            divider:get_area_anchor("inn_line").tr
        )
    )
    for i = 1, numlatches do
        divider:add_layer_boundary(
            generics.metal(_P.clocklinemetal),
            util.rectangle_to_polygon(
                divider:get_area_anchor(string.format("clockpvia_%d", i)).bl,
                divider:get_area_anchor(string.format("clockpvia_%d", i)).tr
            )
        )
    end
    divider:add_layer_boundary(
        generics.metal(_P.clocklinemetal),
        util.rectangle_to_polygon(
            latches[numlatches]:get_area_anchor(string.format("nlatchleft_sourcedrain%d", _P.latchfingers)).tl,
            point.create(
                latches[numlatches]:get_area_anchor(string.format("nlatchright_sourcedrain%d", 2)).r,
                buffer:get_area_anchor("inp").t
            )
        )
    )
    if _P.drawQbuffer then
        divider:add_layer_boundary(
            generics.metal(_P.clocklinemetal),
            util.rectangle_to_polygon(
                buffer:get_area_anchor("inQp").bl,
                buffer:get_area_anchor("inQn").tr,
                1000, 1000, 100, 100
            )
        )
    end
    -- area anchor for layer boundaries
    divider:add_area_anchor_bltr(
        "activecore",
        latches[1]:get_area_anchor("clocknleft_topgatestrap").bl,
        latches[numlatches]:get_area_anchor("clocknright_topgatestrap").tr
    )
end
