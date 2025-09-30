--[[
        5 Transistor OTA:

  VDD ─────────────────────────────┬───────────────────┐
                                   │                   │
                                   │                   │
                                   └───║           ║───┘
                                MloadL ║o──┬──────o║ MloadR
                                   ┌───║   │       ║───┐
                                   │       │           │
                                   ├───────┘           │
                                   │                   │
                                   │                   │
                               ║───┘                   └───║
                    vinp o─────║ MinL                MinR  ║o────o vinn
                               ║───┐                   ┌───║
                                   └─────────┬─────────┘
                                             │
                                             │
                                         ║───┘
                              vbias o────║ Mbias
                                         ║───┐
                                             │
                                             │
  VSS ───────────────────────────────────────┴──────────────────────────
--]]


function parameters()
    pcell.add_parameters(
        { "interconnectwidth", 100 },
        { "powerwidth", 200 },
        { "powerspace", 100 },
        { "sdwidth", 100 },
        { "biasrowsdwidth", 0, follow = "sdwidth" },
        { "inputrowsdwidth", 0, follow = "sdwidth" },
        { "mirrorrowsdwidth", 0, follow = "sdwidth" },
        { "biasrowouterdummies", 4 },
        { "inputrowinnerdummies", 4 },
        { "inputrowouterdummies", 4 },
        { "mirrorrowinnerdummies", 4 },
        { "mirrorrowouterdummies", 4 }
    )
end

function layout(ota, _P)
    local separation = 500
    local biasrow = {
        channeltype = "nmos",
        gatelength = 100,
        gatespace = 200,
        width = 1000,
        oxidetype = 1,
        vthtype = 1,
        drawbotgate = true,
        botgatewidth = 100,
        botgatespace = 100,
        gbotext = _P.powerspace + _P.powerwidth,
        connectsource = true,
        sourcemetal = 1,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        drainmetal = 1,
        connectdrainwidth = _P.interconnectwidth,
        connectdrainspace = (separation - _P.interconnectwidth) / 2,
        devices = {
            {
                name = "Mbiasleftdummy",
                fingers = _P.biasrowouterdummies,
                botgatewidth = _P.powerwidth,
                botgatespace = _P.powerspace,
            },
            {
                name = "Mbias",
                fingers = 8,
            },
            {
                name = "Mbiasrightdummy",
                fingers = _P.biasrowouterdummies,
                botgatewidth = _P.powerwidth,
                botgatespace = _P.powerspace,
            },
        }
    }

    local inputrow = {
        channeltype = "nmos",
        gatelength = 60,
        gatespace = 200,
        width = 1000,
        oxidetype = 1,
        vthtype = 1,
        sourcemetal = 1,
        connectsourcewidth = _P.interconnectwidth,
        connectsourcespace = (separation - _P.interconnectwidth) / 2,
        connectdrain = true,
        drainmetal = 2,
        connectdrainwidth = _P.interconnectwidth,
        connectdrainspace = (separation - _P.interconnectwidth) / 2,
        devices = {
            {
                name = "Minouterleftdummy",
                fingers = _P.inputrowouterdummies,
                drainmetal = 1,
            },
            {
                name = "MinL",
                fingers = 8,
                connectsource = true,
            },
            {
                name = "Mininnerdummy",
                fingers = _P.inputrowinnerdummies,
                drainmetal = 1,
            },
            {
                name = "MinR",
                fingers = 8,
                connectsource = true,
            },
            {
                name = "Minouterrightdummy",
                fingers = _P.inputrowouterdummies,
                drainmetal = 1,
            },
        }
    }

    local mirrorrow = {
        channeltype = "pmos",
        gatelength = 200,
        gatespace = 200,
        width = 1200,
        oxidetype = 1,
        vthtype = 1,
        drawbotgate = true,
        botgatewidth = _P.interconnectwidth,
        botgatespace = (separation - _P.interconnectwidth) / 2,
        connectsource = true,
        sourcemetal = 1,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        connectdrain = true,
        drainmetal = 2,
        connectdrainwidth = _P.interconnectwidth,
        connectdrainspace = (separation - _P.interconnectwidth) / 2,
        devices = {
            {
                name = "Mloadouterleftdummy",
                fingers = _P.mirrorrowouterdummies,
                drainmetal = 1,
                connectdraininverse = true,
                connectdrainwidth = _P.powerwidth,
                connectdrainspace = _P.powerspace,
            },
            {
                name = "MloadL",
                fingers = 8,
                diodeconnected = true,
            },
            {
                name = "Mloadinnerdummy",
                fingers = _P.mirrorrowinnerdummies,
                drainmetal = 1,
                connectdraininverse = true,
                connectdrainwidth = _P.powerwidth,
                connectdrainspace = _P.powerspace,
            },
            {
                name = "MloadR",
                fingers = 8,
            },
            {
                name = "Mloadouterrightdummy",
                fingers = _P.mirrorrowouterdummies,
                drainmetal = 1,
                connectdraininverse = true,
                connectdrainwidth = _P.powerwidth,
                connectdrainspace = _P.powerspace,
            },
        }
    }

    -- put all devices togehter
    local rows = {
        biasrow,
        inputrow,
        mirrorrow,
    }
    local mosfets = pcell.create_layout("basic/stacked_mosfet_array", "_mosfets", {
        rows = rows,
        autoskip = true,
        centermosfets = true,
        separation = separation,
        unequalgatelengths = true,
    })
    ota:merge_into(mosfets)
end
