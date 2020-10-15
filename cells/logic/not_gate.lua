function parameters()
    pcell.add_parameters(
        { "oxidetype",      "0.9" },
        { "pvthtype",      "slvt" },
        { "nvthtype",      "slvt" },
        { "pwidth",           500 },
        { "nwidth",           500 },
        { "glength",          100 },
        { "gspace",           150 },
        { "gext",             100 },
        { "sdwidth",           60 },
        { "gstwidth",         100 },
        { "fingers",            2 },
        { "dummies",            1 },
        { "dummycontheight",   80 },
        { "separation",       400 },
        { "ttypeext",         100 },
        { "powerwidth",       200 },
        { "powerspace",       100 },
        { "conngate",           1 },
        { "connmetal",          3 },
        { "connwidth",        100 },
        { "connoffset",         1 }
    )
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    gate:merge_into(pcell.create_layout("logic/harness", { innerfingers = _P.fingers, dummies = _P.dummies, dummycontheight = _P.dummycontheight }))

    -- common transistor options
    pcell.overwrite_defaults("transistor", {
        fingers = _P.fingers, gatelength = _P.glength, gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
    })

    -- pfet
    local pmos = pcell.create_layout("transistor",
        {
            channeltype = "pmos",
            fwidth = _P.pwidth,
            gtopext = _P.powerspace + _P.dummycontheight,
            drawbotgate = true, botgatestrwidth = _P.gstwidth, botgatestrspace = (_P.separation - _P.gstwidth) / 2,
            clipbot = true,
            innersourcedrainsize = _P.pwidth / 2,
            innersourcedrainalign = "top",
            outersourcedrainsize = _P.pwidth / 2,
            outersourcedrainalign = "top"
        }
    ):move_anchor("botgate")
    gate:merge_into(pmos)

    -- nfet
    local nmos = pcell.create_layout("transistor",
        {
            channeltype = "nmos",
            fingers = _P.fingers, gatelength = _P.glength, fwidth = _P.pwidth, gatespace = _P.gspace,
            sdwidth = _P.sdwidth,
            gbotext = _P.powerspace + _P.dummycontheight, gtopext = _P.separation / 2,
            drawtopgate = true, topgatestrwidth = _P.gstwidth, topgatestrspace = (_P.separation - _P.gstwidth) / 2,
            cliptop = true,
            drawinnersourcedrain = false,
            outersourcedrainsize = _P.nwidth / 2,
            outersourcedrainalign = "bottom"
        }
    ):move_anchor("topgate")
    gate:merge_into(nmos)

    -- signal transistors source connections
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
        _P.fingers / 2 + 1, 2,
        2 * xpitch, _P.nwidth + _P.pwidth + _P.separation + _P.powerspace
    ):translate(0, 0.5 * (_P.pwidth - _P.nwidth)))

    -- signal transistors drain connections
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(_P.connmetal), (_P.fingers - 1 + _P.connoffset) * xpitch, _P.connwidth),
        1, 2, 0, 0.5 * (_P.nwidth + _P.pwidth) + _P.separation
    ):translate(0.5 * (1 + _P.connoffset) * xpitch, 0.25 * (_P.pwidth - _P.nwidth)))
    gate:merge_into(geometry.rectangle(
        generics.metal(_P.connmetal), 
        _P.connwidth, 0.5 * (_P.nwidth + _P.pwidth) + _P.separation + _P.connwidth
    ):translate((0.5 * _P.fingers + _P.connoffset) * xpitch, 0.25 * (_P.pwidth - _P.nwidth)))
    for i = 1, math.floor(_P.fingers / 2) do
        gate:merge_into(geometry.rectangle(
            generics.via(1, _P.connmetal), 
            _P.sdwidth, _P.pwidth
        ):translate((i - 0.25 * _P.fingers - 0.5) * 2 * xpitch, 0.5 * (_P.pwidth + _P.separation)))
        gate:merge_into(geometry.rectangle(
            generics.via(1, _P.connmetal), 
            _P.sdwidth, _P.nwidth
        ):translate((i - 0.25 * _P.fingers - 0.5) * 2 * xpitch, -0.5 * (_P.pwidth + _P.separation)))
    end
    gate:add_anchor("left", point.create(-(_P.fingers + _P.dummies) * xpitch / 2, 0))
    gate:add_anchor("right", point.create((_P.fingers + _P.dummies) * xpitch / 2, 0))
end
