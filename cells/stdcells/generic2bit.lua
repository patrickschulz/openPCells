function parameters()
    pcell.add_parameters(
        { "fingers",                 1 },
        { "bitpattern", { 1, 1, 1, 0 } },
        { "swapinputs",          false },
        { "shiftoutput",             0 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local gatecontactpos = { }
    for i = 1, 2 * _P.fingers do
        if not _P.swapinputs then
            if i % 4 > 1 then
                gatecontactpos[i] = "upper"
            else
                gatecontactpos[i] = "lower"
            end
        else
            if i % 4 > 1 then
                gatecontactpos[i] = "lower"
            else
                gatecontactpos[i] = "upper"
            end
        end
    end

    local pcontacts = {}
    local ncontacts = {}
    for i = 1, 2 * _P.fingers + 1 do
        if i % 2 == 0 then
            pcontacts[i] = "inner"
        else
            pcontacts[i] = "power"
        end
        if i % 4 == 1 then
            ncontacts[i] = "inner"
        elseif i % 4 == 3 then
            ncontacts[i] = "power"
        end
    end

    --[[
    local harness = pcell.create_layout("stdcells/harness", "harness", {
        fingers = 2 * _P.fingers,
        gatecontactpos = gatecontactpos,
        pcontactpos = _P.gatetype == "nand" and pcontacts or ncontacts,
        ncontactpos = _P.gatetype == "nand" and ncontacts or pcontacts,
    })
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate straps
    if _P.fingers > 1 then
        if _P.fingers % 2 == 0 then
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G2"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers - 1))
                }, bp.routingwidth
            ))
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G1"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers))
                }, bp.routingwidth
            ))
        else
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G2"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers))
                }, bp.routingwidth
            ))
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G1"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers - 1))
                }, bp.routingwidth
            ))
        end
    else
        gate:merge_into(geometry.path(generics.metal(1), 
            {
                harness:get_anchor("G2"):translate(xpitch - bp.sdwidth / 2 - bp.routingspace, 0),
                (harness:get_anchor("G1") .. harness:get_anchor("G2")):translate(-xpitch + bp.sdwidth / 2 + bp.routingspace, 0),
            }, bp.routingwidth
        ))
        gate:merge_into(geometry.path(generics.metal(1), 
            {
                harness:get_anchor("G1"):translate(-xpitch + bp.sdwidth / 2 + bp.routingspace, 0),
                (harness:get_anchor("G2") .. harness:get_anchor("G1")):translate(xpitch - bp.sdwidth / 2 - bp.routingspace, 0),
            }, bp.routingwidth
        ))
    end

    -- drain connection
    local yinvert = _P.gatetype == "nand" and 1 or -1
    local startpt = harness:get_anchor(string.format("%sSDi1", _P.gatetype == "nand" and "n" or "p")):translate(0, -yinvert * bp.sdwidth / 2)
    local connpts = {
        harness:get_anchor(string.format("G%d", 2 * _P.fingers)):translate(xpitch + _P.shiftoutput, 0),
        0, -- toggle xy
        harness:get_anchor(string.format("%sSDi2", _P.gatetype == "nand" and "p" or "n")):translate(0, yinvert * bp.sdwidth / 2),
    }
    gate:merge_into(geometry.path(generics.metal(1), geometry.path_points_xy(
        startpt, connpts),
        bp.sdwidth)
    )

    gate:add_port("A", generics.metalport(1), harness:get_anchor("G1"))
    gate:add_port("B", generics.metalport(1), harness:get_anchor("G2"))
    gate:add_port("O", generics.metalport(1), (harness:get_anchor("G2") .. point.create(0, 0)):translate(xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))
    --]]
end
