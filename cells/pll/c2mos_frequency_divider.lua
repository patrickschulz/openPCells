function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
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
        { "dummygatecontactwidth", technology.get_dimension("Minimum M1 Width") }
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
    local separation = 420
    local rowdefinition = { -- without equalization dummies, these are added next
        {
            width = _P.nmosclockfingerwidth,
            channeltype = "nmos",
            vthtype = 1,
            devices = {
                {
                    name = "outerclockndummyleft",
                    fingers = _P.outerdummies,
                    sourcesize = _P.nmosclockfingerwidth / 2,
                    drainsize = _P.nmosclockfingerwidth / 2,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace,
                },
                {
                    name = "clocknleft",
                    fingers = _P.clockfingers / 2,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 60,
                    connectdrain = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawtopgatecut = true,
                    topgatecutwidth = 80,
                    topgatecutspace = 170,
                },
                {
                    name = "clockndummymiddle",
                    fingers = 2 * _P.latchoutersepfingers + _P.latchinnersepfingers + 2 * _P.latchfingers,
                    sourcesize = _P.nmosclockfingerwidth / 2,
                    drainsize = _P.nmosclockfingerwidth / 2,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawtopgatecut = true,
                    topgatecutwidth = 80,
                    topgatecutspace = 170,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace,
                },
                {
                    name = "clocknright",
                    fingers = _P.clockfingers / 2,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 60,
                    connectdrain = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawtopgatecut = true,
                    topgatecutwidth = 80,
                    topgatecutspace = 170,
                },
                {
                    name = "outerclockndummyright",
                    fingers = _P.outerdummies,
                    sourcesize = _P.nmosclockfingerwidth / 2,
                    drainsize = _P.nmosclockfingerwidth / 2,
                    connectsource = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawbotgate = true,
                    botgatewidth = _P.dummygatecontactwidth,
                    botgatespace = _P.powerspace,
                },
            },
        },
        {
            width = _P.nmosinputfingerwidth,
            channeltype = "nmos",
            vthtype = 1,
            devices = {
                {
                    name = "outerinputndummyleft",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    topgatecutwidth = 80,
                    topgatecutspace = 170,
                },
                {
                    name = "ninleft",
                    fingers = _P.inputfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 180,
                    connectsource = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    drainmetal = 4,
                },
                {
                    name = "ninputseparation1",
                    fingers = _P.latchoutersepfingers,
                },
                {
                    name = "nlatchleft",
                    fingers = _P.latchfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 60,
                    connectdrain = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 300,
                },
                {
                    name = "ninputseparation2",
                    fingers = _P.latchinnersepfingers,
                },
                {
                    name = "nlatchright",
                    fingers = _P.latchfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 300,
                    connectdrain = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 60,
                },
                {
                    name = "ninputseparation3",
                    fingers = _P.latchoutersepfingers,
                },
                {
                    name = "ninright",
                    fingers = _P.inputfingers,
                    drawtopgate = true,
                    topgatewidth = 60,
                    topgatespace = 180,
                    connectsource = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    drainmetal = 4,
                },
                {
                    name = "outerinputndummyright",
                    fingers = _P.outerdummies,
                    drawtopgatecut = true,
                    topgatecutwidth = 80,
                    topgatecutspace = 170,
                },
            },
        },
        {
            width = _P.pmosinputfingerwidth,
            channeltype = "pmos",
            vthtype = 1,
            devices = {
                {
                    name = "outerinputpdummyleft",
                    fingers = _P.outerdummies,
                },
                {
                    name = "pinleft",
                    fingers = _P.inputfingers,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    drainmetal = 4,
                },
                {
                    name = "pinputseparation1",
                    fingers = _P.latchoutersepfingers,
                },
                {
                    name = "platchleft",
                    fingers = _P.latchfingers,
                    connectdrain = true,
                    connectdraininverse = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 60,
                },
                {
                    name = "pinputseparation2",
                    fingers = _P.latchinnersepfingers,
                },
                {
                    name = "platchright",
                    fingers = _P.latchfingers,
                    connectdrain = true,
                    connectdraininverse = true,
                    drainmetal = 4,
                    connectdrainwidth = 60,
                    connectdrainspace = 300,
                },
                {
                    name = "pinputseparation3",
                    fingers = _P.latchoutersepfingers,
                },
                {
                    name = "pinright",
                    fingers = _P.inputfingers,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcewidth = 80,
                    connectsourcespace = 170,
                    sourcemetal = 3,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainwidth = 60,
                    connectdrainspace = 180,
                    drainmetal = 4,
                },
                {
                    name = "outerinputpdummyright",
                    fingers = _P.outerdummies,
                },
            },
        },
        {
            width = _P.pmosclockfingerwidth,
            channeltype = "pmos",
            vthtype = 1,
            devices = {
                {
                    name = "outerclockpdummyleft",
                    fingers = _P.outerdummies,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace,
                },
                {
                    name = "clockpleft",
                    fingers = _P.clockfingers / 2,
                    drawbotgate = true,
                    botgatewidth = 60,
                    botgatespace = 60,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawbotgatecut = true,
                    botgatecutwidth = 80,
                    botgatecutspace = 170,
                },
                {
                    name = "clockpdummymiddle",
                    fingers = 2 * _P.latchoutersepfingers + _P.latchinnersepfingers + 2 * _P.latchfingers,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawbotgatecut = true,
                    botgatecutwidth = 80,
                    botgatecutspace = 170,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace,
                },
                {
                    name = "clockpright",
                    fingers = _P.clockfingers / 2,
                    drawbotgate = true,
                    botgatewidth = 60,
                    botgatespace = 60,
                    connectdrain = true,
                    connectdraininverse = true,
                    connectdrainwidth = 80,
                    connectdrainspace = 170,
                    drainmetal = 3,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcewidth = _P.powerwidth,
                    connectsourcespace = _P.powerspace,
                    drawbotgatecut = true,
                    botgatecutwidth = 80,
                    botgatecutspace = 170,
                },
                {
                    name = "outerclockpdummyright",
                    fingers = _P.outerdummies,
                    connectsource = true,
                    connectsourceinverse = true,
                    connectsourcespace = _P.powerspace,
                    connectsourcewidth = _P.powerwidth,
                    connectdrain = true,
                    connectdrainspace = _P.powerspace,
                    connectdrainwidth = _P.powerwidth,
                    drawtopgate = true,
                    topgatewidth = _P.dummygatecontactwidth,
                    topgatespace = _P.powerspace,
                    drawtopgatecut = true,
                    topgatecutwidth = 60,
                    topgatecutspace = _P.powerspace + (_P.powerwidth - 60) / 2,
                },
            },
        },
    }

    local equalizationdummyntemplate = {
        fingers = equalizationdummies,
        sourcesize = _P.nmosclockfingerwidth / 2,
        drainsize = _P.nmosclockfingerwidth / 2,
        connectsource = true,
        connectsourcespace = _P.powerspace,
        connectsourcewidth = _P.powerwidth,
        connectdrain = true,
        connectdraininverse = true,
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        drawtopgatecut = true,
        topgatecutwidth = 80,
        topgatecutspace = 170,
        drawbotgate = true,
        drawbotgate = true,
        botgatewidth = _P.dummygatecontactwidth,
        botgatespace = _P.powerspace,
    }
    local equalizationdummyptemplate = {
        fingers = equalizationdummies,
        sourcesize = _P.nmosclockfingerwidth / 2,
        drainsize = _P.nmosclockfingerwidth / 2,
        connectsource = true,
        connectsourceinverse = true,
        connectsourcespace = _P.powerspace,
        connectsourcewidth = _P.powerwidth,
        connectdrain = true,
        connectdrainspace = _P.powerspace,
        connectdrainwidth = _P.powerwidth,
        drawbotgatecut = true,
        botgatecutwidth = 80,
        botgatecutspace = 170,
        drawtopgate = true,
        topgatewidth = _P.dummygatecontactwidth,
        topgatespace = _P.powerspace,
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
    else -- insert dummies in input rows
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
        gatestopextension = _P.powerspace + _P.powerwidth / 2,
        gatesbotextension = _P.powerspace + _P.powerwidth / 2,
        separation = separation,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        rows = rowdefinition,
        drawtopgatecut = true,
        topgatecutwidth = 60,
        drawbotgatecut = true,
        botgatecutwidth = 60,
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
            latch:get_area_anchor(string.format("nlatchleftsourcedrain%d", i)).bl:translate_y(-separation),
            latch:get_area_anchor(string.format("nlatchleftsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("nlatchrightsourcedrain%d", i)).bl:translate_y(-separation),
            latch:get_area_anchor(string.format("nlatchrightsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchleftsourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("platchleftsourcedrain%d", i)).tr:translate_y(separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("platchrightsourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("platchrightsourcedrain%d", i)).tr:translate_y(separation)
        )
    end

    -- outer dummies source connections
    for i = 1, _P.outerdummies do
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyleftsourcedrain%d", i)).tl,
            latch:get_area_anchor(string.format("outerclockndummyleftsourcedrain%d", i)).tr:translate_y(separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockndummyrightsourcedrain%d", i + 1)).tl,
            latch:get_area_anchor(string.format("outerclockndummyrightsourcedrain%d", i + 1)).tr:translate_y(separation)
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockpdummyleftsourcedrain%d", i)).bl:translate_y(-separation),
            latch:get_area_anchor(string.format("outerclockpdummyleftsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(latch, generics.metal(1),
            latch:get_area_anchor(string.format("outerclockpdummyrightsourcedrain%d", i + 1)).bl:translate_y(-separation),
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

    -- clock ports (not conneted)
    latch:add_area_anchor_bltr("clknleft", latch:get_area_anchor("clocknlefttopgate").bl, latch:get_area_anchor("clocknlefttopgate").tr)
    latch:add_area_anchor_bltr("clknright", latch:get_area_anchor("clockplefttopgate").bl, latch:get_area_anchor("clockplefttopgate").tr)
    latch:add_area_anchor_bltr("clkpleft", latch:get_area_anchor("clocknrighttopgate").bl, latch:get_area_anchor("clocknrighttopgate").tr)
    latch:add_area_anchor_bltr("clkpright", latch:get_area_anchor("clockprighttopgate").bl, latch:get_area_anchor("clockprighttopgate").tr)

    -- input ports
    latch:add_area_anchor_bltr("inp", latch:get_area_anchor("ninlefttopgate").bl, latch:get_area_anchor("ninlefttopgate").tr)
    latch:add_area_anchor_bltr("inn", latch:get_area_anchor("ninrighttopgate").bl, latch:get_area_anchor("ninrighttopgate").tr)

    -- placement
    local latch1 = latch:copy()
    local latch2 = latch:copy()
    latch2:mirror_at_xaxis()
    latch2:abut_top(latch1)
    latch2:align_left(latch1)
    divider:merge_into(latch1)
    divider:merge_into(latch2)

    -- alignment box
    divider:inherit_alignment_box(latch1)
    divider:inherit_alignment_box(latch2)

    -- clock ports
    divider:add_port("clkp", generics.metalport(1), latch1:get_area_anchor("clkpleft").bl)
    divider:add_port("clkp", generics.metalport(1), latch2:get_area_anchor("clknleft").bl)
    divider:add_port("clkn", generics.metalport(1), latch1:get_area_anchor("clknleft").bl)
    divider:add_port("clkn", generics.metalport(1), latch2:get_area_anchor("clkpleft").bl)
    divider:add_port("clkp", generics.metalport(1), latch1:get_area_anchor("clkpright").bl)
    divider:add_port("clkp", generics.metalport(1), latch2:get_area_anchor("clknright").bl)
    divider:add_port("clkn", generics.metalport(1), latch1:get_area_anchor("clknright").bl)
    divider:add_port("clkn", generics.metalport(1), latch2:get_area_anchor("clkpright").bl)
end
