function parameters()
    pcell.add_parameters(
        { "high", true },
        { "pwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "fingers", 2, posvals = even() }
    )
end

function layout(cell, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local gatecontactpos = util.fill_all_with(_P.fingers, "center")
    for i = 1, _P.fingers do gatecontactpos[i] = "center" end

    local contactpos = util.fill_even_with(_P.fingers + 1, "inner", "power")
    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    cell:merge_into(harness)
    cell:inherit_alignment_box(harness)

    -- gate strap
    geometry.rectanglebltr(
        cell, generics.metal(1),
        harness:get_area_anchor(string.format("G%d", 1)).bl,
        harness:get_area_anchor(string.format("G%d", _P.fingers)).tr
    )

    -- output strap
    local invert = _P.high and 1 or -1
    geometry.rectanglebltr(
        cell, generics.metal(1),
        harness:get_area_anchor(string.format("G%d", 1)).bl:translate(0, invert * (bp.routingwidth + bp.routingspace)),
        harness:get_area_anchor(string.format("G%d", _P.fingers)).tr:translate(0, invert * (bp.routingwidth + bp.routingspace))
    )

    -- connect drains to gate
    local where = _P.high and "n" or "p"
    for i = 2, _P.fingers, 2 do
        if _P.high then
            geometry.rectanglebltr(cell, generics.metal(1),
                harness:get_area_anchor(string.format("nSD%d", i)).tl,
                harness:get_area_anchor(string.format("nSD%d", i)).tr .. harness:get_area_anchor("G1").bl
            )
        else
            geometry.rectanglebltr(cell, generics.metal(1),
                harness:get_area_anchor(string.format("pSD%d", i)).bl .. harness:get_area_anchor("G1").tl,
                harness:get_area_anchor(string.format("pSD%d", i)).br
            )
        end
    end

    -- connect drains to output
    local where = _P.high and "n" or "p"
    for i = 2, _P.fingers, 2 do
        if _P.high then
            geometry.rectanglebltr(cell, generics.metal(1),
                harness:get_area_anchor(string.format("pSD%d", i)).bl:translate(0, -bp.routingspace),
                harness:get_area_anchor(string.format("pSD%d", i)).br
            )
        else
            geometry.rectanglebltr(cell, generics.metal(1),
                harness:get_area_anchor(string.format("nSD%d", i)).tl,
                harness:get_area_anchor(string.format("nSD%d", i)).tr:translate(0, bp.routingspace)
            )
        end
    end

    -- ports
    cell:add_port("O", generics.metalport(1), harness:get_area_anchor(string.format("%sSD%d", _P.high and "p" or "n", _P.fingers)).bl:translate(0, (_P.high and 1 or -1) * bp.sdwidth / 2))
    cell:add_port("VDD", generics.metalport(1), harness:get_area_anchor("PRp").bl)
    cell:add_port("VSS", generics.metalport(1), harness:get_area_anchor("PRn").bl)
end
