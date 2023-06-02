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
        { "clockfingers", 40 },
        { "inputfingers", 32 },
        { "sepfingers", 2 },
        { "latchfingers", 6 },
        { "nmosclockfingerwidth", 500 },
        { "pmosclockfingerwidth", 500 },
        { "nmosinputfingerwidth", 500 },
        { "pmosinputfingerwidth", 500 }
    )
end

function check(_P)
    if _P.clockfingers % 4 ~= 0 then
        return false, string.format("clockfingers must be divisible by 4 (got: %d)", _P.clockfingers)
    end
    return true
end

function layout(latch, _P)
    local clockdummyfingers = (2 * _P.inputfingers + 3 * _P.sepfingers + 2 * _P.latchfingers - _P.clockfingers) / 2
    local core = pcell.create_layout("basic/stacked_mosfet_array", "latch", {
        separation = 420,
        powerwidth = 200,
        powerspace = 300,
        rows = {
            {
                width = _P.nmosclockfingerwidth,
                channeltype = "nmos",
                vthtype = 1,
                devices = {
                    {
                        name = "clockndummyleftleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdraininverse = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
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
                        connectsourcewidth = 200,
                        connectsourcespace = 300,
                    },
                    {
                        name = "clockndummyleftright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdraininverse = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
                    },
                    {
                        name = "clockndummymiddle",
                        fingers = 3 * _P.sepfingers + 2 * _P.latchfingers,
                        connectsource = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdraininverse = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
                    },
                    {
                        name = "clockndummyrightleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdraininverse = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
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
                        connectsourcewidth = 200,
                        connectsourcespace = 300,
                    },
                    {
                        name = "clockndummyrightright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdraininverse = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
                    },
                },
            },
            {
                width = _P.nmosinputfingerwidth,
                channeltype = "nmos",
                vthtype = 1,
                devices = {
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
                        connectdrainwidth = 80,
                        connectdrainspace = 170,
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
                        drainmetal = 3,
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
                        drainmetal = 3,
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
                        connectdrainwidth = 80,
                        connectdrainspace = 170,
                        drainmetal = 4,
                    },
                },
            },
            {
                width = _P.pmosinputfingerwidth,
                channeltype = "pmos",
                vthtype = 1,
                devices = {
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
                        connectdrainwidth = 80,
                        connectdrainspace = 170,
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
                        drainmetal = 3,
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
                        drainmetal = 3,
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
                        connectdrainwidth = 80,
                        connectdrainspace = 170,
                        drainmetal = 4,
                    },
                },
            },
            {
                width = _P.pmosclockfingerwidth,
                channeltype = "pmos",
                vthtype = 1,
                devices = {
                    {
                        name = "clockpdummyleftleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourceinverse = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
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
                        connectsourcewidth = 200,
                        connectsourcespace = 300,
                    },
                    {
                        name = "clockpdummyleftright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourceinverse = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
                    },
                    {
                        name = "clockpdummymiddle",
                        fingers = 3 * _P.sepfingers + 2 * _P.latchfingers,
                        connectsource = true,
                        connectsourceinverse = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
                    },
                    {
                        name = "clockpdummyrightleft",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourceinverse = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
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
                        connectsourcewidth = 200,
                        connectsourcespace = 300,
                    },
                    {
                        name = "clockpdummyrightright",
                        fingers = (_P.inputfingers - _P.clockfingers / 2) / 2,
                        connectsource = true,
                        connectsourceinverse = true,
                        connectsourcespace = 300,
                        connectsourcewidth = 200,
                        connectdrain = true,
                        connectdrainspace = 300,
                        connectdrainwidth = 200,
                    },
                },
            },
        },
    })

    -- latch cross-coupling
    geometry.viabltr(core, 1, 3,
        core:get_area_anchor("nlatchleftdrainstrap").bl,
        core:get_area_anchor("nlatchleftdrainstrap").tr
    )
    geometry.viabltr(core, 1, 3,
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

    latch:merge_into(core)

    latch:inherit_alignment_box(core)
end
