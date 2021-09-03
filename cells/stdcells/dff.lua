--[[
                             |\                            |\
                             | \ Inverter                  | \ Inverter
                        |----|  O----|                |----|  O----|
         |\ Clocked     |    | /     |                |    | /     |       |\
         | \ Inverter   |    |/      |        /       |    |/      |       | \
    D o--|  O-----------*            *-------o -------*            *-------|  O----o Q
         | /            |      /|    |  Transmission  |      /|    |       | /
         |/             |     / |    |      Gate      |     / |    |       |/
                        |----O  |----|                |----O  |----|
                              \ | Clocked                   \ | Clocked
                               \| Inverter                   \| Inverter


          clk                 ~clk          ~clk            clk
--]]

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
    local routingshift = (bp.gstwidth + bp.gstspace) / 2

    local gatecontactpos = {
        "lower", "dummy", "lower", "dummy", "lower",
        "center", "upper", "dummy", "center", "dummy", "lower",
        "center", "upper", "center", "center",
        --"lower", "upper", "center", "dummy", "lower", "upper", "dummy",
        --"center", "dummy", "lower", "upper", "center", "center",
        --"dummy", "center",
    }
    local pcontactpos = {
        "power", "inner", "power", "inner", "power", "power", nil,
        "inner", "power", "outer", "power", nil, "outer", "outer", "outer", "power",
        --"inner", "power", "outer", "inner", nil, "power", "inner",
        --"power", "inner",
    }
    local ncontactpos = {
        "power", "inner", "power", "inner", "power", "outer", "outer",
        "inner", "power", "outer", "power", "power", nil, nil, "inner",
        --"inner", "power", "outer", "inner", nil, "power", "inner",
        --"power", "inner",
    }
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
    if _P.enable_reset then
        table.insert(gatecontactpos, 11, "upper")
        gatecontactpos[12] = "center"
        gatecontactpos[13] = "lower"
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

    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        anchor("G1"):translate(-xpitch, -bp.gstwidth / 2),
        anchor("G1"):translate( xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor("G1"):translate(-xpitch,           yinvert * 2 * (bp.gstwidth + bp.gstspace) - bp.gstwidth / 2),
        anchor("G1"):translate( xpitch - spacing, yinvert * 2 * (bp.gstwidth + bp.gstspace) + bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor("G3"):translate(-xpitch, -bp.gstwidth / 2),
        anchor("G3"):translate( xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        { anchor("G1"):translate( xpitch - spacing, yinvert * 2 * (bp.gstwidth + bp.gstspace)), 
          anchor("G5"):translate(-xpitch + spacing, yinvert * 2 * (bp.gstwidth + bp.gstspace)) }, 
        bp.sdwidth
    ))

    gate:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(anchor("pSDi2"):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            anchor("nSDi2"):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(anchor("pSDi4"):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            anchor("nSDi4"):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth))

    -- cinv clk connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        anchor("G6"):translate(-2 * xpitch, -bp.gstwidth / 2),
        anchor("G6"):translate(3 * xpitch - spacing, bp.gstwidth / 2)
    ))

    -- cinv ~clk connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G5"):translate(-1 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G5"):translate( 4 * xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G7"):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G7"):translate( 2 * xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G11"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G11"):translate( 5 * xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G13"):translate(-4 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G13"):translate( 3 * xpitch - spacing, bp.gstwidth / 2)
    ))

    if _P.clockpolarity == "positive" then
        gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            anchor("nSDc6"):translate(0, -bp.sdwidth / 2),
            anchor("nSDc7"):translate(0, bp.sdwidth / 2)
        ))
    else
        gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
            anchor("pSDc6"):translate(0, -bp.sdwidth / 2),
            anchor("pSDc7"):translate(0, bp.sdwidth / 2)
        ))
    end

    -- fbinv.O to fbcinv.I
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDi8"):translate(0, bp.sdwidth / 2), {
            anchor("G9"),
            0,
            anchor("nSDi8"):translate(0, -bp.sdwidth / 2)
        }),
    bp.sdwidth))

    -- second clocked inverter with reset
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("pSDc13"):translate(0, -bp.sdwidth / 2),
        anchor("pSDc15"):translate(0, bp.sdwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("G9"):translate(0, -bp.sdwidth / 2),
        anchor("G12"):translate(xpitch - bp.gstspace / 2, bp.sdwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("G14"):translate(-xpitch + bp.gstspace / 2, -bp.sdwidth / 2),
        anchor("G15"):translate(xpitch - bp.gstspace / 2, bp.sdwidth / 2)
    ))

    --[[
    local suffix1 = _P.clockpolarity == "positive" and "lower" or "upper"
    local suffix2 = _P.clockpolarity == "positive" and "upper" or "lower"
    local clockinvanchor1 = _P.clockpolarity == "positive" and "nSDi4" or "pSDi4"
    gate:merge_into_shallow(geometry.path(generics.metal(3), 
        geometry.path_points_xy(anchor("G6"):translate(-2 * xpitch, 0), {
        anchor("G9"),
        0,
        anchor("G20"):translate(xpitch - spacing, 0),
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(
            anchor("G3"):translate(-xpitch, 0), {
            anchor("G18")
    }), bp.sdwidth))
    --]]

    --[[
    -- M2 bars
    local suffix1 = _P.clockpolarity == "positive" and "lower" or "upper"
    local suffix2 = _P.clockpolarity == "positive" and "upper" or "lower"
    local clockinvanchor1 = _P.clockpolarity == "positive" and "nSDi4" or "pSDi4"
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(anchor(clockinvanchor1):translate(0, -yinvert * bp.sdwidth / 2), {
        anchor(string.format("G%d", 11 + gateoffset), suffix1):translate(-2 * xpitch, 0),
        anchor(string.format("G%d", 14), suffix1):translate(xpitch, 0),
        0,
        anchor(string.format("G%d", 18), suffix2):translate(xpitch - spacing, 0),
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(
            anchor("G3"):translate(-xpitch, 0), {
            anchor("G5"):translate(4 * xpitch - spacing - bp.sdwidth / 2, 0),
            0,
            anchor("G9"):translate(0, 0),
            anchor(string.format("G%d", 11), suffix2):translate(0, 0),
            anchor(string.format("G%d", 14), suffix2):translate(xpitch - spacing - bp.sdwidth, 0),
            anchor(string.format("G%d", 18), suffix2):translate(2 * xpitch, yinvert * (bp.gstspace + bp.gstwidth)),
            anchor(string.format("G%d", 18), suffix1):translate(-3 * xpitch + bp.gstwidth / 2 + bp.gstspace, 0),
    }), bp.sdwidth))
    -- vias
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
        :translate(anchor(clockinvanchor1):translate(0, -yinvert * bp.sdwidth / 2)))

    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDi11"):translate(0, bp.sdwidth / 2), {
            anchor("G9"),
            0,
            anchor("nSDi11"):translate(0, -bp.sdwidth / 2)
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDc10"), {
            2 * xpitch,
            -bp.pwidth * 3 / 4 + bp.sdwidth / 2,
            anchor(string.format("G%d", 12 + gateoffset)),
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("nSDc10"), {
            2 * xpitch,
            bp.nwidth * 3 / 4 - bp.sdwidth / 2,
            anchor(string.format("G%d", 12 + gateoffset)),
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(anchor("nSDo14"), {
            anchor(string.format("G%d", 12 + gateoffset)):translate(0, -2 * (bp.gstwidth + bp.gstspace))
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(anchor("pSDo14"), {
            anchor(string.format("G%d", 12 + gateoffset)):translate(0, 2 * (bp.gstwidth + bp.gstspace))
        }),
    bp.sdwidth))

    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor(string.format("G%d", 11 + gateoffset), "upper"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor(string.format("G%d", 11 + gateoffset), "upper"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor(string.format("G%d", 11 + gateoffset), "lower"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor(string.format("G%d", 11 + gateoffset), "lower"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor(string.format("G%d", 14 + gateoffset), "upper"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor(string.format("G%d", 14 + gateoffset), "upper"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor(string.format("G%d", 14 + gateoffset), "lower"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor(string.format("G%d", 14 + gateoffset), "lower"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))

    gate:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(anchor("pSDi15"):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            anchor("nSDi15"):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), { anchor("nSDi15"):translate(0, -bp.sdwidth / 2), anchor("nSDi18"):translate(0, -bp.sdwidth / 2) }, bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), { anchor("pSDi15"):translate(0,  bp.sdwidth / 2), anchor("pSDi18"):translate(0,  bp.sdwidth / 2) }, bp.sdwidth))

    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDo17"):translate(0, -bp.sdwidth / 2), {
            2 * xpitch,
            -bp.pwidth + bp.sdwidth,
            anchor(string.format("G%d", 19 + gateoffset))
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("nSDo17"):translate(0, bp.sdwidth / 2), {
            2 * xpitch,
            bp.nwidth - bp.sdwidth,
            anchor(string.format("G%d", 19 + gateoffset))
        }),
    bp.sdwidth))

    -- output inverter connection
    gate:merge_into_shallow(geometry.path(generics.metal(1),
        geometry.path_points_xy(anchor("pSDi21"):translate(0, bp.sdwidth / 2), {
            xpitch / 2,
            anchor("nSDi21"):translate(0, -bp.sdwidth / 2)
    }), bp.sdwidth))
    if _P.enableQN then
        gate:merge_into_shallow(geometry.path(generics.metal(1),
            geometry.path_points_xy(anchor("pSDi23"):translate(0, bp.sdwidth / 2), {
                xpitch / 2,
                anchor("nSDi23"):translate(0, -bp.sdwidth / 2)
        }), bp.sdwidth))
        gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
            anchor(string.format("G%d", 22 + gateoffset)):translate(-xpitch, -bp.gstwidth / 2),
            anchor(string.format("G%d", 22 + gateoffset)):translate(xpitch - spacing,  bp.gstwidth / 2)
        ))
    end

    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor(string.format("G%d", 18 + gateoffset), "upper"):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        anchor(string.format("G%d", 18 + gateoffset), "upper"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor(string.format("G%d", 18 + gateoffset), "lower"):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        anchor(string.format("G%d", 18 + gateoffset), "lower"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor(string.format("G%d", 16 + gateoffset)):translate(-xpitch, -bp.gstwidth / 2),
        anchor(string.format("G%d", 16 + gateoffset)):translate(3 / 2 * xpitch - bp.gstspace / 2, bp.gstwidth / 2)
    ))

    -- output connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        anchor(string.format("G%d", 19 + gateoffset)):translate(-3 / 2 * xpitch + bp.gstspace / 2, -bp.gstwidth / 2),
        anchor(string.format("G%d", 20 + gateoffset)):translate(xpitch - spacing,  bp.gstwidth / 2)
    ))
    --]]

    gate:inherit_alignment_box(harness)

    -- ports
    --if _P.enableQ then
    --    gate:add_port("Q", generics.metal(1), anchor(string.format("G%d", 20 + gateoffset)):translate(xpitch, 0))
    --end
    --if _P.enableQN then
    --    gate:add_port("QN", generics.metal(1), anchor(string.format("G%d", 22 + gateoffset)):translate(xpitch, 0))
    --end
    gate:add_port("D", generics.metal(1), anchor("G1"):translate(0, yinvert * 2 * (bp.gstwidth + bp.gstspace)))
    gate:add_port("CLK", generics.metal(1), anchor("G1"))
    gate:add_port("VDD", generics.metal(1), anchor("top"))
    gate:add_port("VSS", generics.metal(1), anchor("bottom"))
end
