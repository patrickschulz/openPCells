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
    local isogateref = pcell.create_layout("logic/isogate")
    local isoname = gate:add_child_reference(isogateref, "isogate")
    local isogate

    -- first part of clock inverter/buffer
    pcell.push_overwrites("logic/base", { rightdummies = 1 })
    local clockinv1ref = pcell.create_layout("logic/not_gate", { 
        inputpos = _P.clockpolarity == "positive" and "lower" or "upper",
        shiftoutput = xpitch / 2 
    })
    local clockinv1 = gate:add_child(clockinv1ref, "clockinv1")

    -- second part of clock inverter/buffer
    pcell.push_overwrites("logic/base", { leftdummies = 0 })
    local clockinv2ref = pcell.create_layout("logic/not_gate", { 
        --inputpos = _P.clockpolarity == "positive" and "lower" or "upper",
        inputpos = "center",
        shiftoutput = xpitch / 2 
    })
    local clockinv2 = gate:add_child(clockinv2ref, "clockinv2")
    clockinv2:move_anchor("left", clockinv1:get_anchor("right"))

    -- first clocked inverter
    local cinvref = pcell.create_layout("logic/cinv", { 
        splitenables = true, -- TODO
        swapoutputs = true, 
        inputpos = "upper",
        enableppos = "center",
        shiftoutput = xpitch * 3 / 2 
    })
    local cinv = gate:add_child(cinvref, "cinv")
    cinv:move_anchor("left", clockinv2:get_anchor("right"))

    -- first feedback inverter cell
    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    pcell.push_overwrites("logic/base", { connectoutput = false })
    pcell.push_overwrites("logic/harness", { shiftpcontactsinner = bp.pwidth / 2, shiftncontactsinner = bp.nwidth / 2 })
    local fbinv1ref = pcell.create_layout("logic/not_gate")
    local fbinv1 = gate:add_child(fbinv1ref, "fbinv1")
    fbinv1:move_anchor("left", cinv:get_anchor("right"))
    pcell.pop_overwrites("logic/base")
    pcell.pop_overwrites("logic/harness")

    isogate = gate:add_child_link(isoname)
    isogate:move_anchor("left", fbinv1:get_anchor("right"))

    local fbcinv1ref = pcell.create_layout("logic/cinv", { swapinputs = false, swapoutputs = true, shiftoutput = xpitch * 3 / 2 })
    local fbcinv1 = gate:add_child(fbcinv1ref, "fbcinv1")
    fbcinv1:flipx()
    fbcinv1:move_anchor("left", isogate:get_anchor("right"))
    pcell.pop_overwrites("logic/base")

    isogate = gate:add_child_link(isoname)
    isogate:move_anchor("left", fbcinv1:get_anchor("right"))

    -- transmission gate
    local tgateref = pcell.create_layout("logic/tgate", { shiftinput = xpitch * 3 / 2, shiftoutput = xpitch / 2 })
    local tgate = gate:add_child(tgateref, "tgate")
    tgate:move_anchor("left", isogate:get_anchor("right"))

    -- second feedback inverter cell
    pcell.push_overwrites("logic/base", { connectoutput = false, rightdummies = 0 })
    pcell.push_overwrites("logic/harness", { shiftpcontactsinner = bp.pwidth / 2, shiftncontactsinner = bp.nwidth / 2 })
    local fbinv2ref = pcell.create_layout("logic/not_gate", { 
        inputpos = _P.clockpolarity == "positive" and "upper" or "lower"
    })
    local fbinv2 = gate:add_child(fbinv2ref, "fbinv2")
    fbinv2:move_anchor("left", tgate:get_anchor("right"))
    pcell.pop_overwrites("logic/harness")
    pcell.pop_overwrites("logic/base")

    isogate = gate:add_child_link(isoname)
    isogate:move_anchor("left", fbinv2:get_anchor("right"))

    pcell.push_overwrites("logic/base", { connectoutput = true, rightdummies = 0 })
    local fbcinv2ref = pcell.create_layout("logic/cinv", { 
        inputpos = "center",
        swapinputs = false, 
        swapoutputs = true, 
        shiftoutput = xpitch * 5 / 2 
    })
    local fbcinv2 = gate:add_child(fbcinv2ref, "fbcinv2")
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
        inputpos = "center",
        shiftoutput = xpitch / 2 ,
    })
    local outinv1
    local outinv2
    if _P.enableQN then
        pcell.push_overwrites("logic/base", {
            rightdummies = 1,
            leftdummies = 0
        })
        local outinv1ref = pcell.create_layout("logic/not_gate")
        pcell.pop_overwrites("logic/base")
        outinv1 = gate:add_child(outinv1ref, "outinv1")
        outinv1:move_anchor("left", fbcinv2:get_anchor("right"))
        local outinv2ref = pcell.create_layout("logic/not_gate", { inputpos = "center" })
        outinv2 = gate:add_child(outinv2ref, "outinv2")
        outinv2:move_anchor("left", outinv1:get_anchor("right"))
        gate:merge_into_shallow(geometry.path(generics.metal(1), { outinv1:get_anchor("O"), outinv2:get_anchor("I") }, bp.sdwidth))
    else
        local outinv1ref = pcell.create_layout("logic/not_gate", { 
        })
        outinv1 = gate:add_child(outinv1ref, "outinv1")
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
        geometry.path_points_xy(fbinv2:get_anchor("OTRo"):translate(0, -bp.sdwidth / 2), {
            2 * xpitch,
            -bp.pwidth + bp.sdwidth,
            fbcinv2:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv2:get_anchor("OBRo"):translate(0, bp.sdwidth / 2), {
            2 * xpitch,
            bp.nwidth - bp.sdwidth,
            fbcinv2:get_anchor("I")
        }),
    bp.sdwidth))

    -- tgate to fbinv2
    --gate:merge_into_shallow(geometry.path(generics.metal(1), {
    --    tgate:get_anchor("O") .. fbinv2:get_anchor("I"), fbinv2:get_anchor("I")
    --}, bp.gstwidth))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        (tgate:get_anchor("O") .. fbinv2:get_anchor("I")):translate(0, -bp.gstwidth / 2),
        fbinv2:get_anchor("I"):translate(xpitch - bp.gstspace - bp.gstwidth / 2 + bp.glength / 2, bp.gstwidth / 2)
    ))

    -- clk connections
    local fbcinvanchor1 = _P.clockpolarity == "positive" and "EN" or "EP"
    local fbcinvanchor2 = _P.clockpolarity == "positive" and "EP" or "EN"
    local clockinvanchor1 = _P.clockpolarity == "positive" and "OBRi" or "OTRi"
    local clockinvanchor2 = _P.clockpolarity == "positive" and "OTRi" or "OBRi"
    local yinvert = _P.clockpolarity == "positive" and 1 or -1
    -- M2 bars
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(clockinv2:get_anchor(clockinvanchor1):translate(0, -yinvert * bp.sdwidth / 2), {
        fbcinv1:get_anchor(fbcinvanchor1):translate(-xpitch, 0),
        tgate:get_anchor(fbcinvanchor1):translate(xpitch, 0),
        0,
        fbcinv2:get_anchor(fbcinvanchor1):translate(-xpitch, bp.gstwidth + bp.gstspace)
    }), bp.sdwidth))
    gate:merge_into_shallow(geometry.path(generics.metal(2), 
        geometry.path_points_xy(
            clockinv1:get_anchor("O") .. clockinv2:get_anchor("I"), {
            (clockinv2:get_anchor("I") .. cinv:get_anchor(fbcinvanchor1)):translate(xpitch, 0),
            fbcinv1:get_anchor(fbcinvanchor2):translate(-2 * xpitch, 0),
            outinv1:get_anchor("I"):translate(-2 * xpitch, 0),
            0,
            fbcinv2:get_anchor(fbcinvanchor1):translate(-2 * xpitch, 0)
    }), bp.sdwidth))
    -- vias
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
        :translate(clockinv2:get_anchor(clockinvanchor1):translate(0, -yinvert * bp.sdwidth / 2)))
    --gate:merge_into_shallow(
    --    geometry.rectangle(generics.via(1, 2), bp.sdwidth + xpitch, bp.gstwidth)
    --    :translate(point.combine_12(clockinv1:get_anchor("O"), tgate:get_anchor("EN")):translate(xpitch / 2, 0)))

    -- clockinv1 to clockinv2 connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        (clockinv1:get_anchor("O") .. clockinv2:get_anchor("I")):translate(0, -bp.gstwidth / 2),
        clockinv2:get_anchor("I"):translate(xpitch - bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))

    -- cinv clk connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        (clockinv2:get_anchor("O") .. cinv:get_anchor(fbcinvanchor2)):translate(0, -bp.gstwidth / 2),
        (fbinv1:get_anchor("I") .. cinv:get_anchor(fbcinvanchor2)):translate(-bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    -- cinv ~clk connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, true), 
        (clockinv2:get_anchor("O") .. cinv:get_anchor(fbcinvanchor1)):translate(bp.sdwidth / 2 + bp.gstspace, -bp.gstwidth / 2),
        (fbinv1:get_anchor("I") .. cinv:get_anchor(fbcinvanchor1)):translate(-bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        (clockinv2:get_anchor("O") .. cinv:get_anchor(fbcinvanchor1)):translate(bp.sdwidth / 2 + bp.gstspace, -bp.gstwidth / 2),
        (fbinv1:get_anchor("I") .. cinv:get_anchor(fbcinvanchor1)):translate(-bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))

    -- fbcinv2 connections
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2, true), 2 * bp.glength + bp.gspace + bp.gspace - bp.gstspace, bp.sdwidth)
        :translate(fbcinv2:get_anchor(fbcinvanchor1):translate(-xpitch * 3 / 2, bp.gstwidth + bp.gstspace)))
    gate:merge_into_shallow(
        geometry.rectangle(generics.metal(1), 2 * bp.glength + bp.gspace + bp.gspace - bp.gstspace, bp.gstwidth)
        :translate(fbcinv2:get_anchor(fbcinvanchor1):translate(-xpitch * 3 / 2, bp.gstwidth + bp.gstspace)))
    gate:merge_into_shallow(geometry.path(generics.metal(1), 
        geometry.path_points_yx(fbcinv2:get_anchor(fbcinvanchor1):translate(-xpitch, bp.gstwidth + bp.gstspace), {
        fbcinv2:get_anchor(fbcinvanchor2)
    }), bp.sdwidth))
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2, true), 2 * xpitch, bp.sdwidth)
        :translate(fbcinv2:get_anchor(fbcinvanchor1):translate(-xpitch * 2 / 2, 0)))
    gate:merge_into_shallow(
        geometry.rectangle(generics.metal(1), 2 * xpitch, bp.gstwidth)
        :translate(fbcinv2:get_anchor(fbcinvanchor1):translate(-xpitch * 2 / 2, 0)))

    -- ~clk connections vias
    for _, anchor in ipairs({ fbcinv1:get_anchor("EP"), fbcinv1:get_anchor("EN"), tgate:get_anchor("EP"), tgate:get_anchor("EN") }) do
        anchor:translate(-xpitch / 2, 0)
        gate:merge_into_shallow(geometry.rectangle(generics.via(1, 2, true), 
            3 * xpitch - bp.sdwidth - 2 * bp.gstspace, bp.gstwidth
        ):translate(anchor))
        gate:merge_into_shallow(geometry.rectangle(generics.metal(1), 
            3 * xpitch - bp.sdwidth - 2 * bp.gstspace, bp.gstwidth
        ):translate(anchor))
    end

    -- input connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2, true),
        (clockinv2:get_anchor("O") .. cinv:get_anchor("I")):translate(bp.sdwidth / 2 + bp.gstspace, -bp.gstwidth / 2),
        (fbinv1:get_anchor("I") .. cinv:get_anchor("I")):translate(-bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        (clockinv2:get_anchor("O") .. cinv:get_anchor("I")):translate(bp.sdwidth / 2 + bp.gstspace, -bp.gstwidth / 2),
        (fbinv1:get_anchor("I") .. cinv:get_anchor("I")):translate(-bp.sdwidth / 2 - bp.gstspace, bp.gstwidth / 2)
    ))
    gate:merge_into_shallow(geometry.path(generics.metal(2), {
        cinv:get_anchor("I"):translate(3 * xpitch - bp.gstspace - bp.sdwidth / 2, 0),
        point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I"))
    }, bp.sdwidth))
    gate:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2), 
        bp.glength,
        --2 * bp.glength + bp.gspace, 
    bp.sdwidth):translate(point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I"))))

    -- output connection
    gate:merge_into_shallow(geometry.rectanglebltr(generics.metal(1),
        fbcinv2:get_anchor("I"):translate(-bp.glength / 2 - (bp.gspace - bp.gstspace) / 2, -bp.gstwidth / 2),
        outinv1:get_anchor("I"):translate(0,  bp.gstwidth / 2)
    ))

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
