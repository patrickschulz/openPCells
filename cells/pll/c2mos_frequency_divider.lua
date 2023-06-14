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
            width = _P.nmosclockfingerwidth,
            channeltype = "nmos",
            vthtype = _P.nmosvthtype,
            devices = {
                {
                    name = "outerclockndummyleft",
                    fingers = _P.outerdummies,
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
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
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
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
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
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
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
                    connectdrain = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
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
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drainmetal = 2,
                    drainviasize = _P.nmosclockfingerwidth / 2,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace + (_P.powerwidth - _P.dummygatecontactwidth) / 2,
                },
            },
        },
        { -- second nmos row (input)
            width = _P.nmosinputfingerwidth,
            channeltype = "nmos",
            vthtype = _P.nmosvthtype,
            devices = {
                {
                    name = "outerinputndummyleft",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    topgatecutwidth = _P.gatecutwidth,
                    topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
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
                },
            },
        },
        { -- first pmos row (input)
            width = _P.pmosinputfingerwidth,
            channeltype = "pmos",
            vthtype = _P.pmosvthtype,
            devices = {
                {
                    name = "outerinputpdummyleft",
                    fingers = _P.outerdummies,
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
                },
            },
        },
        { -- second pmos row (clock)
            width = _P.pmosclockfingerwidth,
            channeltype = "pmos",
            vthtype = _P.pmosvthtype,
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
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        gatestopextension = _P.powerspace + _P.powerwidth / 2 + _P.gatestopextension,
        gatesbotextension = _P.powerspace + _P.powerwidth / 2 + _P.gatesbotextension,
        separation = _P.separation,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        rows = rowdefinition,
        --drawtopgatecut = true,
        --topgatecutwidth = _P.gatecutwidth,
        --topgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
        --drawbotgatecut = true,
        --botgatecutwidth = _P.gatecutwidth,
        --botgatecutspace = (_P.separation - _P.gatecutwidth) / 2,
        implantleftextension = _P.implantleftextension,
        implantrightextension = _P.implantrightextension,
        implanttopextension = _P.implanttopextension,
        implantbotextension = _P.implantbotextension,
        vthtypeleftextension = _P.vthtypeleftextension,
        vthtyperightextension = _P.vthtyperightextension,
        vthtypetopextension = _P.vthtypetopextension,
        vthtypebotextension = _P.vthtypebotextension,
        drawleftstopgate = _P.drawleftstopgate,
        drawrightstopgate = _P.drawrightstopgate,
        stopgatecutwidth = _P.stopgatecutwidth,
        leftpolylines = _P.leftpolylines,
        rightpolylines = _P.rightpolylines,
    })

    -- latch cross-coupling
    geometry.viabltr(latch, 1, 4,
        latch:get_area_anchor("nlatchleftdrainstrap").bl,
        latch:get_area_anchor("nlatchleftdrainstrap").tr
    )
    geometry.viabltr(latch, 1, 4,
        latch:get_area_anchor("nlatchrightdrainstrap").bl,
        latch:get_area_anchor("nlatchrightdrainstrap").tr
    )
    geometry.rectanglebltr(latch, generics.metal(1),
        latch:get_area_anchor("nlatchlefttopgate").br,
        latch:get_area_anchor("nlatchrightdrainstrap").tl
    )
    geometry.rectanglebltr(latch, generics.metal(1),
        latch:get_area_anchor("nlatchleftdrainstrap").br,
        latch:get_area_anchor("nlatchrighttopgate").tl
    )

    -- latch source connections
    for i = 1, _P.latchfingers + 1, 2 do
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("nlatchleftsourcedrain%d", i)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("nlatchleftsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("nlatchrightsourcedrain%d", i)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("nlatchrightsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchleftsourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("platchleftsourcedrain%d", i)).tr:translate_y(_P.separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchrightsourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("platchrightsourcedrain%d", i)).tr:translate_y(_P.separation)
        )
    end

    -- outer dummies source connections
    for i = 1, _P.outerdummies do
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyleftsourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("outerclockndummyleftsourcedrain%d", i)).tr:translate_y(_P.separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyrightsourcedrain%d", i + 1)).tl,
            latch:get_area_anchor(string.format("outerclockndummyrightsourcedrain%d", i + 1)).tr:translate_y(_P.separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockpdummyleftsourcedrain%d", i)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("outerclockpdummyleftsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockpdummyrightsourcedrain%d", i + 1)).bl:translate_y(-_P.separation),
            latch:get_area_anchor(string.format("outerclockpdummyrightsourcedrain%d", i + 1)).br
        )
    end

    -- connect voutp and voutn
    geometry.polygon(latch, generics.metal(4), {
        latch:get_area_anchor("ninleftdrainstrap").br,
        latch:get_area_anchor("ninleftdrainstrap").br:translate_x(2 * xpitch + 30),
        (latch:get_area_anchor("ninleftdrainstrap").br .. latch:get_area_anchor("nlatchleftdrainstrap").bl):translate_x(2 * xpitch + 30),
        latch:get_area_anchor("nlatchleftdrainstrap").bl,
        latch:get_area_anchor("nlatchleftdrainstrap").tl,
        (latch:get_area_anchor("ninleftdrainstrap").tr .. latch:get_area_anchor("nlatchleftdrainstrap").tl):translate_x(2 * xpitch - 30),
        latch:get_area_anchor("ninleftdrainstrap").tr:translate_x(2 * xpitch - 30),
        latch:get_area_anchor("ninleftdrainstrap").tr,
    })
    geometry.polygon(latch, generics.metal(4), {
        latch:get_area_anchor("nlatchrightdrainstrap").br,
        (latch:get_area_anchor("ninrightdrainstrap").bl .. latch:get_area_anchor("nlatchrightdrainstrap").br):translate_x(-2 * xpitch + 30),
        latch:get_area_anchor("ninrightdrainstrap").bl:translate_x(-2 * xpitch + 30),
        latch:get_area_anchor("ninrightdrainstrap").bl,
        latch:get_area_anchor("ninrightdrainstrap").tl,
        latch:get_area_anchor("ninrightdrainstrap").tl:translate_x(-2 * xpitch - 30),
        (latch:get_area_anchor("ninrightdrainstrap").tl .. latch:get_area_anchor("nlatchrightdrainstrap").tr):translate_x(-2 * xpitch - 30),
        latch:get_area_anchor("nlatchrightdrainstrap").tr,
    })

    -- clock anchors
    latch:add_area_anchor_bltr("clknleft", latch:get_area_anchor("clocknlefttopgate").bl, latch:get_area_anchor("clocknlefttopgate").tr)
    latch:add_area_anchor_bltr("clknright", latch:get_area_anchor("clockplefttopgate").bl, latch:get_area_anchor("clockplefttopgate").tr)
    latch:add_area_anchor_bltr("clkpleft", latch:get_area_anchor("clocknrighttopgate").bl, latch:get_area_anchor("clocknrighttopgate").tr)
    latch:add_area_anchor_bltr("clkpright", latch:get_area_anchor("clockprighttopgate").bl, latch:get_area_anchor("clockprighttopgate").tr)

    -- input anchors
    latch:add_area_anchor_bltr("inp", latch:get_area_anchor("ninlefttopgate").bl, latch:get_area_anchor("ninlefttopgate").tr)
    latch:add_area_anchor_bltr("inn", latch:get_area_anchor("ninrighttopgate").bl, latch:get_area_anchor("ninrighttopgate").tr)

    -- power rail vias
    geometry.viabltr(latch, 1, 2,
        latch:get_area_anchor("lowerpowerrail").bl,
        latch:get_area_anchor("lowerpowerrail").tr
    )
    geometry.viabltr(latch, 1, 2,
        latch:get_area_anchor("upperpowerrail").bl,
        latch:get_area_anchor("upperpowerrail").tr
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
            latches[i]:get_area_anchor("clocknleftdrainstrap").br,
            latches[i]:get_area_anchor("clocknrightdrainstrap").tl
        )
    end

    -- internal connections between latches
    -- FIXME

    -- input lines
    geometry.rectanglebltr(divider, generics.metal(8),
        latches[1]:get_area_anchor(string.format("clockndummymiddlesourcedrain%d", 3)).bl .. latches[1]:get_area_anchor("lowerpowerrail").bl,
        latches[numlatches]:get_area_anchor(string.format("clockndummymiddlesourcedrain%d", _P.latchoutersepfingers - 1)).tr .. latches[numlatches]:get_area_anchor("lowerpowerrail").tr
    )
    geometry.rectanglebltr(divider, generics.metal(8),
        latches[numlatches]:get_area_anchor(string.format("clockndummymiddlesourcedrain%d", middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).tl .. latches[1]:get_area_anchor("lowerpowerrail").bl,
        latches[1]:get_area_anchor(string.format("clockndummymiddlesourcedrain%d", middledummyfingers - 3 + 2)).br .. latches[numlatches]:get_area_anchor("lowerpowerrail").tr
    )

    -- input gate connections
    for i = 1, numlatches do
        local clockpidentifier
        local clocknidentifier
        if i % 2 == 0 then
            clockpidentifier = "p"
            clocknidentifier = "n"
        else
            clockpidentifier = "n"
            clocknidentifier = "p"
        end
        -- clockp
        geometry.viabltr(divider, 7, 8,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clockpidentifier, 3)).bl:translate_y(-_P.clockviaextension),
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clockpidentifier, _P.latchoutersepfingers - 1)).tr:translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, 2, 7,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clockpidentifier, 3)).tl:translate_y(_P.clockviaextension) .. latches[i]:get_area_anchor(string.format("clock%slefttopgate", clockpidentifier)).br,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clockpidentifier, _P.latchoutersepfingers - 1)).tr .. latches[i]:get_area_anchor(string.format("clock%slefttopgate", clockpidentifier)).tr
        )
        geometry.rectanglebltr(divider, generics.metal(2),
            latches[i]:get_area_anchor(string.format("clock%slefttopgate", clockpidentifier)).br,
            latches[i]:get_area_anchor(string.format("clock%srighttopgate", clockpidentifier)).tl
        )
        -- clockn
        geometry.viabltr(divider, 7, 8,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clocknidentifier, middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).bl:translate_y(-_P.clockviaextension),
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clocknidentifier, middledummyfingers - 3 + 2)).tr:translate_y(_P.clockviaextension)
        )
        geometry.viabltr(divider, 2, 7,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clocknidentifier, middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).bl:translate_y(-_P.clockviaextension) .. latches[i]:get_area_anchor(string.format("clock%slefttopgate", clocknidentifier)).br,
            latches[i]:get_area_anchor(string.format("clock%sdummymiddlesourcedrain%d", clocknidentifier, middledummyfingers - 3 + 2)).tr:translate_y(_P.clockviaextension) .. latches[i]:get_area_anchor(string.format("clock%slefttopgate", clocknidentifier)).tr
        )
        geometry.rectanglebltr(divider, generics.metal(2),
            latches[i]:get_area_anchor(string.format("clock%slefttopgate", clocknidentifier)).bl,
            latches[i]:get_area_anchor(string.format("clock%srighttopgate", clocknidentifier)).tr
        )
    end

    -- clock ports
    divider:add_port("inp", generics.metalport(8), latches[1]:get_area_anchor(string.format("clockndummymiddlesourcedrain%d", 3)).bl .. latches[1]:get_area_anchor("lowerpowerrail").bl)
    divider:add_port("inn", generics.metalport(8), latches[2]:get_area_anchor(string.format("clockndummymiddlesourcedrain%d", middledummyfingers - (_P.latchoutersepfingers - 1) + 2)).tl .. latches[1]:get_area_anchor("lowerpowerrail").bl)

    -- power ports
    for i = 1, numlatches do
        divider:add_port("vss", generics.metalport(1), latches[i]:get_area_anchor("lowerpowerrail").bl)
        divider:add_port("vdd", generics.metalport(1), latches[i]:get_area_anchor("upperpowerrail").bl)
    end

    -- output ports
    divider:add_port("outp", generics.metalport(4), latches[numlatches]:get_area_anchor("nlatchleftsourcedrain2").tl)
    divider:add_port("outn", generics.metalport(4), latches[numlatches]:get_area_anchor("nlatchrightsourcedrain2").tl)
end
