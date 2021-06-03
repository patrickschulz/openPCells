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
    pcell.reference_cell("logic/base")
    pcell.reference_cell("logic/harness")
    pcell.reference_cell("logic/not_gate")
    pcell.add_parameter("clockpolarity", "positive", { posvals = set("positive", "negative") })
    pcell.add_parameter("enableQ", true)
    pcell.add_parameter("enableQN", false)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength
    local routingshift = (bp.gstwidth + bp.gstspace) / 2

    -- isolation dummy
    local isogatemaster = pcell.create_layout("logic/isogate")
    local isoname = gate:add_child_reference(isogatemaster, "isogate")

    -- first part of clock inverter/buffer
    pcell.push_overwrites("logic/base", { rightdummies = 1 })
    local clockinv1master = pcell.create_layout("logic/not_gate", { 
        inputpos = _P.clockpolarity == "positive" and "lower" or "upper",
        shiftoutput = xpitch / 2 
    })
    local clockinv1 = gate:add_child(clockinv1master, "clockinv1")

    -- second part of clock inverter/buffer
    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local clockinv2master = pcell.create_layout("logic/not_gate", { 
        inputpos = _P.clockpolarity == "positive" and "lower" or "upper",
        shiftoutput = xpitch / 2 
    })
    local clockinv2 = gate:add_child(clockinv2master, "clockinv2")
    clockinv2:move_anchor("left", clockinv1:get_anchor("right"))

    -- first clocked inverter
    local cinvmaster = pcell.create_layout("logic/cinv", { 
        swapoutputs = true, 
        inputpos = _P.clockpolarity == "positive" and "upper" or "lower", 
        shiftoutput = xpitch * 3 / 2 
    })
    local cinv = gate:add_child(cinvmaster, "cinv")
    cinv:move_anchor("left", clockinv2:get_anchor("right"))

    -- first feedback inverter cell
    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    pcell.push_overwrites("logic/base", { connectoutput = false })
    pcell.push_overwrites("logic/harness", { shiftpcontactsinner = bp.pwidth / 2, shiftncontactsinner = bp.nwidth / 2 })
    local fbinv1master = pcell.create_layout("logic/not_gate")
    local fbinv1 = gate:add_child(fbinv1master, "fbinv1")
    fbinv1:move_anchor("left", cinv:get_anchor("right"))
    pcell.pop_overwrites("logic/base")
    pcell.pop_overwrites("logic/harness")

    isogate = gate:add_child_link(isoname)
    isogate:move_anchor("left", fbinv1:get_anchor("right"))

    local fbcinv1master = pcell.create_layout("logic/cinv", { swapinputs = false, swapoutputs = true, shiftoutput = xpitch * 3 / 2 })
    local fbcinv1 = gate:add_child(fbcinv1master, "fbcinv1")
    fbcinv1:flipx()
    fbcinv1:move_anchor("left", isogate:get_anchor("right"))
    pcell.pop_overwrites("logic/base")

    isogate = gate:add_child_link(isoname)
    isogate:move_anchor("left", fbcinv1:get_anchor("right"))

    -- transmission gate
    local tgatemaster = pcell.create_layout("logic/tgate", { shiftinput = xpitch * 3 / 2, shiftoutput = xpitch / 2 })
    local tgate = gate:add_child(tgatemaster, "tgate")
    tgate:move_anchor("left", isogate:get_anchor("right"))

    -- second feedback inverter cell
    pcell.push_overwrites("logic/base", { connectoutput = false, rightdummies = 0 })
    pcell.push_overwrites("logic/harness", { shiftpcontactsinner = bp.pwidth / 2, shiftncontactsinner = bp.nwidth / 2 })
    local fbinv2master = pcell.create_layout("logic/not_gate", { 
        inputpos = _P.clockpolarity == "positive" and "upper" or "lower"
    })
    local fbinv2 = gate:add_child(fbinv2master, "fbinv2")
    fbinv2:move_anchor("left", tgate:get_anchor("right"))
    pcell.pop_overwrites("logic/harness")
    pcell.pop_overwrites("logic/base")

    isogate = gate:add_child_link(isoname)
    isogate:move_anchor("left", fbinv2:get_anchor("right"))

    pcell.push_overwrites("logic/base", { connectoutput = true, rightdummies = 0 })
    local fbcinv2master = pcell.create_layout("logic/cinv", { 
        inputpos = _P.clockpolarity == "positive" and "upper" or "lower",
        swapinputs = false, 
        swapoutputs = true, 
        shiftoutput = xpitch * 5 / 2 
    })
    local fbcinv2 = gate:add_child(fbcinv2master, "fbcinv2")
    fbcinv2:move_anchor("left", isogate:get_anchor("right"))
    fbcinv2:flipx()
    pcell.pop_overwrites("logic/base")

    -- pop general settings (restores correct number of right dummies for the entire cell)
    pcell.pop_overwrites("logic/base")
    pcell.pop_overwrites("logic/base")

    -- output buffer
    pcell.push_overwrites("logic/base", {
        leftdummies = 0
    })
    pcell.push_overwrites("logic/not_gate", {
        inputpos = _P.clockpolarity == "positive" and "upper" or "lower",
        shiftoutput = xpitch / 2 ,
    })
    local outinv1
    local outinv2
    if _P.enableQN then
        pcell.push_overwrites("logic/base", {
            rightdummies = 1,
            leftdummies = 0
        })
        local outinv1master = pcell.create_layout("logic/not_gate")
        pcell.pop_overwrites("logic/base")
        outinv1 = gate:add_child(outinv1master, "outinv1")
        outinv1:move_anchor("left", fbcinv2:get_anchor("right"))
        local outinv2master = pcell.create_layout("logic/not_gate", { inputpos = "center" })
        outinv2 = gate:add_child(outinv2master, "outinv2")
        outinv2:move_anchor("left", outinv1:get_anchor("right"))
        gate:merge_into_shallow(geometry.path(generics.metal(1), { outinv1:get_anchor("O"), outinv2:get_anchor("I") }, bp.sdwidth))
    else
        local outinv1master = pcell.create_layout("logic/not_gate", { 
        })
        outinv1 = gate:add_child(outinv1master, "outinv1")
        outinv1:move_anchor("left", fbcinv2:get_anchor("right"))
        outinv2 = outinv1 -- simple hack for alignmentbox
    end
    pcell.pop_overwrites("logic/not_gate")
    pcell.pop_overwrites("logic/base")

    -- draw connections
    -- fbinv.O to fbcinv.I
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv1:get_anchor("OTRc"), {
            2 * xpitch,
            -bp.pwidth * 3 / 4 + bp.sdwidth / 2,
            fbcinv1:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv1:get_anchor("OBRc"), {
            2 * xpitch,
            bp.nwidth * 3 / 4 - bp.sdwidth / 2,
            fbcinv1:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv2:get_anchor("OTRc"), {
            2 * xpitch,
            -bp.pwidth * 3 / 4 + bp.sdwidth / 2,
            outinv1:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv2:get_anchor("OBRc"), {
            2 * xpitch,
            bp.nwidth * 3 / 4 - bp.sdwidth / 2,
            outinv1:get_anchor("I")
        }),
    bp.sdwidth))

    -- tgate to fbinv2
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(tgate:get_anchor("O"), {
            fbinv2:get_anchor("I")
        }), 
    bp.sdwidth))

    -- clk connections
    if _P.clockpolarity == "negative" then
        -- M2 bars
        gate:merge_into_shallow(geometry.path(generics.metal(2), 
            geometry.path_points_xy(clockinv2:get_anchor("OTRi"):translate(0, bp.sdwidth / 2), {
            fbcinv1:get_anchor("EP") + point.create(-2 * xpitch, 0),
            fbcinv2:get_anchor("EP") + point.create(-xpitch, 0)
        }), bp.sdwidth))
        gate:merge_into_shallow(geometry.path(generics.metal(2), 
            geometry.path_points_xy(
                point.combine_12(clockinv1:get_anchor("O"), fbcinv2:get_anchor("EP")), {
                fbcinv1:get_anchor("EN") + point.create(-3 * xpitch, 0),
                outinv1:get_anchor("I"),
                0,
                fbcinv2:get_anchor("EP")
        }), bp.sdwidth))
        -- vias
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(clockinv2:get_anchor("OTRi"):translate(0, bp.sdwidth / 2)))
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth + xpitch, bp.sdwidth)
            :translate(point.combine_12(clockinv1:get_anchor("O"), tgate:get_anchor("EP")):translate(xpitch / 2, 0)))

        -- cinv clk connection
        gate:merge_into_shallow(geometry.path(generics.metal(1), 
            geometry.path_points_xy(clockinv2:get_anchor("OBRi"):translate(0, -bp.sdwidth / 2), {
                cinv:get_anchor("EN"),
                --xpitch
            }),
        bp.sdwidth))
        -- cinv ~clk connection
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(cinv:get_anchor("EP"):translate(-xpitch / 2, 0)))

        -- fbcinv2 connections
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EP"):translate(-xpitch * 3 / 2, 0)))
        gate:merge_into_shallow(geometry.path(generics.metal(1), 
            geometry.path_points_yx(fbcinv2:get_anchor("EP") + point.create(-xpitch, 0), {
            fbcinv2:get_anchor("EN")
        }), bp.sdwidth))
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EP"):translate(xpitch / 2, 0)))
    else
        -- M2 bars
        gate:merge_into_shallow(geometry.path(generics.metal(2), 
            geometry.path_points_xy(clockinv2:get_anchor("OBRi"):translate(0, -bp.sdwidth / 2), {
            fbcinv1:get_anchor("EN") + point.create(-2 * xpitch, 0),
            fbcinv2:get_anchor("EN") + point.create(-xpitch, 0)
        }), bp.sdwidth))
        gate:merge_into_shallow(geometry.path(generics.metal(2), 
            geometry.path_points_xy(
                point.combine_12(clockinv1:get_anchor("O"), fbcinv2:get_anchor("EN")), {
                fbcinv1:get_anchor("EP") + point.create(-3 * xpitch, 0),
                outinv1:get_anchor("I"),
                0,
                fbcinv2:get_anchor("EN")
        }), bp.sdwidth))
        -- vias
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(clockinv2:get_anchor("OBRi"):translate(0, -bp.sdwidth / 2)))
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth + xpitch, bp.sdwidth)
            :translate(point.combine_12(clockinv1:get_anchor("O"), tgate:get_anchor("EN")):translate(xpitch / 2, 0)))

        -- cinv clk connection
        gate:merge_into_shallow(geometry.path(generics.metal(1), 
            geometry.path_points_xy(clockinv2:get_anchor("OTRi"):translate(0, bp.sdwidth / 2), {
                cinv:get_anchor("EP"),
                --xpitch
            }),
        bp.sdwidth))
        -- cinv ~clk connection
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(cinv:get_anchor("EN"):translate(-xpitch / 2, 0)))

        -- fbcinv2 connections
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EN"):translate(-xpitch * 3 / 2, 0)))
        gate:merge_into_shallow(geometry.path(generics.metal(1), 
            geometry.path_points_yx(fbcinv2:get_anchor("EN") + point.create(-xpitch, 0), {
            fbcinv2:get_anchor("EP")
        }), bp.sdwidth))
        gate:merge_into_shallow(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EN"):translate(xpitch / 2, 0)))
    end
    -- ~clk connections vias
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(fbcinv1:get_anchor("EP"):translate(-xpitch / 2, 0)))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(fbcinv1:get_anchor("EN"):translate(-xpitch / 2, 0)))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(tgate:get_anchor("EP"):translate(-xpitch / 2, 0)))
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(tgate:get_anchor("EN"):translate(-xpitch / 2, 0)))

    -- input connection
    gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2), 
        bp.glength, bp.sdwidth):translate(cinv:get_anchor("I")))
    gate:merge_into_shallow(geometry.path(generics.metal(2), {
        cinv:get_anchor("I"),
        point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I"))
    }, bp.sdwidth))
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2), 
        bp.glength,
        --2 * bp.glength + bp.gspace, 
    bp.sdwidth):translate(point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I"))))

    -- output connection
    gate:merge_into_shallow(geometry.path(generics.metal(1), {
        fbcinv2:get_anchor("I"),
        outinv1:get_anchor("I"),
    }, bp.sdwidth))

    -- inherit alignment boxes, only use most-left and most-right block
    gate:inherit_alignment_box(clockinv1)
    gate:inherit_alignment_box(outinv2)

    -- ports
    gate:add_port("D", generics.metal(1), point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I")))
    if _P.enableQ then
        gate:add_port("Q", generics.metal(1), outinv1:get_anchor("O"))
    end
    if _P.enableQN then
        gate:add_port("QN", generics.metal(1), outinv2:get_anchor("O"))
    end
    gate:add_port("CLK", generics.metal(1), clockinv1:get_anchor("I"))
    gate:add_port("VDD", generics.metal(1), clockinv1:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), clockinv1:get_anchor("VSS"))
end
