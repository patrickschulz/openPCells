function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos" },
        { "fingers", 2, posvals = even() },
        { "fingerwidth", technology.get_dimension("Minimum MOSFET Fingerwidth", "Minimum Active Width") },
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "sourcedrainstrapspace", technology.get_dimension("Minimum M1 Space") },
        { "xrep", 1 },
        { "yrep", 1 },
        { "drawguardring", false }
    )
end

function layout(moscap, _P)
    local base = pcell.create_layout("basic/mosfet", "_mosfet", {
        fingers = _P.fingers,
        fingerwidth = _P.fingerwidth,
        channeltype = _P.channeltype,
        gatelength = _P.gatelength,
        drawtopgate = true,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        drawbotgate = true,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        sourcemetal = 2,
        connectsource = true,
        --connectsourceinverse = (_P.channeltype == "pmos"),
        connectsourceboth = true,
        connectsourcespace = _P.gatestrapspace + _P.gatestrapwidth + _P.sourcedrainstrapspace,
        drainmetal = 2,
        connectdrain = true,
        --connectdraininverse = (_P.channeltype == "nmos"),
        connectdrainboth = true,
        connectdrainspace = _P.gatestrapspace + _P.gatestrapwidth + _P.sourcedrainstrapspace,
        drawguardring = _P.drawguardring,
    })
    local lastydevice
    for yi = 1, _P.yrep do
        local mosfet = base:copy()
        if lastydevice then
            mosfet:abut_top(lastydevice)
        end
        local lastxdevice
        for xi = 1, _P.xrep do
            if lastxdevice then
                mosfet:abut_right(lastxdevice)
            end
            moscap:merge_into(mosfet)
            moscap:inherit_all_anchors_with_prefix(mosfet, string.format("moscap_%d_%d_", xi, yi))
            moscap:inherit_alignment_box(mosfet)
            lastxdevice = mosfet
            if xi == 1 then
                lastydevice = mosfet
            end
        end
    end
end
