function config()
    pcell.reference_cell("logic/base")
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "fingers",       1 },
        { "gatetype", "nand" },
        { "swapinputs", false }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local yinvert = _P.gatetype == "nand" and 1 or -1
    local block = object.create()

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

    pcell.push_overwrites("logic/base", { rightdummies = 0 })
    local harness = pcell.create_layout("logic/harness", { 
        fingers = 2 * _P.fingers,
        gatecontactpos = gatecontactpos,
    })
    gate:merge_into(harness)
    pcell.pop_overwrites("logic/base")

    -- gate straps
    if _P.fingers > 1 then
        if _P.fingers % 2 == 0 then
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G2"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers - 1))
                }, bp.gstwidth
            ))
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G1"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers))
                }, bp.gstwidth
            ))
        else
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G2"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers))
                }, bp.gstwidth
            ))
            gate:merge_into(geometry.path(generics.metal(1), 
                {
                    harness:get_anchor("G1"),
                    harness:get_anchor(string.format("G%d", 2 * _P.fingers - 1))
                }, bp.gstwidth
            ))
        end
    end

    -- TODO: improve structure by re-using statements
    -- pmos source/drain contacts
    if _P.gatetype == "nand" then
        block:merge_into(geometry.rectangle( -- drain contact
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(0, (bp.separation + bp.pwidth / 2) / 2))
        block:merge_into(geometry.multiple_x(  -- source contact
            geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.pwidth / 2),
            2, 2 * xpitch
        ):translate(0, bp.separation / 2 + bp.pwidth * 3 / 4))
        block:merge_into(geometry.multiple_x( -- source to power connection
            geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
            2, 2 * xpitch
        ):translate(0, bp.separation / 2 + bp.pwidth + bp.powerspace / 2))
        -- nmos source/drain contacts
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(-xpitch, -(bp.separation + bp.nwidth / 2) / 2))
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(xpitch, -bp.separation / 2 - bp.nwidth * 3 / 4))
        block:merge_into(geometry.rectangle(
            generics.metal(1), bp.sdwidth, bp.powerspace
        ):translate(xpitch, -bp.separation / 2 - bp.nwidth - bp.powerspace / 2))
    else -- nor
        -- pmos source/drain contacts
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(-xpitch, (bp.separation + bp.pwidth / 2) / 2))
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(xpitch, bp.separation / 2 + bp.pwidth * 3 / 4))
        block:merge_into(geometry.rectangle(
            generics.metal(1), bp.sdwidth, bp.powerspace
        ):translate(xpitch, bp.separation / 2 + bp.pwidth + bp.powerspace / 2))
        -- nmos source/drain contacts
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(0, -(bp.separation + bp.nwidth / 2) / 2))
        block:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.nwidth / 2),
            2, 2 * xpitch
        ):translate(0, -bp.separation / 2 - bp.nwidth * 3 / 4))
        block:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
            2, 2 * xpitch
        ):translate(0, -bp.separation / 2 - bp.nwidth - bp.powerspace / 2))
    end

    -- place block
    for i = 1, _P.fingers do
        local shift = 2 * (i - 1) - (_P.fingers - 1)
        if i % 2 == 0 then
            gate:merge_into(block:copy():flipx():translate(-shift * xpitch, 0))
        else
            gate:merge_into(block:copy():translate(-shift * xpitch, 0))
        end
    end
    
    -- drain connection
    local connpts
    local startpt = point.create(-(_P.fingers - 1) * xpitch, yinvert * (bp.separation + bp.sdwidth) / 2)
    local connpts = {
        (2 * _P.fingers - 1) * xpitch,
        -yinvert * (bp.separation + bp.sdwidth),
        -2 * _P.fingers * xpitch
    }
    if _P.fingers % 2 == 0 then
        connpts[#connpts] = connpts[#connpts] + 2 * xpitch
    end
    gate:merge_into(geometry.path(
        generics.metal(1),
        geometry.path_points_xy(startpt, connpts),
        bp.sdwidth,
        true
    ))

    gate:set_alignment_box(
        point.create(-(2 * _P.fingers + 2 * bp.leftdummies) * (bp.glength + bp.gspace) / 2, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2),
        point.create((2 * _P.fingers + 2 * bp.rightdummies) * (bp.glength + bp.gspace) / 2, bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2)
    )

    gate:add_anchor("A", harness:get_anchor("G1"))
    gate:add_anchor("B", harness:get_anchor("G2"))
    gate:add_anchor("Z", point.create(_P.fingers * (bp.glength + bp.gspace), 0))
end
