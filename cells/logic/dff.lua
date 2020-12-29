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
    pcell.inherit_all_parameters("logic/_base")
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/_base")

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/_base", {
        leftdummies = 0,
        rightdummies = 0
    })

    -- clock inverter/buffer
    local clockbuf = pcell.create_layout("logic/buf"):move_anchor("right")
    gate:merge_into(clockbuf)

    -- isolation dummy
    local isogate = pcell.create_layout("logic/_isogate")
    isogate:move_anchor("left", clockbuf:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- first clocked inverter
    local cinv1 = pcell.create_layout("logic/cinv", { swapoutputs = true }):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(cinv1)

    isogate:move_anchor("left", cinv1:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- first feedback inverter cell
    local fbinv1 = pcell.create_layout("logic/not_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(fbinv1)

    isogate:move_anchor("left", fbinv1:get_anchor("right"))
    gate:merge_into(isogate:copy())

    local fbcinv1 = pcell.create_layout("logic/cinv", { drawoutputs = false, swapinputs = false, swapoutputs = true }):move_anchor("left", isogate:get_anchor("right"))
    fbcinv1:flipx()
    gate:merge_into(fbcinv1)

    isogate:move_anchor("left", fbcinv1:get_anchor("left"))
    gate:merge_into(isogate:copy())

    -- transmission gate
    local tgate = pcell.create_layout("logic/tgate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(tgate)

    isogate:move_anchor("left", tgate:get_anchor("right"))
    gate:merge_into(isogate:copy())

    -- second feedback inverter cell
    local fbinv2 = pcell.create_layout("logic/not_gate"):move_anchor("left", isogate:get_anchor("right"))
    gate:merge_into(fbinv2)

    isogate:move_anchor("left", fbinv2:get_anchor("right"))
    gate:merge_into(isogate:copy())

    local fbcinv2 = pcell.create_layout("logic/cinv", { drawoutputs = false, swapinputs = false, swapoutputs = true }):move_anchor("left", isogate:get_anchor("right"))
    fbcinv2:flipx()
    gate:merge_into(fbcinv2)

    -- pop general settings (restores correct number of right dummies for the entire cell)
    pcell.pop_overwrites("logic/_base")

    -- output buffer
    pcell.push_overwrites("logic/_base", {
        leftdummies = 0
    })
    local outbuf = pcell.create_layout("logic/not_gate"):move_anchor("left", fbcinv2:get_anchor("left"))
    pcell.pop_overwrites("logic/_base")
    gate:merge_into(outbuf)

    -- draw connections
    gate:merge_into(geometry.path(generics.metal(1), {
        cinv1:get_anchor("O"),
        fbinv1:get_anchor("I"),
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), {
        fbinv1:get_anchor("O"),
        tgate:get_anchor("I"),
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), {
        fbinv1:get_anchor("O"),
        fbcinv1:get_anchor("I"),
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), {
        fbinv2:get_anchor("O"),
        fbcinv2:get_anchor("I"),
    }, bp.sdwidth))
    for _, c in ipairs({ fbcinv1, fbcinv2 }) do
        gate:merge_into(geometry.path(generics.metal(1), 
            point.relative_array(c:get_anchor("O"),
            {
                { 0, bp.separation / 2 + bp.pwidth / 2 },
                { 0, 100 },
                { - 3 * xpitch / 2, 0 },
                { 0, -bp.separation / 2 - bp.pwidth / 2 - 100 },
                { 0, -bp.separation / 2 - bp.nwidth / 2 - 100 },
                { 3 * xpitch / 2, 0 },
                { 0, 100 },
            },
            true -- skip first point
        ), bp.sdwidth))
    end
    gate:merge_into(geometry.path(generics.metal(2), {
        point.combine_xy(clockbuf:get_anchor("iout"), fbcinv2:get_anchor("EP")),
        fbcinv2:get_anchor("EP")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(2), {
        point.combine_xy(clockbuf:get_anchor("bout"), fbcinv2:get_anchor("EN")),
        fbcinv2:get_anchor("EN")
    }, bp.sdwidth))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(fbcinv1:get_anchor("EP")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(fbcinv1:get_anchor("EN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(tgate:get_anchor("EP")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(tgate:get_anchor("EN")))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(fbcinv2:get_anchor("EP") + point.create(-xpitch / 2, 0)))
    gate:merge_into(geometry.rectangle(generics.via(1, 2), bp.glength, bp.sdwidth):translate(fbcinv2:get_anchor("EN") + point.create( xpitch / 2, 0)))
    gate:merge_into(geometry.rectangle(generics.via(1, 2),
        bp.sdwidth, bp.sdwidth
    ):translate(point.combine_xy(clockbuf:get_anchor("bout"), fbcinv2:get_anchor("EN"))))
    gate:merge_into(geometry.rectangle(generics.via(1, 2),
        bp.sdwidth, bp.sdwidth
    ):translate(point.combine_xy(clockbuf:get_anchor("iout"), fbcinv2:get_anchor("EP"))))
    gate:merge_into(geometry.path(generics.metal(1), {
        tgate:get_anchor("O"),
        fbinv2:get_anchor("I")
    }, bp.sdwidth))

    -- ports
    gate:add_port("D", generics.metal(1), cinv1:get_anchor("I"))
    gate:add_port("Q", generics.metal(1), outbuf:get_anchor("O"))
    gate:add_port("CLK", generics.metal(1), clockbuf:get_anchor("in"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
