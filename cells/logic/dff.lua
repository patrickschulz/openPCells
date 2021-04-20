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
    pcell.add_parameter("clockpolarity", "positiv", { posvals = set("positiv", "negativ") })
    pcell.add_parameter("enableQ", true)
    pcell.add_parameter("enableQN", false)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength
    local routingshift = bp.sdwidth / 2 + (bp.separation - 2 * bp.sdwidth) / 6

    -- general settings
    pcell.push_overwrites("logic/base", {
        leftdummies = 0,
        rightdummies = 0
    })

    -- clock inverter/buffer
    pcell.push_overwrites("logic/base", { rightdummies = 1 })
    local clockinv1 = pcell.create_layout("logic/not_gate", { shiftinput = routingshift, shiftoutput = xpitch / 2 })
    pcell.pop_overwrites("logic/base")
    local clockinv2 = pcell.create_layout("logic/not_gate", { shiftinput = routingshift, shiftoutput = xpitch / 2 }):move_anchor("left", clockinv1:get_anchor("right"))
    gate:merge_into(clockinv1)
    gate:merge_into(clockinv2)

    -- isolation dummy
    local isogate = pcell.create_layout("logic/isogate")
    isogate:move_anchor("left", clockinv2:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- first clocked inverter
    local cinv = pcell.create_layout("logic/cinv", { swapoutputs = true, inputpos = "lower", shiftoutput = xpitch * 3 / 2 }):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(cinv)

    isogate:move_anchor("left", cinv:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- first feedback inverter cell
    pcell.push_overwrites("logic/base", { connectoutput = false })
    pcell.push_overwrites("logic/harness", { shiftpcontactsinner = bp.pwidth / 2, shiftncontactsinner = bp.nwidth / 2 })
    local fbinv1 = pcell.create_layout("logic/not_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(fbinv1)
    pcell.pop_overwrites("logic/base")
    pcell.pop_overwrites("logic/harness")

    isogate:move_anchor("left", fbinv1:get_anchor("right"))
    gate:merge_into(isogate:copy())

    pcell.push_overwrites("logic/base", { connectoutput = true })
    local fbcinv1 = pcell.create_layout("logic/cinv", { swapinputs = false, swapoutputs = true, shiftoutput = xpitch * 3 / 2 }):move_anchor("left", isogate:get_anchor("right"))
    fbcinv1:flipx()
    gate:merge_into(fbcinv1)
    pcell.pop_overwrites("logic/base")

    isogate:move_anchor("left", fbcinv1:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- transmission gate
    local tgate = pcell.create_layout("logic/tgate", { shiftinput = xpitch * 3 / 2, shiftoutput = xpitch / 2 }):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(tgate)

    isogate:move_anchor("left", tgate:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- second feedback inverter cell
    pcell.push_overwrites("logic/base", { connectoutput = false })
    pcell.push_overwrites("logic/harness", { shiftpcontactsinner = bp.pwidth / 2, shiftncontactsinner = bp.nwidth / 2 })
    local fbinv2 = pcell.create_layout("logic/not_gate", { inputpos = "lower" }):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(fbinv2)
    pcell.pop_overwrites("logic/base")
    pcell.pop_overwrites("logic/harness")

    isogate:move_anchor("left", fbinv2:get_anchor("right"))
    gate:merge_into(isogate:copy())

    pcell.push_overwrites("logic/base", { connectoutput = true })
    local fbcinv2 = pcell.create_layout("logic/cinv", { inputpos = "lower", swapinputs = false, swapoutputs = true, shiftoutput = xpitch * 5 / 2 }):move_anchor("left", isogate:get_anchor("right"))
    fbcinv2:flipx()
    gate:merge_into(fbcinv2)
    pcell.pop_overwrites("logic/base")

    -- pop general settings (restores correct number of right dummies for the entire cell)
    pcell.pop_overwrites("logic/base")

    -- output buffer
    pcell.push_overwrites("logic/base", {
        leftdummies = 0
    })
    local outbuf
    if _P.enableQ and _P.enableQN then
        outbuf = pcell.create_layout("logic/buf"):move_anchor("left", fbcinv2:get_anchor("right"))
    else
        outbuf = pcell.create_layout("logic/not_gate", { inputpos = "lower", shiftoutput = xpitch / 2 }):move_anchor("left", fbcinv2:get_anchor("right"))
    end
    pcell.pop_overwrites("logic/base")
    gate:merge_into(outbuf)

    -- draw connections
    -- fbinv.O to fbcinv.I
    gate:merge_into(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv1:get_anchor("OTR"), {
            2 * xpitch,
            -bp.pwidth * 3 / 4 + bp.sdwidth / 2,
            fbcinv1:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv1:get_anchor("OBR"), {
            2 * xpitch,
            bp.nwidth * 3 / 4 - bp.sdwidth / 2,
            fbcinv1:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv2:get_anchor("OTR"), {
            2 * xpitch,
            -bp.pwidth * 3 / 4 + bp.sdwidth / 2,
            outbuf:get_anchor("I")
        }),
    bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), 
        geometry.path_points_xy(fbinv2:get_anchor("OBR"), {
            2 * xpitch,
            bp.nwidth * 3 / 4 - bp.sdwidth / 2,
            outbuf:get_anchor("I")
        }),
    bp.sdwidth))

    -- tgate to fbinv2
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        tgate:get_anchor("O"),
        fbinv2:get_anchor("I")
    }, bp.sdwidth))

    -- clk connections
    if _P.clockpolarity == "positiv" then
        -- M2 bars
        gate:merge_into(geometry.path_xy(generics.metal(2), {
            clockinv2:get_anchor("OTR"):translate(0, -bp.pwidth / 4 + bp.sdwidth / 2),
            fbcinv1:get_anchor("EP") + point.create(-2 * xpitch, 0),
            fbcinv2:get_anchor("EP") + point.create(-xpitch, 0)
        }, bp.sdwidth))
        gate:merge_into(geometry.path(generics.metal(2), 
            geometry.path_points_xy(
                point.combine_12(clockinv1:get_anchor("O"), fbcinv2:get_anchor("EP")), {
                fbcinv1:get_anchor("EN") + point.create(-3 * xpitch, 0),
                outbuf:get_anchor("I"),
                0,
                fbcinv2:get_anchor("EP")
        }), bp.sdwidth))
        -- vias
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(clockinv2:get_anchor("OTR"):translate(0, -bp.pwidth / 4 + bp.sdwidth / 2)))
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth + xpitch, bp.sdwidth)
            :translate(point.combine_12(clockinv1:get_anchor("O"), tgate:get_anchor("EP")):translate(xpitch / 2, 0)))

        -- cinv clk connection
        gate:merge_into(geometry.path(generics.metal(1), 
            geometry.path_points_xy(clockinv2:get_anchor("OBR"):translate(0, bp.nwidth / 4 - bp.sdwidth / 2), {
                cinv:get_anchor("EN"),
                --xpitch
            }),
        bp.sdwidth))
        -- cinv ~clk connection
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(cinv:get_anchor("EP"):translate(-xpitch / 2, 0)))

        -- fbcinv2 connections
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EP"):translate(-xpitch * 3 / 2, 0)))
        gate:merge_into(geometry.path_yx(generics.metal(1), {
            fbcinv2:get_anchor("EP") + point.create(-xpitch, 0),
            fbcinv2:get_anchor("EN")
        }, bp.sdwidth))
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EP"):translate(xpitch / 2, 0)))
    else
        -- M2 bars
        gate:merge_into(geometry.path(generics.metal(2), {
            point.combine_12(clockinv2:get_anchor("O"), fbcinv2:get_anchor("EN")),
            fbcinv2:get_anchor("EN") + point.create(-xpitch, 0)
        }, bp.sdwidth))
        gate:merge_into(geometry.path_xy(generics.metal(2), {
            point.combine_12(clockinv1:get_anchor("O"), fbcinv2:get_anchor("EP")),
            fbcinv2:get_anchor("EN")
        }, bp.sdwidth))
        -- vias
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth)
            :translate(point.combine_12(clockinv2:get_anchor("O"), tgate:get_anchor("EN"))))
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth)
            :translate(point.combine_12(clockinv1:get_anchor("O"), tgate:get_anchor("EP"))))

        -- cinv clk connection
        gate:merge_into(geometry.path(generics.metal(1), 
            geometry.path_points_xy(clockinv2:get_anchor("OTR"):translate(0, -bp.pwidth / 4 + bp.sdwidth / 2), {
                cinv:get_anchor("EP")
            }),
        bp.sdwidth))
        -- cinv ~clk connection
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth)
            :translate(cinv:get_anchor("EP") + point.create(xpitch, 0)))
        gate:merge_into(geometry.path(generics.metal(1), 
            geometry.path_points_yx(cinv:get_anchor("EP") + point.create(xpitch, 0), {
                cinv:get_anchor("EN")
            }),
        bp.sdwidth))

        -- fbcinv2 connections
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), bp.sdwidth, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EN") + point.create(-xpitch, 0)))
        gate:merge_into(geometry.path_yx(generics.metal(1), {
            fbcinv2:get_anchor("EN") + point.create(-xpitch, 0),
            fbcinv2:get_anchor("EP")
        }, bp.sdwidth))
        gate:merge_into(
            geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth)
            :translate(fbcinv2:get_anchor("EN"):translate(xpitch / 2, 0)))
    end
    -- ~clk connections vias
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(fbcinv1:get_anchor("EP"):translate(-xpitch / 2, 0)))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(fbcinv1:get_anchor("EN"):translate(-xpitch / 2, 0)))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(tgate:get_anchor("EP"):translate(-xpitch / 2, 0)))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 2 * bp.glength + bp.gspace, bp.sdwidth):translate(tgate:get_anchor("EN"):translate(-xpitch / 2, 0)))

    -- input connection
    gate:merge_into(geometry.rectangle(generics.via(1, 2), 
        bp.glength, bp.sdwidth):translate(cinv:get_anchor("I")))
    gate:merge_into(geometry.path(generics.metal(2), {
        cinv:get_anchor("I"),
        point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I"))
    }, bp.sdwidth))
    gate:merge_into(
        geometry.rectangle(generics.via(1, 2), 
        bp.glength,
        --2 * bp.glength + bp.gspace, 
    bp.sdwidth):translate(point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I"))))

    -- output connection
    gate:merge_into(geometry.path(generics.metal(1), {
        fbcinv2:get_anchor("I"),
        outbuf:get_anchor("I"),
    }, bp.sdwidth))

    -- inherit alignment boxes, only use most-left and most-right block
    gate:inherit_alignment_box(clockinv1)
    gate:inherit_alignment_box(outbuf)

    -- ports
    gate:add_port("D", generics.metal(1), point.combine_21(cinv:get_anchor("I"), clockinv1:get_anchor("I")))
    if _P.enableQ and _P.enableQN then
        gate:add_port("Q", generics.metal(1), outbuf:get_anchor("iout"))
        gate:add_port("QN", generics.metal(1), outbuf:get_anchor("O"))
    elseif _P.enableQ then
        gate:add_port("Q", generics.metal(1), outbuf:get_anchor("O"))
    elseif _P.enableQN then
        gate:add_port("QN", generics.metal(1), outbuf:get_anchor("O"))
    end
    gate:add_port("CLK", generics.metal(1), clockinv1:get_anchor("I"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
