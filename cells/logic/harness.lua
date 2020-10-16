function parameters()
    pcell.inherit_all_parameters("logic/_base")
    pcell.add_parameters(
        { "leftadapt",  false },
        { "rightadapt", false }
    )
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    -- common transistor options
    pcell.overwrite_defaults("transistor", { 
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
    })

    -- pmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "pmos",
        fwidth = _P.pwidth,
        drawtopgate = true,
        topgatestrwidth = _P.dummycontheight,
        topgatestrspace = _P.powerspace,
        gbotext = _P.separation / 2,
        clipbot = true,
        outersourcedrainsize = _P.pwidth / 2,
        innersourcedrainsize = _P.pwidth / 2,
        outersourcedrainalign = "top",
        innersourcedrainalign = "top",
    })
    if _P.rightdummies > 1 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = _P.rightdummies - 1 })
            :move_anchor("leftbotgate", point.create((_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if _P.leftdummies > 1 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = _P.leftdummies - 1 })
            :move_anchor("rightbotgate", point.create(-(_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if _P.rightdummies > 0 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = 1, drawoutersourcedrain = not _P.rightadapt })
            :move_anchor("leftbotgate", point.create(_P.fingers * xpitch / 2, 0))
        )
    end
    if _P.leftdummies > 0 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = 1, drawoutersourcedrain = not _P.leftadapt })
            :move_anchor("rightbotgate", point.create(-_P.fingers * xpitch / 2, 0))
        )
    end
    pcell.restore_defaults("transistor")

    -- nmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "nmos",
        fwidth = _P.nwidth,
        drawbotgate = true,
        botgatestrwidth = _P.dummycontheight,
        botgatestrspace = _P.powerspace,
        gtopext = _P.separation / 2,
        cliptop = true,
        outersourcedrainsize = _P.nwidth / 2,
        innersourcedrainsize = _P.nwidth / 2,
        outersourcedrainalign = "bottom",
        innersourcedrainalign = "bottom",
    })

    if _P.rightdummies > 1 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = _P.rightdummies - 1 })
            :move_anchor("lefttopgate", point.create((_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if _P.leftdummies > 1 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = _P.leftdummies - 1 })
            :move_anchor("righttopgate", point.create(-(_P.fingers + 2) * xpitch / 2, 0))
        )
    end
    if _P.rightdummies > 0 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = 1, drawoutersourcedrain = not _P.rightadapt })
            :move_anchor("lefttopgate", point.create(_P.fingers * xpitch / 2, 0))
        )
    end
    if _P.leftdummies > 0 then
        gate:merge_into(
            pcell.create_layout("transistor", { fingers = 1, drawoutersourcedrain = not _P.leftadapt })
            :move_anchor("righttopgate", point.create(-_P.fingers * xpitch / 2, 0))
        )
    end
    pcell.restore_defaults("transistor")

    -- draw missing contacts
    if _P.leftdummies > 0 and _P.leftadapt then
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), _P.sdwidth, _P.nwidth / 2
        ):translate(-xpitch / 2 * (_P.fingers + 2), -_P.separation / 2 - _P.nwidth * 3 / 4))
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), _P.sdwidth, _P.pwidth / 2
        ):translate(-xpitch / 2 * (_P.fingers + 2), _P.separation / 2 + _P.pwidth * 3 / 4))
    end
    if _P.rightdummies > 0 and _P.rightadapt then
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), _P.sdwidth, _P.nwidth / 2
        ):translate(xpitch / 2 * (_P.fingers + 2), -_P.separation / 2 - _P.nwidth * 3 / 4))
        gate:merge_into(geometry.rectangle(
            generics.contact("active"), _P.sdwidth, _P.pwidth / 2
        ):translate(xpitch / 2 * (_P.fingers + 2), _P.separation / 2 + _P.pwidth * 3 / 4))
    end

    -- power rails...
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), (_P.fingers + _P.leftdummies + _P.rightdummies) * xpitch + _P.sdwidth, _P.powerwidth),
        1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
    ):translate((_P.rightdummies - _P.leftdummies) * xpitch / 2, (_P.pwidth - _P.nwidth) / 2))
    -- ... with connections
    if _P.leftdummies > 0 then
        gate:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
            _P.leftdummies, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        ):translate(-(_P.fingers + _P.leftdummies + 1) * xpitch / 2, (_P.pwidth - _P.nwidth) / 2))
    end
    if _P.rightdummies > 0 then
        gate:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
            _P.rightdummies, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        ):translate((_P.fingers + _P.rightdummies + 1) * xpitch / 2, (_P.pwidth - _P.nwidth) / 2))
    end
end
