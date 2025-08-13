function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos" },
        { "fingers", 2, posvals = even() },
        { "fingerwidth", technology.get_dimension("Minimum MOSFET Fingerwidth", "Minimum Active Width") },
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") }
    )
end

function layout(moscap, _P)
    local mosfet = pcell.create_layout("basic/mosfet", "_mosfet", {
        fingers = _P.fingers,
        fingerwidth = _P.fingerwidth,
        channeltype = _P.channeltype,
        gatelength = _P.gatelength,
        drawtopgate = true,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        connectsource = true,
        connectsourceinverse = (_P.channeltype == "pmos"),
        connectdrain = true,
        connectdraininverse = (_P.channeltype == "nmos"),
    })
    moscap:merge_into(mosfet)
    moscap:inherit_all_anchors_with_prefix(mosfet, "")
    moscap:inherit_alignment_box(mosfet)
end
