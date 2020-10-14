--[[
-------------*-----------------*------
             |                 |
             |                 |
           --                --
    A ]--o|           B ]--o| 
           <-                <-
             |                 |
             |                 |
             *--------*--------*-----[ Z
                      |
                      |
                    --
             B ]---| 
                    ->
                      |
                      |
                      |
                    --
             A ]---| 
                    ->
                      |
----------------------*---------------
--]]

function parameters()
    pcell.add_parameters(
        { "oxidetype",  "0.9" },
        { "pvthtype",   "slvt" },
        { "nvthtype",   "slvt" },
        { "pwidth",    1000 },
        { "nwidth",    1000 },
        { "glength",    200 },
        { "gspace",     270 },
        { "gext",       100 },
        { "sdwidth",     60 },
        { "gstwidth",   100 },
        { "fingers",      1 },
        { "dummies",      2 },
        { "separation", 400 },
        { "ttypeext",   100 },
        { "powerwidth", 200 },
        { "powerspace", 500 },
        { "conngate",     1 },
        { "connmetal",    3 },
        { "connwidth",  100 },
        { "connoffset",   1 }
    )
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    -- common transistor options
    pcell.overwrite_defaults("transistor", { 
        fingers = _P.fingers,
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
        topgatestrwidth = _P.gstwidth,
        botgatestrwidth = _P.gstwidth,
        topgatestrspace = (_P.separation - _P.gstwidth) / 2,
        botgatestrspace = (_P.separation - _P.gstwidth) / 2,
    })

    -- pmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "pmos",
        fwidth = _P.pwidth,
        drawbotgate = true,
        clipbot = true
    })
    gate:merge_into(pcell.create_layout("transistor"):move_anchor("rightbotgate"))
    gate:merge_into(pcell.create_layout("transistor"):move_anchor("leftbotgate"))
    pcell.restore_defaults("transistor")

    -- nmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "nmos",
        fwidth = _P.nwidth,
        drawtopgate = true,
        cliptop = true
    })
    gate:merge_into(pcell.create_layout("transistor"):move_anchor("righttopgate"))
    gate:merge_into(pcell.create_layout("transistor"):move_anchor("lefttopgate"))
    pcell.restore_defaults("transistor")

    -- power rails...
    gate:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), (2 * _P.fingers + 2 * _P.dummies) * xpitch + _P.sdwidth, _P.powerwidth),
        1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
    ):translate(0, (_P.pwidth - _P.nwidth) / 2))
    -- ... with connections
    for i = -1, 1, 2 do
        gate:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
            _P.dummies + 1, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        ):translate(i * (2 * _P.fingers + _P.dummies) / 2 * xpitch, (_P.pwidth - _P.nwidth) / 2))
    end
end
