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

    local harness = pcell.create_layout("stdcells/harness", {
        fingers = _P.enableQN and 22 or 20,
        gatecontactpos = 
            _P.clockpolarity == "positive" and {
                "lower", "dummy", "lower", "dummy", "lower",
                "center", "upper", "dummy", "center", "dummy",
                "split", "center", "dummy", "split", "dummy",
                "center", "dummy", "split", "center", "center",
                "dummy", "center",
            }
            or {
                "upper", "power", "upper", "power", "lower",
                "center", "upper", "power", "center", "power",
                "split", "center", "power", "split", "power",
                "center", "power", "split", "center", "center",
                "power", "center",
            },
        pcontactpos = {
            "power", "inner", "power", "inner", "power", "power", nil,
            "inner", "power", "outer", "inner", nil, "power", "outer",
            "inner", "power", "outer", "inner", nil, "power", "inner",
            "power", "inner",
        },
        ncontactpos = {
            "power", "inner", "power", "inner", "power", "outer", "outer",
            "inner", "power", "outer", "inner", nil, "power", "outer",
            "inner", "power", "outer", "inner", nil, "power", "inner",
            "power", "inner",
        },
    })
    gate:merge_into_shallow(harness)

    local anchor = function(str, suffix) return harness:get_anchor(string.format("%s%s", str, suffix or "")) end

    local spacing = bp.sdwidth / 2 + bp.gstspace
    local yinvert = _P.clockpolarity == "positive" and 1 or -1

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
        anchor("G7"):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G7"):translate( 2 * xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G5"):translate(-1 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G5"):translate( 4 * xpitch - spacing, bp.gstwidth / 2)
    ))

    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("nSDc6"):translate(0, -bp.sdwidth / 2),
        anchor("nSDc7"):translate(0, bp.sdwidth / 2)
    ))

    -- M2 bars
    local suffix1 = _P.clockpolarity == "positive" and "lower" or "upper"
    local suffix2 = _P.clockpolarity == "positive" and "upper" or "lower"
    local clockinvanchor1 = _P.clockpolarity == "positive" and "nSDi4" or "pSDi4"
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(anchor(clockinvanchor1):translate(0, -yinvert * bp.sdwidth / 2), {
        anchor("G11", suffix1):translate(-2 * xpitch, 0),
        anchor("G14", suffix1):translate(xpitch, 0),
        0,
        anchor("G18", suffix2):translate(xpitch - spacing, 0),
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(
            anchor("G3"):translate(-xpitch, 0), {
            anchor("G5"):translate(4 * xpitch - spacing - bp.sdwidth / 2, 0),
            0,
            anchor("G9"):translate(0, 0),
            anchor("G11", suffix2):translate(0, 0),
            anchor("G14", suffix2):translate(xpitch - spacing - bp.sdwidth, 0),
            anchor("G18", suffix2):translate(2 * xpitch, yinvert * (bp.gstspace + bp.gstwidth)),
            anchor("G18", suffix1):translate(-3 * xpitch + bp.gstwidth / 2 + bp.gstspace, 0),
    }), bp.sdwidth))
    -- vias
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
        :translate(anchor(clockinvanchor1):translate(0, -yinvert * bp.sdwidth / 2)))

    -- fbinv.O to fbcinv.I
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("pSDi8"):translate(0, bp.sdwidth / 2), {
            anchor("G9"),
            0,
            anchor("nSDi8"):translate(0, -bp.sdwidth / 2)
        }),
    bp.sdwidth))
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
            anchor("G12"),
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("nSDc10"), {
            2 * xpitch,
            bp.nwidth * 3 / 4 - bp.sdwidth / 2,
            anchor("G12"),
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(anchor("nSDo14"), {
            anchor("G12"):translate(0, -2 * (bp.gstwidth + bp.gstspace))
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(anchor("pSDo14"), {
            anchor("G12"):translate(0, 2 * (bp.gstwidth + bp.gstspace))
        }),
    bp.sdwidth))

    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor("G11upper"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G11upper"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor("G11lower"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G11lower"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor("G14upper"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G14upper"):translate(xpitch - spacing, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2),
        anchor("G14lower"):translate(-2 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G14lower"):translate(xpitch - spacing, bp.gstwidth / 2)
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
            anchor("G19")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(anchor("nSDo17"):translate(0, bp.sdwidth / 2), {
            2 * xpitch,
            bp.nwidth - bp.sdwidth,
            anchor("G19")
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
            anchor("G22"):translate(-xpitch, -bp.gstwidth / 2),
            anchor("G22"):translate(xpitch - spacing,  bp.gstwidth / 2)
        ))
    end

    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G18", "upper"):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G18", "upper"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        anchor("G18", "lower"):translate(-3 * xpitch + spacing, -bp.gstwidth / 2),
        anchor("G18", "lower"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        anchor("G16"):translate(-xpitch, -bp.gstwidth / 2),
        anchor("G16"):translate(3 / 2 * xpitch - bp.gstspace / 2, bp.gstwidth / 2)
    ))

    -- output connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        anchor("G19"):translate(-3 / 2 * xpitch + bp.gstspace / 2, -bp.gstwidth / 2),
        anchor("G20"):translate(xpitch - spacing,  bp.gstwidth / 2)
    ))

    gate:inherit_alignment_box(harness)

    -- ports
    if _P.enableQ then
        gate:add_port("Q", generics.metal(1), anchor("G20"):translate(xpitch, 0))
    end
    if _P.enableQN then
        gate:add_port("QN", generics.metal(1), anchor("G22"):translate(xpitch, 0))
    end
    gate:add_port("D", generics.metal(1), anchor("G1"):translate(0, yinvert * 2 * (bp.gstwidth + bp.gstspace)))
    gate:add_port("CLK", generics.metal(1), anchor("G1"))
    gate:add_port("VDD", generics.metal(1), anchor("top"))
    gate:add_port("VSS", generics.metal(1), anchor("bottom"))
end
