function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.reference_cell("stdcells/not_gate")
    pcell.add_parameter("clockpolarity", "positive", { posvals = set("positive", "negative") })
    pcell.add_parameter("enableQ", true)
    pcell.add_parameter("enableQN", false)
    pcell.add_parameter("enable_reset", false)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")

    local xpitch = bp.gspace + bp.glength
    local yrpitch = bp.gstwidth + bp.gstspace

    local gatecontactpos = {
        "center", "center", "lower", "upper", "center", "dummy"
    }
    local pcontactpos = {
        "outer", "inner", "outer", "outer", "power",
    }
    local ncontactpos = {
        "outer", "inner", nil, "power", "power",
    }
    --[[
    if _P.clockpolarity == "negative" then
        gatecontactpos[1] = "upper"
        gatecontactpos[3] = "upper"
        gatecontactpos[5] = "upper"
        gatecontactpos[7] = "lower"
        pcontactpos[6] = "outer"
        ncontactpos[6] = "power"
        pcontactpos[7] = "outer"
        ncontactpos[7] = nil
    end
    --]]
    if _P.enable_reset then
        --table.insert(gatecontactpos, 11, "upper")
        --gatecontactpos[12] = "center"
        --gatecontactpos[13] = "lower"
        pcontactpos[7] = "inner"
        pcontactpos[8] = "inner"
        ncontactpos[7] = "inner"
        ncontactpos[8] = "inner"
        gatecontactpos[7] = "center"
        gatecontactpos[8] = "center"
    end

    local harness = pcell.create_layout("stdcells/harness", {
        --fingers = 20 + (_P.enableQN and 2 or 0) + (_P.enable_reset and 1 or 0),
        fingers = #gatecontactpos,
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    })
    gate:merge_into_shallow(harness)

    local anchor = function(str, suffix) return harness:get_anchor(string.format("%s%s", str, suffix or "")) end

    local spacing = bp.sdwidth / 2 + bp.gstspace
    local yinvert = _P.clockpolarity == "positive" and 1 or -1

    local gateoffset = _P.enable_reset and 1 or 0

    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDc1"), {
            -xpitch / 2,
            anchor("nSDc1")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
        anchor("G2"):translate(-bp.sdwidth / 2 - 2 * xpitch, -bp.sdwidth / 2),
        anchor("G2"):translate( bp.sdwidth / 2, bp.sdwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("pSDc3"):translate(0, -bp.sdwidth / 2),
        anchor("pSDc4"):translate(0, bp.sdwidth / 2)
    ))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDc2"), {
            anchor("G1"),
            0,
            anchor("nSDc2")
        }),
    bp.sdwidth))

    --[[
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDi8"):translate(0, bp.sdwidth / 2), {
            anchor("G1"),
            0,
            anchor("nSDi8"):translate(0, -bp.sdwidth / 2)
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(anchor("pSDo12"), {
            -bp.pwidth + bp.sdwidth / 2,
            anchor("G13"),
            0,
            anchor("nSDc13")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("pSDc10"):translate(0, -bp.sdwidth / 2),
        anchor("pSDc11"):translate(0, bp.sdwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("nSDc11"):translate(0, -bp.sdwidth / 2),
        anchor("nSDc12"):translate(0, bp.sdwidth / 2)
    ))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_yx(anchor("G13"), {
            anchor("G9"),
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G9"):translate(-bp.glength / 2, -bp.gstwidth / 2),
        anchor("G9"):translate( bp.glength / 2,  bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G13"):translate(-bp.glength / 2, -bp.gstwidth / 2),
        anchor("G13"):translate( bp.glength / 2,  bp.gstwidth / 2)
    ))
    if _P.enable_reset then
        gate:add_port("RST", generics.metal(1), anchor("G16"):translate(-xpitch / 2, 0))
    end
    gate:add_port("D", generics.metal(1), anchor("G1"):translate(0, yinvert * 2 * (bp.gstwidth + bp.gstspace)))
    gate:add_port("CLK", generics.metal(1), anchor("G1"))
    gate:add_port("VDD", generics.metal(1), anchor("top"))
    gate:add_port("VSS", generics.metal(1), anchor("bottom"))
    --]]
end
