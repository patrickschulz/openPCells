function parameters()
    pcell.add_parameters(
        { "high", true },
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "fingers", 4, posvals = even() }
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
        harness:get_anchor(string.format("G%dbl", 1)),
        harness:get_anchor(string.format("G%dtr", _P.fingers))
    )

    -- connect drain to gate
    local where = _P.high and "n" or "p"
    for i = 2, _P.fingers, 2 do
        geometry.path(
            cell, generics.metal(1),
            {
                harness:get_anchor(string.format("%sSDi%d", where, i)),
                harness:get_anchor(string.format("%sSDi%d", where, i)) ..  harness:get_anchor(string.format("G%dbc", 1))
            },
            bp.sdwidth
        )
    end

    if _P.fingers > 2 then
        local where = _P.high and "p" or "n"
        geometry.path(cell, generics.metal(1),
            {
                harness:get_anchor(string.format("%sSDi%d", where, 2)):translate(0, (_P.high and 1 or -1) * bp.sdwidth / 2),
                harness:get_anchor(string.format("%sSDi%d", where, _P.fingers)):translate(0, (_P.high and 1 or -1) * bp.sdwidth / 2)
            },
            bp.sdwidth
        )
    end

    -- ports
    cell:add_port("O", generics.metalport(1), harness:get_anchor(string.format("%sSDi%d", _P.high and "p" or "n", _P.fingers)):translate(0, (_P.high and 1 or -1) * bp.sdwidth / 2))
    cell:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    cell:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))
end
