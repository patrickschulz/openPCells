function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "fingers",       1 },
        { "leftadapt",  true },
        { "rightadapt", true }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength

    -- common transistor options
    pcell.push_overwrites("basic/transistor", {
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
    })

    -- pmos
    pcell.push_overwrites("basic/transistor", {
        channeltype = "pmos",
        fwidth = bp.pwidth,
        drawtopgate = true,
        drawbotgcut = true,
        topgatestrwidth = bp.dummycontheight,
        topgatestrspace = bp.powerspace + bp.powerwidth / 2 - bp.dummycontheight / 2,
        gbotext = bp.separation / 2,
        clipbot = true,
        sourcesize = bp.pwidth / 2,
        drainsize  = bp.pwidth / 2,
        sourcealign = "top",
        drainalign  = "top",
    })
    if bp.rightdummies > 1 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = bp.rightdummies - 1 })
            :move_anchor("leftbotgate", point.create((_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if bp.leftdummies > 1 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = bp.leftdummies - 1 })
            :move_anchor("rightbotgate", point.create(-(_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if bp.rightdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = 1, drawoutersourcedrain = not _P.rightadapt })
            :move_anchor("leftbotgate", point.create(_P.fingers * xpitch / 2, 0))
        )
    end
    if bp.leftdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = 1, drawoutersourcedrain = not _P.leftadapt })
            :move_anchor("rightbotgate", point.create(-_P.fingers * xpitch / 2, 0))
        )
    end
    pcell.pop_overwrites("basic/transistor")

    -- nmos
    pcell.push_overwrites("basic/transistor", {
        channeltype = "nmos",
        fwidth = bp.nwidth,
        drawbotgate = true,
        drawtopgcut = true,
        botgatestrwidth = bp.dummycontheight,
        botgatestrspace = bp.powerspace + bp.powerwidth / 2 - bp.dummycontheight / 2,
        gtopext = bp.separation / 2,
        cliptop = true,
        sourcesize = bp.nwidth / 2,
        drainsize  = bp.nwidth / 2,
        sourcealign = "bottom",
        drainalign  = "bottom",
    })

    if bp.rightdummies > 1 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = bp.rightdummies - 1 })
            :move_anchor("lefttopgate", point.create((_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if bp.leftdummies > 1 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = bp.leftdummies - 1 })
            :move_anchor("righttopgate", point.create(-(_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if bp.rightdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = 1, drawoutersourcedrain = not _P.rightadapt })
            :move_anchor("lefttopgate", point.create(_P.fingers * xpitch / 2, 0))
        )
    end
    if bp.leftdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/transistor", { fingers = 1, drawoutersourcedrain = not _P.leftadapt })
            :move_anchor("righttopgate", point.create(-_P.fingers * xpitch / 2, 0))
        )
    end
    pcell.pop_overwrites("basic/transistor")
    -- pop general transistor settings
    pcell.pop_overwrites("basic/transistor")

    -- draw missing contacts
    if bp.leftdummies > 0 and _P.leftadapt then
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(-xpitch / 2 * (_P.fingers + 2), -bp.separation / 2 - bp.nwidth * 3 / 4))
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(-xpitch / 2 * (_P.fingers + 2), bp.separation / 2 + bp.pwidth * 3 / 4))
    end
    if bp.rightdummies > 0 and _P.rightadapt then
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(xpitch / 2 * (_P.fingers + 2), -bp.separation / 2 - bp.nwidth * 3 / 4))
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(xpitch / 2 * (_P.fingers + 2), bp.separation / 2 + bp.pwidth * 3 / 4))
    end

    -- power rails...
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), (_P.fingers + bp.leftdummies + bp.rightdummies) * xpitch + bp.sdwidth, bp.powerwidth),
        1, 2, 0, bp.separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
    ):translate((bp.rightdummies - bp.leftdummies) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))
    -- ... with connections
    if bp.leftdummies > 0 then
        gate:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
            bp.leftdummies, 2, xpitch, bp.separation + bp.pwidth + bp.nwidth + bp.powerspace
        ):translate(-(_P.fingers + bp.leftdummies + 1) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))
    end
    if bp.rightdummies > 0 then
        gate:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
            bp.rightdummies, 2, xpitch, bp.separation + bp.pwidth + bp.nwidth + bp.powerspace
        ):translate((_P.fingers + bp.rightdummies + 1) * xpitch / 2, (bp.pwidth - bp.nwidth) / 2))
    end
end
