function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "fingers",       1 },
        { "gatetype", "nand" },
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 },
        { "swapinputs", false },
        { "shiftoutput", 0 }
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
            ncontacts[i] = "power"
        elseif i % 4 == 3 then
            ncontacts[i] = "inner"
        else
            ncontacts[i] = "unused"
        end
    end

    if _P.fingers % 2 == 1 then
        gatecontactpos[#gatecontactpos + 1] = "dummy"
        pcontacts[#pcontacts + 1] = "power"
        ncontacts[#ncontacts + 1] = "power"
    end

    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        gatecontactpos = gatecontactpos,
        pcontactpos = _P.gatetype == "nand" and pcontacts or ncontacts,
        ncontactpos = _P.gatetype == "nand" and ncontacts or pcontacts,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
    })
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate straps
    if _P.fingers > 1 then
        if _P.fingers % 2 == 0 then
            geometry.path(gate, generics.metal(1), 
                {
                    harness:get_anchor("G2cc"):translate(-bp.glength / 2, 0),
                    harness:get_anchor(string.format("G%dcc", 2 * _P.fingers - 1)):translate(bp.glength / 2, 0)
                }, bp.routingwidth
            )
            geometry.path(gate, generics.metal(1), 
                {
                    harness:get_anchor("G1cc"):translate(-bp.glength / 2, 0),
                    harness:get_anchor(string.format("G%dcc", 2 * _P.fingers)):translate(bp.glength / 2, 0)
                }, bp.routingwidth
            )
        else
            geometry.path(gate, generics.metal(1), 
                {
                    harness:get_anchor("G2cc"):translate(-bp.glength / 2, 0),
                    harness:get_anchor(string.format("G%dcc", 2 * _P.fingers)):translate(bp.glength / 2, 0)
                }, bp.routingwidth
            )
            geometry.path(gate, generics.metal(1), 
                {
                    harness:get_anchor("G1cc"):translate(-bp.glength / 2, 0),
                    harness:get_anchor(string.format("G%dcc", 2 * _P.fingers - 1)):translate(bp.glength / 2, 0)
                }, bp.routingwidth
            )
        end
    else
        geometry.rectanglebltr(gate, generics.metal(1), 
            (harness:get_area_anchor("G1").bl .. harness:get_area_anchor("G2").bl),
            harness:get_area_anchor("G2").tl
        )
        geometry.rectanglebltr(gate, generics.metal(1), 
            harness:get_area_anchor("G1").bl,
            (harness:get_area_anchor("G2").br .. harness:get_area_anchor("G1").tl)
        )
    end

    -- drain connection
    local yinvert = _P.gatetype == "nand" and 1 or -1
    local startpt, endpt
    local connpt = harness:get_area_anchor(string.format("G%d", 2 * _P.fingers)).bl:translate(xpitch + _P.shiftoutput, 0)
    if _P.gatetype == "nand" then
        startpt = harness:get_area_anchor("nSD3").tr:translate(0, -yinvert * bp.sdwidth / 2)
        endpt = harness:get_area_anchor("pSD2").br:translate(0, yinvert * bp.sdwidth / 2)
    else
        startpt = harness:get_area_anchor("pSD3").br:translate(0, -yinvert * bp.sdwidth / 2)
        endpt = harness:get_area_anchor(string.format("%sSD2", "n")).tr:translate(0, yinvert * bp.sdwidth / 2)
    end
    geometry.path_cshape(gate, generics.metal(1),
        startpt, endpt, connpt,
        bp.sdwidth
    )

    gate:add_port("A", generics.metalport(1), harness:get_area_anchor("G1").bl)
    gate:add_port("B", generics.metalport(1), harness:get_area_anchor("G2").bl)
    gate:add_port("O", generics.metalport(1), harness:get_area_anchor("G3").bl)
    gate:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    gate:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end
