function config()
    pcell.reference_cell("basic/transistor")
    pcell.reference_cell("logic/base")
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "fingers",       1 },
        { "pcontactpos", { nil, nil } },
        { "ncontactpos", { nil, nil } },
        { "leftadapt",  true },
        { "rightadapt", true }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local fingers = _P.fingers + bp.leftdummies + bp.rightdummies

    -- common transistor options
    pcell.push_overwrites("basic/transistor", {
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none"
    })

    -- pmos
    gate:merge_into(
        pcell.create_layout("basic/transistor", { 
            channeltype = "pmos",
            fingers = fingers,
            vthtype = bp.pvthtype,
            fwidth = bp.pwidth,
            gbotext = bp.separation / 2,
            gtopext = bp.powerspace + bp.powerwidth,
            clipbot = true,
        }):move_anchor("botgate", point.create(0, 0))
    )

    -- nmos
    gate:merge_into(
        pcell.create_layout("basic/transistor", { 
            channeltype = "nmos",
            fingers = fingers,
            vthtype = bp.nvthtype,
            fwidth = bp.nwidth,
            gtopext = bp.separation / 2,
            gbotext = bp.powerspace + bp.powerwidth,
            cliptop = true,
        }):move_anchor("topgate", point.create(0, 0))
    )

    -- pop general transistor settings
    pcell.pop_overwrites("basic/transistor")

    -- power rails
    gate:merge_into(geometry.multiple_y(
        geometry.rectangle(generics.metal(1), (_P.fingers + bp.leftdummies + bp.rightdummies) * xpitch + bp.sdwidth, bp.powerwidth),
        2, bp.separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
    ):translate(0, (bp.pwidth - bp.nwidth) / 2))

    -- draw gate contacts
    for i = 1, _P.fingers do
        gate:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate((2 * i - _P.fingers - 1 + bp.leftdummies - bp.rightdummies) * xpitch / 2, 0))
    end
    gate:merge_into(geometry.multiple_xy(
        geometry.rectangle(generics.contact("gate"), bp.glength, bp.powerwidth),
        bp.leftdummies, 2, xpitch, bp.separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
    ):translate(-(_P.fingers + bp.rightdummies) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))
    gate:merge_into(geometry.multiple_xy(
        geometry.rectangle(generics.contact("gate"), bp.glength, bp.powerwidth),
        bp.rightdummies, 2, xpitch, bp.separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
    ):translate( (_P.fingers + bp.leftdummies) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))

    -- dummy source/drain contacts
    gate:merge_into(geometry.multiple_x(
        geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.pwidth / 2),
        bp.leftdummies, xpitch
    ):translate(-(_P.fingers + bp.rightdummies + 1) * xpitch / 2, bp.separation / 2 + bp.pwidth * 3 / 4))
    gate:merge_into(geometry.multiple_x(
        geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.nwidth / 2),
        bp.leftdummies, xpitch
    ):translate(-(_P.fingers + bp.rightdummies + 1) * xpitch / 2, -bp.separation / 2 - bp.nwidth * 3 / 4))
    gate:merge_into(geometry.multiple_xy(
        geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
        bp.leftdummies, 2, xpitch, bp.separation + bp.pwidth + bp.nwidth + bp.powerspace
    ):translate(-(_P.fingers + bp.rightdummies + 1) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))
    gate:merge_into(geometry.multiple_x(
        geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.pwidth / 2),
        bp.rightdummies, xpitch
    ):translate( (_P.fingers + bp.leftdummies + 1) * xpitch / 2, bp.separation / 2 + bp.pwidth * 3 / 4))
    gate:merge_into(geometry.multiple_x(
        geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.nwidth / 2),
        bp.rightdummies, xpitch
    ):translate( (_P.fingers + bp.leftdummies + 1) * xpitch / 2, -bp.separation / 2 - bp.nwidth * 3 / 4))
    gate:merge_into(geometry.multiple_xy(
        geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
        bp.rightdummies, 2, xpitch, bp.separation + bp.pwidth + bp.nwidth + bp.powerspace
    ):translate( (_P.fingers + bp.leftdummies + 1) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))

    -- source/drain between main transistors and dummies
    --gate:merge_into(geometry.multiple_y(
    --    geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.pwidth / 2),
    --    2, bp.separation + bp.pwidth * 3 / 4 + bp.nwidth * 3 / 4
    --):translate(-(_P.fingers - bp.leftdummies + bp.rightdummies) * xpitch / 2, bp.pwidth - bp.nwidth))
    --gate:merge_into(geometry.multiple_y(
    --    geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
    --    2, bp.separation + bp.pwidth + bp.nwidth + bp.powerspace
    --):translate(-(_P.fingers - bp.leftdummies + bp.rightdummies) * xpitch / 2, bp.pwidth - bp.nwidth))
    --gate:merge_into(geometry.multiple_y(
    --    geometry.rectangle(generics.contact("active"), bp.sdwidth, bp.pwidth / 2),
    --    2, bp.separation + bp.pwidth * 3 / 4 + bp.nwidth * 3 / 4
    --):translate( (_P.fingers + bp.leftdummies - bp.rightdummies) * xpitch / 2, bp.pwidth - bp.nwidth))
    --gate:merge_into(geometry.multiple_y(
    --    geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
    --    2, bp.separation + bp.pwidth + bp.nwidth + bp.powerspace
    --):translate( (_P.fingers + bp.leftdummies - bp.rightdummies) * xpitch / 2, bp.pwidth - bp.nwidth))

    -- draw source/drain contacts
    local indexshift = _P.fingers / 2 + 1
    for i = 1, _P.fingers + 1 do
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "top" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), bp.sdwidth, bp.pwidth / 2
            ):translate((i - indexshift) * xpitch, bp.separation / 2 + bp.pwidth * 3 / 4))
            if _P.pcontactpos[i] == "power" then
                gate:merge_into(geometry.rectangle(
                    generics.metal(1), bp.sdwidth, bp.powerspace)
                :translate((i - indexshift) * xpitch, bp.separation / 2 + bp.pwidth + bp.powerspace / 2))
            end
        end
        if _P.pcontactpos[i] == "bottom" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), bp.sdwidth, bp.pwidth / 2
            ):translate((i - indexshift) * xpitch, bp.separation / 2 + bp.pwidth / 4))
        end
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "bottom" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), bp.sdwidth, bp.nwidth / 2
            ):translate((i - indexshift) * xpitch, -bp.separation / 2 - bp.nwidth * 3 / 4))
            if _P.ncontactpos[i] == "power" then
                gate:merge_into(geometry.rectangle(
                    generics.metal(1), bp.sdwidth, bp.powerspace)
                :translate((i - indexshift) * xpitch, -bp.separation / 2 - bp.nwidth - bp.powerspace / 2))
            end
        end
        if _P.ncontactpos[i] == "top" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), bp.sdwidth, bp.pwidth / 2
            ):translate((i - indexshift) * xpitch, -bp.separation / 2 - bp.pwidth / 4))
        end
    end

    gate:set_alignment_box(
        point.create(-(_P.fingers + 2 * bp.leftdummies) * (bp.glength + bp.gspace) / 2, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2),
        point.create((_P.fingers + 2 * bp.rightdummies) * (bp.glength + bp.gspace) / 2, bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2)
    )
end
