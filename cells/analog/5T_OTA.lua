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
        { "bias_gatelength", technology.get_dimension("Minimum Gate Length") },
        { "bias_gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "bias_fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "bias_oxidetype", 1 },
        { "bias_vthtype", 1 },
        { "bias_gatestrapwidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "bias_gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "input_gatelength", technology.get_dimension("Minimum Gate Length") },
        { "input_gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "input_fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "input_gatestrapwidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "input_gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "input_oxidetype", 1 },
        { "input_vthtype", 1 },
        { "input_gatewidth", technology.get_dimension("Minimum Gate Contact Region Size") },
        { "mirror_gatelength", technology.get_dimension("Minimum Gate Length") },
        { "mirror_gatespace", technology.get_dimension("Minimum Gate XSpace", "Minimum Gate Space") },
        { "mirror_fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "interconnectwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "sdwidth", technology.get_dimension("Minimum Source/Drain Contact Region Size") },
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
        gatelength = _P.bias_gatelength,
        gatespace = _P.bias_gatespace,
        width = _P.bias_fingerwidth,
        oxidetype = _P.bias_oxidetype,
        vthtype = _P.bias_vthtype,
        drawbotgate = true,
        botgatewidth = _P.bias_gatestrapwidth,
        botgatespace = _P.bias_gatestrapspace,
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
        gatelength = _P.input_gatelength,
        gatespace = _P.input_gatespace,
        width = _P.input_fingerwidth,
        oxidetype = _P.input_oxidetype,
        vthtype = _P.input_vthtype,
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
        gatelength = _P.mirror_gatelength,
        gatespace = _P.mirror_gatespace,
        width = _P.mirror_fingerwidth,
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
        yseparation = separation,
        unequalgatelengths = true,
    })
    ota:merge_into(mosfets)
end
