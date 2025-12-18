function parameters()
    pcell.add_parameters(
        { "channeltype", "nmos" },
        { "oxidetype", 1 },
        { "flippedwell", false },
        { "sourcevthtype", 1 },
        { "sourcefingers", 2, posvals = even() },
        { "sourcewidth", technology.get_dimension("Minimum Active Width", "Minimum Active YWidth") },
        { "sourcelength", technology.get_dimension("Minimum Gate Length") },
        { "sourcegatespace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "cascodevthtype", 1 },
        { "cascodefingers", 2, posvals = even() },
        { "cascodewidth", technology.get_dimension("Minimum Active Width", "Minimum Active YWidth") },
        { "cascodelength", technology.get_dimension("Minimum Gate Length") },
        { "cascodegatespace", technology.get_dimension("Minimum Gate Space", "Minimum Gate XSpace") },
        { "interconnectmetal", 2 },
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
        { "connect_gates", false },
        { "continuous_upper_gate_strap", true },
        { "continuous_lower_gate_strap", true },
        { "diodeconnected", false },
        { "gateext", 0 },
        { "actext", technology.get_optional_dimension("Minimum Device Minimum Active Extension") },
        { "continuousimplant", true },
        { "continuousoxidetype", true },
        { "continuousvthtype", true },
        { "continuouswell", true },
        { "implantalignwithactive", false },
        { "implantalignleftwithactive", false, follow = "implantalignwithactive" },
        { "implantalignrightwithactive", false, follow = "implantalignwithactive" },
        { "implantaligntopwithactive", false, follow = "implantalignwithactive" },
        { "implantalignbottomwithactive", false, follow = "implantalignwithactive" },
        { "oxidetypealignwithactive", false, },
        { "oxidetypealignleftwithactive", false, follow = "oxidetypealignwithactive" },
        { "oxidetypealignrightwithactive", false, follow = "oxidetypealignwithactive" },
        { "oxidetypealigntopwithactive", false, follow = "oxidetypealignwithactive" },
        { "oxidetypealignbottomwithactive", false, follow = "oxidetypealignwithactive" },
        { "vthtypealignwithactive", false },
        { "vthtypealignleftwithactive", false, follow = "vthtypealignwithactive" },
        { "vthtypealignrightwithactive", false, follow = "vthtypealignwithactive" },
        { "vthtypealigntopwithactive", false, follow = "vthtypealignwithactive" },
        { "vthtypealignbottomwithactive", false, follow = "vthtypealignwithactive" },
        { "wellalignwithactive", false },
        { "wellalignleftwithactive", false, follow = "wellalignwithactive" },
        { "wellalignrightwithactive", false, follow = "wellalignwithactive" },
        { "wellaligntopwithactive", false, follow = "wellalignwithactive" },
        { "wellalignbottomwithactive", false, follow = "wellalignwithactive" },
        { "extendall", 0 },
        { "extendalltop", 0, follow = "extendall" },
        { "extendallbottom", 0, follow = "extendall" },
        { "extendallleft", 0, follow = "extendall" },
        { "extendallright", 0, follow = "extendall" },
        { "extendoxidetypetop", technology.get_dimension("Minimum Oxide Extension"), follow = "extendalltop" },
        { "extendoxidetypebottom", technology.get_dimension("Minimum Oxide Extension"), follow = "extendallbottom" },
        { "extendoxidetypeleft", technology.get_dimension("Minimum Oxide Extension"), follow = "extendallleft" },
        { "extendoxidetyperight", technology.get_dimension("Minimum Oxide Extension"), follow = "extendallright" },
        { "extendvthtypetop", technology.get_optional_dimension("Minimum Vthtype Extension"), follow = "extendalltop" },
        { "extendvthtypebottom", technology.get_optional_dimension("Minimum Vthtype Extension"), follow = "extendallbottom" },
        { "extendvthtypeleft", technology.get_optional_dimension("Minimum Vthtype Extension"), follow = "extendallleft" },
        { "extendvthtyperight", technology.get_optional_dimension("Minimum Vthtype Extension"), follow = "extendallright" },
        { "extendimplanttop", technology.get_dimension("Minimum Implant Extension"), follow = "extendalltop" },
        { "extendimplantbottom", technology.get_dimension("Minimum Implant Extension"), follow = "extendallbottom" },
        { "extendimplantleft", technology.get_dimension("Minimum Implant Extension"), follow = "extendallleft" },
        { "extendimplantright", technology.get_dimension("Minimum Implant Extension"), follow = "extendallright" },
        { "extendwelltop", technology.get_dimension("Minimum Well Extension"), follow = "extendalltop" },
        { "extendwellbottom", technology.get_dimension("Minimum Well Extension"), follow = "extendallbottom" },
        { "extendwellleft", technology.get_dimension("Minimum Well Extension"), follow = "extendallleft" },
        { "extendwellright", technology.get_dimension("Minimum Well Extension"), follow = "extendallright" }
    )
end

function layout(cell, _P)
    local source = pcell.create_layout("basic/mosfet", "_source", {
        oxidetype = _P.oxidetype,
        vthtype = _P.sourcevthtype,
        fingers = _P.sourcefingers,
        gatelength = _P.sourcelength,
        gatespace = _P.sourcegatespace,
        fingerwidth = _P.sourcewidth,
        sdwidth = _P.sdwidth,
        sourcemetal = 1,
        connectsource = true,
        connectsourcewidth = _P.powerwidth,
        connectsourcespace = _P.powerspace,
        drainmetal = _P.interconnectmetal,
        connectdrain = true,
        connectdrainwidth = _P.sdstrapwidth,
        connectdrainspace = _P.gatestrapwidth + 2 * _P.gatestrapspace + _P.extraspace / 2,
        drawtopgate = true,
        topgatewidth = _P.gatestrapwidth,
        topgatespace = _P.gatestrapspace,
        implantalignleftwithactive = _P.implantalignleftwithactive,
        implantalignrightwithactive = _P.implantalignrightwithactive,
        implantaligntopwithactive = _P.implantaligntopwithactive,
        implantalignbottomwithactive = _P.implantalignbottomwithactive,
        oxidetypealignleftwithactive = _P.oxidetypealignleftwithactive,
        oxidetypealignrightwithactive = _P.oxidetypealignrightwithactive,
        oxidetypealigntopwithactive = _P.oxidetypealigntopwithactive,
        oxidetypealignbottomwithactive = _P.oxidetypealignbottomwithactive,
        vthtypealignleftwithactive = _P.vthtypealignleftwithactive,
        vthtypealignrightwithactive = _P.vthtypealignrightwithactive,
        vthtypealigntopwithactive = _P.vthtypealigntopwithactive,
        vthtypealignbottomwithactive = _P.vthtypealignbottomwithactive,
        wellalignleftwithactive = _P.wellalignleftwithactive,
        wellalignrightwithactive = _P.wellalignrightwithactive,
        wellaligntopwithactive = _P.wellaligntopwithactive,
        wellalignbottomwithactive = _P.wellalignbottomwithactive,
        extendimplantleft = _P.extendimplantleft,
        extendimplantright = _P.extendimplantright,
        extendimplanttop = _P.continuousimplant and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendimplanttop,
        extendimplantbottom = _P.extendimplantbottom,
        extendoxidetypeleft = _P.extendoxidetypeleft,
        extendoxidetyperight = _P.extendoxidetyperight,
        extendoxidetypetop = _P.continuousoxidetype and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendoxidetypetop,
        extendoxidetypebottom = _P.extendoxidetypebottom,
        extendvthtypeleft = _P.extendvthtypeleft,
        extendvthtyperight = _P.extendvthtyperight,
        extendvthtypetop = _P.continuousvthtype and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendvthtypetop,
        extendvthtypebottom = _P.extendvthtypebottom,
        extendwellleft = _P.extendwellleft,
        extendwellright = _P.extendwellright,
        extendwelltop = _P.continuouswell and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendwelltop,
        extendwellbottom = _P.extendwellbottom,
        topgatepolytopbottomextension = _P.gateext,
        actext = _P.actext,
    })
    local cascode = pcell.create_layout("basic/mosfet", "_cascode", {
        oxidetype = _P.oxidetype,
        vthtype = _P.cascodevthtype,
        fingers = _P.cascodefingers,
        gatelength = _P.cascodelength,
        gatespace = _P.cascodegatespace,
        fingerwidth = _P.cascodewidth,
        sdwidth = _P.sdwidth,
        sourcemetal = _P.interconnectmetal,
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
        implantalignleftwithactive = _P.implantalignleftwithactive,
        implantalignrightwithactive = _P.implantalignrightwithactive,
        implantaligntopwithactive = _P.implantaligntopwithactive,
        implantalignbottomwithactive = _P.implantalignbottomwithactive,
        oxidetypealignleftwithactive = _P.oxidetypealignleftwithactive,
        oxidetypealignrightwithactive = _P.oxidetypealignrightwithactive,
        oxidetypealigntopwithactive = _P.oxidetypealigntopwithactive,
        oxidetypealignbottomwithactive = _P.oxidetypealignbottomwithactive,
        vthtypealignleftwithactive = _P.vthtypealignleftwithactive,
        vthtypealignrightwithactive = _P.vthtypealignrightwithactive,
        vthtypealigntopwithactive = _P.vthtypealigntopwithactive,
        vthtypealignbottomwithactive = _P.vthtypealignbottomwithactive,
        wellalignleftwithactive = _P.wellalignleftwithactive,
        wellalignrightwithactive = _P.wellalignrightwithactive,
        wellaligntopwithactive = _P.wellaligntopwithactive,
        wellalignbottomwithactive = _P.wellalignbottomwithactive,
        extendimplantleft = _P.extendimplantleft,
        extendimplantright = _P.extendimplantright,
        extendimplanttop = _P.extendimplanttop,
        extendimplantbottom = _P.continuousimplant and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendimplantbottom,
        extendoxidetypeleft = _P.extendoxidetypeleft,
        extendoxidetyperight = _P.extendoxidetyperight,
        extendoxidetypetop = _P.extendoxidetypetop,
        extendoxidetypebottom = _P.continuousoxidetype and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendoxidetypebottom,
        extendvthtypeleft = _P.extendvthtypeleft,
        extendvthtyperight = _P.extendvthtyperight,
        extendvthtypetop = _P.extendvthtypetop,
        extendvthtypebottom = _P.continuousvthtype and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendvthtypebottom,
        extendwellleft = _P.extendwellleft,
        extendwellright = _P.extendwellright,
        extendwelltop = _P.extendwelltop,
        extendwellbottom = _P.continuouswell and _P.gatestrapwidth + 2 * _P.gatestrapspace or _P.extendwellbottom,
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

    -- alignment box
    cell:inherit_alignment_box(source)
    cell:inherit_alignment_box(cascode)

    -- anchors
    cell:inherit_all_anchors_with_prefix(source, "source_")
    cell:inherit_all_anchors_with_prefix(cascode, "cascode_")
end
