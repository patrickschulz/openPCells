function parameters()
    pcell.add_parameters(
        { "sourcefingers", 2, posvals = even() },
        { "sourcewidth", technology.get_dimension("Minimum Active Width", "Minimum Active YWidth") },
        { "sourcelength", technology.get_dimension("Minimum Gate Length") },
        { "sourcegatespace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "cascodefingers", 2, posvals = even() },
        { "cascodewidth", technology.get_dimension("Minimum Active Width", "Minimum Active YWidth") },
        { "cascodelength", technology.get_dimension("Minimum Gate Length") },
        { "cascodegatespace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "outputmetal", 1 },
        { "outputwidth", technology.get_dimension_max("Minimum M1 Width") },
        { "sdwidth", technology.get_dimension_max("Minimum M1 Width", "Minimum Source/Drain Contact Region Size") },
        { "sdstrapwidth", technology.get_dimension("Minimum M2 Width") },
        { "sdstrapspace", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapwidth", technology.get_dimension_max("Minimum M1 Width", "Minimum Gate Contact Region Size") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Width") },
        { "powerwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Width") },
        { "extraspace", 0 },
        { "oxidetype", 1 },
        { "connect_gates", false },
        { "continuous_upper_gate_strap", true },
        { "continuous_lower_gate_strap", true },
        { "diodeconnected", false },
        { "gateext", 0 },
        { "actext", 0 }
    )
end

function layout(cell, _P)
    local source = pcell.create_layout("basic/mosfet", "_source", {
        oxidetype = _P.oxidetype,
        fingers = _P.sourcefingers,
        gatelength = _P.sourcelength,
        gatespace = _P.sourcegatespace,
        fingerwidth = _P.sourcewidth,
        sdwidth = _P.sdwidth,
        sourcemetal = 1,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        drainmetal = 2,
        connectdrain = true,
        connectdrainwidth = _P.sdstrapwidth,
        connectdrainspace = _P.gatestrapwidth + 2 * _P.gatestrapspace + _P.extraspace / 2,
        drawtopgate = true,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        extendall = _P.gatestrapwidth + 2 * _P.gatestrapspace,
        topgatepolytopbottomextension = _P.gateext,
        actext = _P.actext,
    })
    local cascode = pcell.create_layout("basic/mosfet", "_cascode", {
        oxidetype = _P.oxidetype,
        fingers = _P.cascodefingers,
        gatelength = _P.cascodelength,
        gatespace = _P.cascodegatespace,
        fingerwidth = _P.cascodewidth,
        sdwidth = _P.sdwidth,
        sourcemetal = 2,
        connectsource = true,
        connectsourcewidth = _P.sdstrapwidth,
        connectsourcespace = _P.gatestrapwidth + 2 * _P.gatestrapspace + _P.extraspace / 2,
        drainmetal = _P.outputmetal,
        connectdrain = true,
        connectdrainwidth = _P.outputwidth,
        connectdrainspace = _P.sdstrapspace,
        drawbotgate = true,
        botgatewidth = _P.gatestrapwidth,
        botgatespace = _P.gatestrapspace,
        extendall = _P.gatestrapwidth + 2 * _P.gatestrapspace,
        botgatepolytopbottomextension = _P.gateext,
        actext = _P.actext,
        diodeconnected = _P.diodeconnected,
    })
    cascode:align_center_x(source)
    cascode:align_area_anchor_y("sourcestrap", source, "drainstrap")
    cell:merge_into(source)
    cell:merge_into(cascode)
    -- connect gates
    if _P.connect_gates then
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(
                cascode:get_area_anchor_fmt("sourcedrain%d", _P.cascodefingers / 2 + 1).l,
                source:get_area_anchor("topgatestrap").t
            ),
            point.create(
                cascode:get_area_anchor_fmt("sourcedrain%d", _P.cascodefingers / 2 + 1).r,
                cascode:get_area_anchor("botgatestrap").b
            )
        )
    end
    -- alignment box
    cell:inherit_alignment_box(source)
    cell:inherit_alignment_box(cascode)
    -- anchors
    cell:inherit_area_anchor_as(source, "sourcestrap", "power")
    cell:inherit_area_anchor_as(cascode, "drainstrap", "output")
    -- continuous gate strap
    if _P.continuous_upper_gate_strap then
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(
                source:get_area_anchor("sourcedrain1").l,
                cascode:get_area_anchor("botgatestrap").b
            ),
            point.create(
                source:get_area_anchor("sourcedrain-1").r,
                cascode:get_area_anchor("botgatestrap").t
            )
        )
    end
    -- continuous gate strap
    if _P.continuous_lower_gate_strap then
        geometry.rectanglebltr(cell, generics.metal(1),
            point.create(
                source:get_area_anchor("sourcedrain1").l,
                source:get_area_anchor("topgatestrap").b
            ),
            point.create(
                source:get_area_anchor("sourcedrain-1").r,
                source:get_area_anchor("topgatestrap").t
            )
        )
    end
end
