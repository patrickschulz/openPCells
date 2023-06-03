--[[
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
--]]

function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "clockfingers", 40 },
        { "inputfingers", 32 },
        { "sepfingers", 2 },
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
    if _P.clockfingers % 4 ~= 0 then
        return false, string.format("clockfingers must be divisible by 4 (got: %d)", _P.clockfingers)
    end
    return true
end

function layout(latch, _P)
    local xpitch = _P.gatelength + _P.gatespace
    local clockdummyfingers = (2 * _P.inputfingers + 3 * _P.sepfingers + 2 * _P.latchfingers - _P.clockfingers) / 2
    local core = pcell.create_layout("basic/stacked_mosfet_array", "latch", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        gatestopextension = _P.powerspace + _P.dummygatecontactwidth,
        gatesbotextension = _P.powerspace + _P.dummygatecontactwidth,
        separation = 420,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        rows = {
            {
                width = _P.nmosclockfingerwidth,
                channeltype = "nmos",
                vthtype = 1,
                devices = {
                    {
                        name = "outerclockndummyleft",
                        fingers = _P.outerdummies,
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
                        name = "clockndummyleftleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "clockndummyleftright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "clockndummymiddle",
                        fingers = 3 * _P.sepfingers + 2 * _P.latchfingers,
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
                        name = "clockndummyrightleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "clockndummyrightright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "outerclockndummyright",
                        fingers = _P.outerdummies,
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
                        fingers = _P.sepfingers,
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
                        fingers = _P.sepfingers,
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
                        fingers = _P.sepfingers,
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
                        fingers = _P.sepfingers,
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
                        fingers = _P.sepfingers,
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
                        fingers = _P.sepfingers,
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
                        name = "clockpdummyleftleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "clockpdummyleftright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "clockpdummymiddle",
                        fingers = 3 * _P.sepfingers + 2 * _P.latchfingers,
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
                        name = "clockpdummyrightleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                        name = "clockpdummyrightright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
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
                    },
                },
            },
        },
    })


    -- latch cross-coupling
    geometry.viabltr(core, 1, 4,
        core:get_area_anchor("nlatchleftdrainstrap").bl,
        core:get_area_anchor("nlatchleftdrainstrap").tr
    )
    geometry.viabltr(core, 1, 4,
        core:get_area_anchor("nlatchrightdrainstrap").bl,
        core:get_area_anchor("nlatchrightdrainstrap").tr
    )
    geometry.rectanglebltr(core, generics.metal(1),
        core:get_area_anchor("nlatchlefttopgate").br,
        core:get_area_anchor("nlatchrightdrainstrap").tl
    )
    geometry.rectanglebltr(core, generics.metal(1),
        core:get_area_anchor("nlatchleftdrainstrap").br,
        core:get_area_anchor("nlatchrighttopgate").tl
    )

    -- latch source connections
    for i = 1, _P.latchfingers + 1, 2 do
        geometry.rectanglebltr(core, generics.metal(1),
            core:get_area_anchor(string.format("nlatchleftsourcedrain%d", i)).bl:translate_y(-420),
            core:get_area_anchor(string.format("nlatchleftsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(core, generics.metal(1),
            core:get_area_anchor(string.format("nlatchrightsourcedrain%d", i)).bl:translate_y(-420),
            core:get_area_anchor(string.format("nlatchrightsourcedrain%d", i)).br
        )
        geometry.rectanglebltr(core, generics.metal(1),
            core:get_area_anchor(string.format("platchleftsourcedrain%d", i)).tl,
            core:get_area_anchor(string.format("platchleftsourcedrain%d", i)).tr:translate_y(420)
        )
        geometry.rectanglebltr(core, generics.metal(1),
            core:get_area_anchor(string.format("platchrightsourcedrain%d", i)).tl,
            core:get_area_anchor(string.format("platchrightsourcedrain%d", i)).tr:translate_y(420)
        )
    end

    -- connect voutp and voutn
    geometry.polygon(core, generics.metal(4), {
        core:get_area_anchor("ninleftdrainstrap").br,
        core:get_area_anchor("ninleftdrainstrap").br:translate_x(2 * xpitch + 30),
        (core:get_area_anchor("ninleftdrainstrap").br .. core:get_area_anchor("nlatchleftdrainstrap").bl):translate_x(2 * xpitch + 30),
        core:get_area_anchor("nlatchleftdrainstrap").bl,
        core:get_area_anchor("nlatchleftdrainstrap").tl,
        (core:get_area_anchor("ninleftdrainstrap").tr .. core:get_area_anchor("nlatchleftdrainstrap").tl):translate_x(2 * xpitch - 30),
        core:get_area_anchor("ninleftdrainstrap").tr:translate_x(2 * xpitch - 30),
        core:get_area_anchor("ninleftdrainstrap").tr,
    })
    geometry.polygon(core, generics.metal(4), {
        core:get_area_anchor("nlatchrightdrainstrap").br,
        (core:get_area_anchor("ninrightdrainstrap").bl .. core:get_area_anchor("nlatchrightdrainstrap").br):translate_x(-2 * xpitch + 30),
        core:get_area_anchor("ninrightdrainstrap").bl:translate_x(-2 * xpitch + 30),
        core:get_area_anchor("ninrightdrainstrap").bl,
        core:get_area_anchor("ninrightdrainstrap").tl,
        core:get_area_anchor("ninrightdrainstrap").tl:translate_x(-2 * xpitch - 30),
        (core:get_area_anchor("ninrightdrainstrap").tl .. core:get_area_anchor("nlatchrightdrainstrap").tr):translate_x(-2 * xpitch - 30),
        core:get_area_anchor("nlatchrightdrainstrap").tr,
    })

    latch:merge_into(core)
    latch:inherit_alignment_box(core)

    -- ports
    latch:add_port("clkp", generics.metalport(1), core:get_area_anchor("clocknlefttopgate").bl)
end
