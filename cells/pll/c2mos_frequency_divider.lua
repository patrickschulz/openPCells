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
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "clockfingers", 40 },
        { "inputfingers", 32 },
        { "latchinnersepfingers", 2 },
        { "latchoutersepfingers", 2 },
        { "latchfingers", 6 },
        { "outerdummies", 2 },
        { "nmosclockfingerwidth", 500 },
        { "pmosclockfingerwidth", 500 },
        { "nmosinputfingerwidth", 500 },
        { "pmosinputfingerwidth", 500 },
        { "powerwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "clockgatewidth", 60 },
        { "dummygatecontactwidth", technology.get_dimension("Minimum M1 Width") },
        { "nmosvthtype", 1 },
        { "pmosvthtype", 1 },
        { "nmosflippedwell", false },
        { "pmosflippedwell", false },
        { "clockviaextension", 0 },
        { "implantleftextension", 0 },
        { "implantrightextension", 0 },
        { "implanttopextension", 0 },
        { "implantbotextension", 0 },
        { "vthtypeleftextension", 0 },
        { "vthtyperightextension", 0 },
        { "vthtypetopextension", 0 },
        { "vthtypebotextension", 0 },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "stopgatecutwidth", 10 },
        { "gatestopextension", 0 },
        { "gatesbotextension", 0 },
        { "gatecutwidth", 100 },
        { "leftpolylines", {} },
        { "rightpolylines", {} }
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

    local rowdefinition = { -- without equalization dummies, these are added next
        { -- first nmos row (clock)
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            width = _P.nmosclockfingerwidth,
            channeltype = "nmos",
            vthtype = _P.nmosvthtype,
            flippedwell = _P.nmosflippedwell,
            connectsource = true,
            connectsourcewidth = _P.powerwidth,
            connectsourcespace = _P.powerspace,
            drawtopgatecut = true,
            topgatecutwidth = _P.gatecutwidth,
            topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            drawbotgatecut = true,
            botgatecutwidth = _P.gatecutwidth,
            botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            implantleftextension = _P.implantleftextension,
            implantrightextension = _P.implantrightextension,
            implanttopextension = _P.implanttopextension,
            implantbotextension = _P.implantbotextension,
            vthtypeleftextension = _P.vthtypeleftextension,
            vthtyperightextension = _P.vthtyperightextension,
            vthtypetopextension = _P.vthtypetopextension,
            vthtypebotextension = _P.vthtypebotextension,
            devices = {
                {
                    name = "outerclockndummyleft",
                    fingers = _P.outerdummies,
                    sourceviasize = _P.nmosclockfingerwidth / 2,
                    drainviasize = _P.nmosclockfingerwidth / 2,
                    drainmetal = 2,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                },
                {
                    name = "clocknleft",
                    fingers = _P.clockfingers / 2,
                    drawtopgate = true,
                    topgatewidth = _P.clockgatewidth,
                    topgatespace = 60,
                    topgatemetal = 2,
                    topgateleftextension = xpitch / 2,
                    topgaterightextension = xpitch / 2,
                    connectdrain = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "clockndummymiddle",
                    fingers = middledummyfingers,
                    sourceviasize = _P.nmosclockfingerwidth / 2,
                    drainviasize = _P.nmosclockfingerwidth / 2,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drainmetal = 2,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                },
                {
                    name = "clocknright",
                    fingers = _P.clockfingers / 2,
                    drawtopgate = true,
                    topgatewidth = _P.clockgatewidth,
                    topgatespace = 60,
                    topgatemetal = 2,
                    topgateleftextension = xpitch / 2,
                    topgaterightextension = xpitch / 2,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "outerclockndummyright",
                    fingers = _P.outerdummies,
                    --sourcesize = _P.nmosclockfingerwidth / 2,
                    --drainsize = _P.nmosclockfingerwidth / 2,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drainmetal = 2,
                    drainviasize = _P.nmosclockfingerwidth / 2,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                },
            },
        },
        { -- second nmos row (input)
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            width = _P.nmosinputfingerwidth,
            channeltype = "nmos",
            vthtype = _P.nmosvthtype,
            flippedwell = _P.nmosflippedwell,
            drawtopgatecut = true,
            topgatecutwidth = _P.gatecutwidth,
            topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            drawbotgatecut = true,
            botgatecutwidth = _P.gatecutwidth,
            botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            implantleftextension = _P.implantleftextension,
            implantrightextension = _P.implantrightextension,
            implanttopextension = _P.implanttopextension,
            implantbotextension = _P.implantbotextension,
            vthtypeleftextension = _P.vthtypeleftextension,
            vthtyperightextension = _P.vthtyperightextension,
            vthtypetopextension = _P.vthtypetopextension,
            vthtypebotextension = _P.vthtypebotextension,
            devices = {
                {
                    name = "outerinputndummyleft",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                },
                {
                    name = "ninleft",
                    fingers = _P.inputfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 180,
                    topgateleftextension = xpitch / 2,
                    topgaterightextension = xpitch / 2,
                    connectsource = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    sourceviasize = _P.nmosinputfingerwidth / 2,
                    drainviasize = _P.nmosinputfingerwidth / 2,
                    connectdrain = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    drainmetal = 4,
                },
                {
                    name = "ninputseparation1",
                    fingers = _P.latchoutersepfingers,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "nlatchleft",
                    fingers = _P.latchfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 60,
                    topgateleftextension = xpitch / 2,
                    topgaterightextension = xpitch / 2,
                    connectdrain = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 300,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "ninputseparation2",
                    fingers = _P.latchinnersepfingers,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "nlatchright",
                    fingers = _P.latchfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 300,
                    topgateleftextension = xpitch / 2,
                    topgaterightextension = xpitch / 2,
                    connectdrain = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 60,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "ninputseparation3",
                    fingers = _P.latchoutersepfingers,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "ninright",
                    fingers = _P.inputfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 180,
                    topgateleftextension = xpitch / 2,
                    topgaterightextension = xpitch / 2,
                    connectsource = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    sourceviasize = _P.nmosinputfingerwidth / 2,
                    drainviasize = _P.nmosinputfingerwidth / 2,
                    connectdrain = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    drainmetal = 4,
                },
                {
                    name = "outerinputndummyright",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                },
            },
        },
        { -- first pmos row (input)
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            width = _P.pmosinputfingerwidth,
            channeltype = "pmos",
            vthtype = _P.pmosvthtype,
            flippedwell = _P.pmosflippedwell,
            drawtopgatecut = true,
            topgatecutwidth = _P.gatecutwidth,
            topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            drawbotgatecut = true,
            botgatecutwidth = _P.gatecutwidth,
            botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            implantleftextension = _P.implantleftextension,
            implantrightextension = _P.implantrightextension,
            implanttopextension = _P.implanttopextension,
            implantbotextension = _P.implantbotextension,
            vthtypeleftextension = _P.vthtypeleftextension,
            vthtyperightextension = _P.vthtyperightextension,
            vthtypetopextension = _P.vthtypetopextension,
            vthtypebotextension = _P.vthtypebotextension,
            devices = {
                {
                    name = "outerinputpdummyleft",
                    fingers = _P.outerdummies,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                },
                {
                    name = "pinleft",
                    fingers = _P.inputfingers,
                    connectsource = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    sourceviasize = _P.nmosinputfingerwidth / 2,
                    drainviasize = _P.nmosinputfingerwidth / 2,
                    drainmetal = 4,
                },
                {
                    name = "pinputseparation1",
                    fingers = _P.latchoutersepfingers,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "platchleft",
                    fingers = _P.latchfingers,
                    connectdrain = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 60,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "pinputseparation2",
                    fingers = _P.latchinnersepfingers,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "platchright",
                    fingers = _P.latchfingers,
                    connectdrain = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 300,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "pinputseparation3",
                    fingers = _P.latchoutersepfingers,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "pinright",
                    fingers = _P.inputfingers,
                    connectsource = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    sourceviasize = _P.nmosinputfingerwidth / 2,
                    drainviasize = _P.nmosinputfingerwidth / 2,
                    drainmetal = 4,
                },
                {
                    name = "outerinputpdummyright",
                    fingers = _P.outerdummies,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                },
            },
        },
        { -- second pmos row (clock)
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            width = _P.pmosclockfingerwidth,
            channeltype = "pmos",
            vthtype = _P.pmosvthtype,
            flippedwell = _P.pmosflippedwell,
            drawtopgatecut = true,
            topgatecutwidth = _P.gatecutwidth,
            topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            drawbotgatecut = true,
            botgatecutwidth = _P.gatecutwidth,
            botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
            implantleftextension = _P.implantleftextension,
            implantrightextension = _P.implantrightextension,
            implanttopextension = _P.implanttopextension,
            implantbotextension = _P.implantbotextension,
            vthtypeleftextension = _P.vthtypeleftextension,
            vthtyperightextension = _P.vthtyperightextension,
            vthtypetopextension = _P.vthtypetopextension,
            vthtypebotextension = _P.vthtypebotextension,
            devices = {
                {
                    name = "outerclockpdummyleft",
                    fingers = _P.outerdummies,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    drainmetal = 2,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    connectdraininverse = true,
                    drainviasize = _P.nmosclockfingerwidth / 2,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawleftstopgate = _P.drawleftstopgate,
                    leftpolylines = _P.leftpolylines,
                },
                {
                    name = "clockpleft",
                    fingers = _P.clockfingers / 2,
                    drawbotgate = true,
                    botgatewidth = _P.clockgatewidth,
                    botgatespace = 60,
                    botgatemetal = 2,
                    botgateleftextension = xpitch / 2,
                    botgaterightextension = xpitch / 2,
                    connectdrain = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "clockpdummymiddle",
                    fingers = middledummyfingers,
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
                },
                {
                    name = "clockpright",
                    fingers = _P.clockfingers / 2,
                    drawbotgate = true,
                    botgatewidth = _P.clockgatewidth,
                    botgatespace = 60,
                    botgatemetal = 2,
                    botgateleftextension = xpitch / 2,
                    botgaterightextension = xpitch / 2,
                    connectdrain = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawbotgatecut = true,
                    botgatecutwidth = _P.gatecutwidth,
                    botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
                },
                {
                    name = "outerclockpdummyright",
                    fingers = _P.outerdummies,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    connectdraininverse = true,
                    drainmetal = 2,
                    drainviasize = _P.nmosclockfingerwidth / 2,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                    stopgatecutwidth = _P.stopgatecutwidth,
                    drawrightstopgate = _P.drawrightstopgate,
                    rightpolylines = _P.rightpolylines,
                },
            },
        },
    }

    local equalizationdummyntemplate = {
        fingers = equalizationdummies,
        sourceviasize = _P.nmosclockfingerwidth / 2,
        drainviasize = _P.nmosclockfingerwidth / 2,
        connectsource = true,
        connectsourcespace = _P.powerspace,
        connectsourcewidth = _P.powerwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        drainmetal = 2,
        drawtopgatecut = true,
        topgatecutwidth = _P.gatecutwidth,
        topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
        drawbotgate = true,
        drawbotgate = true,
        botgatewidth = _P.dummygatecontactwidth,
        botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
    }
    local equalizationdummyptemplate = {
        fingers = equalizationdummies,
        sourceviasize = _P.nmosclockfingerwidth / 2,
        drainviasize = _P.nmosclockfingerwidth / 2,
        connectsource = true,
        connectsourcespace = _P.powerspace,
        connectsourcewidth = _P.powerwidth,
        drainmetal = 2,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        drawbotgatecut = true,
        botgatecutwidth = _P.gatecutwidth,
        botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
        drawtopgate = true,
        topgatewidth = _P.dummygatecontactwidth,
        topgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
    }

    if equalizationdummies > 0 then -- insert dummies in clock rows
        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "clockndummyleftleft",
        _insert_before(rowdefinition, "clocknleft", entry)

        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "clockndummyleftright",
        _insert_after(rowdefinition, "clocknleft", entry)

        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "clockndummyrightleft",
        _insert_before(rowdefinition, "clocknright", entry)

        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "clockndummyrightright",
        _insert_after(rowdefinition, "clocknright", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "clockpdummyleftleft",
        _insert_before(rowdefinition, "clockpleft", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "clockpdummyleftright",
        _insert_after(rowdefinition, "clockpleft", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "clockpdummyrightleft",
        _insert_before(rowdefinition, "clockpright", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "clockpdummyrightright",
        _insert_after(rowdefinition, "clockpright", entry)
    elseif equalizationdummies < 0 then -- insert dummies in input rows
        equalizationdummyntemplate.fingers = -equalizationdummyntemplate.fingers
        equalizationdummyptemplate.fingers = -equalizationdummyptemplate.fingers
        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "clockndummyleftleft",
        _insert_before(rowdefinition, "ninleft", entry)

        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "inputndummyleftright",
        _insert_after(rowdefinition, "ninleft", entry)

        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "inputndummyrightleft",
        _insert_before(rowdefinition, "ninright", entry)

        local entry = aux.clone_shallow(equalizationdummyntemplate)
        entry.name = "inputndummyrightright",
        _insert_after(rowdefinition, "ninright", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "inputpdummyleftleft",
        _insert_before(rowdefinition, "pinleft", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "inputpdummyleftright",
        _insert_after(rowdefinition, "pinleft", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "inputpdummyrightleft",
        _insert_before(rowdefinition, "pinright", entry)

        local entry = aux.clone_shallow(equalizationdummyptemplate)
        entry.name = "inputpdummyrightright",
        _insert_after(rowdefinition, "pinright", entry)
    end

    local latch = pcell.create_layout("basic/stacked_mosfet_array", "latch", {
        sdwidth = _P.sdwidth,
        -- FIXME: add parameters to row definitions
        --gatestrapwidth = _P.gatestrapwidth,
        --gatestrapspace = _P.gatestrapspace,
        --gatestopextension = _P.powerspace + _P.powerwidth / 2 + _P.gatestopextension,
        --gatesbotextension = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension,
        separation = _P.separation,
        rows = rowdefinition,
        splitgates = false,
    })

    -- latch cross-coupling
    geometry.viabltr(latch, 1, 4,
        latch:get_area_anchor("nlatchleft_drainstrap").bl,
        latch:get_area_anchor("nlatchleft_drainstrap").tr
    )
    geometry.viabltr(latch, 1, 4,
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
            latch:get_area_anchor(string.format("nlatchleft_sourcedrain%d", i)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("nlatchleft_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("nlatchright_sourcedrain%d", i)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("nlatchright_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchleft_sourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("platchleft_sourcedrain%d", i)).tr:translate_y(_P.separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchright_sourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("platchright_sourcedrain%d", i)).tr:translate_y(_P.separation)
        )
    end

    -- outer dummies source connections
    for i = 1, _P.outerdummies do
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyleft_sourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("outerclockndummyleft_sourcedrain%d", i)).tr:translate_y(_P.separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyright_sourcedrain%d", i + 1)).tl,
            latch:get_area_anchor(string.format("outerclockndummyright_sourcedrain%d", i + 1)).tr:translate_y(_P.separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockpdummyleft_sourcedrain%d", i)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("outerclockpdummyleft_sourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockpdummyright_sourcedrain%d", i + 1)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("outerclockpdummyright_sourcedrain%d", i + 1)).br
        )
    end

    -- connect voutp and voutn
    geometry.polygon(latch, generics.metal(4), {
        latch:get_area_anchor("ninleft_drainstrap").br,
        latch:get_area_anchor("ninleft_drainstrap").br:translate_x(2 * xpitch + 30),
        (latch:get_area_anchor("ninleft_drainstrap").br .. latch:get_area_anchor("nlatchleft_drainstrap").bl):translate_x(2 * xpitch + 30),
        latch:get_area_anchor("nlatchleft_drainstrap").bl,
        latch:get_area_anchor("nlatchleft_drainstrap").tl,
        (latch:get_area_anchor("ninleft_drainstrap").tr .. latch:get_area_anchor("nlatchleft_drainstrap").tl):translate_x(2 * xpitch - 30),
        latch:get_area_anchor("ninleft_drainstrap").tr:translate_x(2 * xpitch - 30),
        latch:get_area_anchor("ninleft_drainstrap").tr,
    })
    geometry.polygon(latch, generics.metal(4), {
        latch:get_area_anchor("nlatchright_drainstrap").br,
        (latch:get_area_anchor("ninright_drainstrap").bl .. latch:get_area_anchor("nlatchright_drainstrap").br):translate_x(-2 * xpitch + 30),
        latch:get_area_anchor("ninright_drainstrap").bl:translate_x(-2 * xpitch + 30),
        latch:get_area_anchor("ninright_drainstrap").bl,
        latch:get_area_anchor("ninright_drainstrap").tl,
        latch:get_area_anchor("ninright_drainstrap").tl:translate_x(-2 * xpitch - 30),
        (latch:get_area_anchor("ninright_drainstrap").tl .. latch:get_area_anchor("nlatchright_drainstrap").tr):translate_x(-2 * xpitch - 30),
        latch:get_area_anchor("nlatchright_drainstrap").tr,
    })

    -- clock anchors
    latch:add_area_anchor_bltr("clknleft", latch:get_area_anchor("clocknleft_topgatestrap").bl, latch:get_area_anchor("clocknleft_topgatestrap").tr)
    latch:add_area_anchor_bltr("clknright", latch:get_area_anchor("clockpleft_botgatestrap").bl, latch:get_area_anchor("clockpleft_botgatestrap").tr)
    latch:add_area_anchor_bltr("clkpleft", latch:get_area_anchor("clocknright_topgatestrap").bl, latch:get_area_anchor("clocknright_topgatestrap").tr)
    latch:add_area_anchor_bltr("clkpright", latch:get_area_anchor("clockpright_botgatestrap").bl, latch:get_area_anchor("clockpright_botgatestrap").tr)

    -- input anchors
    latch:add_area_anchor_bltr("inp", latch:get_area_anchor("ninleft_topgatestrap").bl, latch:get_area_anchor("ninleft_topgatestrap").tr)
    latch:add_area_anchor_bltr("inn", latch:get_area_anchor("ninright_topgatestrap").bl, latch:get_area_anchor("ninright_topgatestrap").tr)

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

    -- placement
    local numlatches = 2^_P.divisionfactor
    local latches = {}
    for i = 1, numlatches do
        latches[i] = latch:copy()
        if i % 2 == 0 then
            latches[i]:mirror_at_xaxis()
        end
        if i > 1 then
            latches[i]:abut_top(latches[i - 1])
            latches[i]:align_left(latches[i - 1])
        end
        divider:merge_into(latches[i])
        divider:inherit_alignment_box(latches[i])
    end

    -- connect left and right parts of latch
    for i = 1, numlatches do
        geometry.rectanglebltr(divider, generics.metal(3),
            latches[i]:get_area_anchor("clocknleft_drainstrap").br,
            latches[i]:get_area_anchor("clocknright_drainstrap").tl
        )
    end

    -- internal connections between latches
    -- FIXME

    -- input lines
    geometry.rectanglebltr(divider, generics.metal(8),
        latches[1]:get_area_anchor(string.format("clockndummymiddle_sourcedrain%d", 3)).bl .. latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").bl,
        latches[numlatches]:get_area_anchor(string.format("clockndummymiddle_sourcedrain%d", _P.latchoutersepfingers - 1)).tr .. latches[numlatches]:get_area_anchor("outerclockndummyleft_sourcestrap").tr
    )
    geometry.rectanglebltr(divider, generics.metal(8),
        latches[numlatches]:get_area_anchor(string.format("clockndummymiddle_sourcedrain%d", middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).tl .. latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").bl,
        latches[1]:get_area_anchor(string.format("clockndummymiddle_sourcedrain%d", middledummyfingers - 3 + 2)).br .. latches[numlatches]:get_area_anchor("outerclockndummyleft_sourcestrap").tr
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
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clockpidentifier, 3)).bl:translate_y(-_P.clockviaextension),
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clockpidentifier, _P.latchoutersepfingers - 1)).tr:translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, 2, 7,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clockpidentifier, 3)).tl:translate_y(_P.clockviaextension) .. latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).br,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clockpidentifier, _P.latchoutersepfingers - 1)).tr .. latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).tr
        )
        geometry.rectanglebltr(divider, generics.metal(2),
            latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clockpidentifier, ptarget)).br,
            latches[i]:get_area_anchor(string.format("clock%sright_%sgatestrap", clockpidentifier, ptarget)).tl
        )
        -- clockn
        geometry.viabltr(divider, 7, 8,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clocknidentifier, middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).bl:translate_y(-_P.clockviaextension),
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clocknidentifier, middledummyfingers - 3 + 2)).tr:translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, 2, 7,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clocknidentifier, middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).bl:translate_y(-_P.clockviaextension) .. latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).br,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddle_sourcedrain%d", clocknidentifier, middledummyfingers - 3 + 2)).tr:translate_y(_P.clockviaextension) .. latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).tr
        )
        geometry.rectanglebltr(divider, generics.metal(2),
            latches[i]:get_area_anchor(string.format("clock%sleft_%sgatestrap", clocknidentifier, ntarget)).bl,
            latches[i]:get_area_anchor(string.format("clock%sright_%sgatestrap", clocknidentifier, ntarget)).tr
        )
    end

    -- clock ports -- FIXME: hard-coded for numlatches == 2
    divider:add_port("inp", generics.metalport(8), latches[1]:get_area_anchor(string.format("clockndummymiddle_sourcedrain%d", 3)).bl .. latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").bl)
    divider:add_port("inn", generics.metalport(8), latches[2]:get_area_anchor(string.format("clockndummymiddle_sourcedrain%d", middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).tl .. latches[1]:get_area_anchor("outerclockndummyleft_sourcestrap").bl)

    -- power ports
    for i = 1, numlatches do
        divider:add_port("vss", generics.metalport(1), latches[i]:get_area_anchor("outerclockndummyleft_sourcestrap").bl)
        divider:add_port("vdd", generics.metalport(1), latches[i]:get_area_anchor("outerclockpdummyright_sourcestrap").bl)
    end

    -- output ports
    divider:add_port("outp", generics.metalport(4), latches[numlatches]:get_area_anchor("nlatchleft_sourcedrain2").tl)
    divider:add_port("outn", generics.metalport(4), latches[numlatches]:get_area_anchor("nlatchright_sourcedrain2").tl)
end
