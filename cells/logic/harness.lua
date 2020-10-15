function parameters()
    pcell.add_parameters(
        { "oxidetype",    "0.9" },
        { "pvthtype",    "slvt" },
        { "nvthtype",    "slvt" },
        { "pwidth",         500 },
        { "nwidth",         500 },
        { "glength",        100 },
        { "gspace",         150 },
        { "sdwidth",         60 },
        { "gstwidth",       100 },
        { "innerfingers",     1 },
        { "dummies",          1 },
        { "dummycontheight", 80 },
        { "separation",     400 },
        { "powerwidth",     200 },
        { "powerspace",     100 }
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
    if _P.dummies > 0 then
        pcell.overwrite_defaults("transistor", { 
            fingers = _P.dummies,
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
        gate:merge_into(pcell.create_layout("transistor"):move_anchor("leftbotgate", point.create(_P.innerfingers * xpitch / 2, 0)))
        gate:merge_into(pcell.create_layout("transistor"):move_anchor("rightbotgate", point.create(-_P.innerfingers * xpitch / 2, 0)))
        pcell.restore_defaults("transistor")
    end

    -- nmos
    if _P.dummies > 0 then
        local opt = { 
            fingers = _P.dummies,
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
        }
        gate:merge_into(pcell.create_layout("transistor", opt):move_anchor("lefttopgate", point.create(_P.innerfingers * xpitch / 2, 0)))
        gate:merge_into(pcell.create_layout("transistor", opt):move_anchor("righttopgate", point.create(-_P.innerfingers  * xpitch / 2, 0)))
    end

    pcell.restore_defaults("transistor")

    -- power rails...
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), (_P.innerfingers + 2 * _P.dummies) * xpitch + _P.sdwidth, _P.powerwidth),
        1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
    ):translate(0, (_P.pwidth - _P.nwidth) / 2))
    -- ... with connections
    for i = -1, 1, 2 do
        gate:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
            _P.dummies + 1, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        ):translate(i * (_P.innerfingers + _P.dummies) * xpitch / 2, (_P.pwidth - _P.nwidth) / 2))
    end
end
