--[[

----------------------*---------------
                      |
                      |
                    --
             A ]--o| 
                    <-
                      |
                      |
                      |
                    --
             B ]--o| 
                    <-
                      |
             *--------*--------*-----[ Z
             |                 |
             |                 |
           --                --
    A ]---|           B ]---| 
           ->                ->
             |                 |
             |                 |
-------------*-----------------*------



--]]
function parameters()
    pcell.add_parameters(
        { "oxidetype",  "0.9" },
        { "pvthtype",   "slvt" },
        { "nvthtype",   "slvt" },
        { "pwidth",     500 },
        { "nwidth",     500 },
        { "glength",    100 },
        { "gspace",     150 },
        { "gext",       100 },
        { "sdwidth",     60 },
        { "gstwidth",   100 },
        { "fingers",      1 },
        { "dummies",      1 },
        { "dummycontheight",      80 },
        { "separation", 400 },
        { "ttypeext",   100 },
        { "powerwidth", 200 },
        { "powerspace", 100 },
        { "conngate",     1 },
        { "connmetal",    3 },
        { "connwidth",  100 },
        { "connoffset",   1 }
    )
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    gate:merge_into(pcell.create_layout("logic/harness", { innerfingers = 2 * _P.fingers, dummies = _P.dummies, dummycontheight = _P.dummycontheight }))

    -- common transistor options
    pcell.overwrite_defaults("transistor", { 
        fingers = 2 * _P.fingers,
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
        -- not really common for all transistor, but they only matter if the gate contact is drawn
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
        drawbotgatestrap = false,
        gtopext = _P.powerspace + _P.dummycontheight,
        clipbot = true,
        drawinnersourcedrain = false,
        outersourcedrainsize = _P.pwidth / 2,
        outersourcedrainalign = "top"
    })
    gate:merge_into(pcell.create_layout("transistor"):move_anchor("botgate"))
    pcell.restore_defaults("transistor")

    -- nmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "nmos",
        fwidth = _P.nwidth,
        drawtopgate = true,
        drawtopgatestrap = false,
        gbotext = _P.powerspace + _P.dummycontheight, gtopext = _P.separation / 2,
        cliptop = true,
        innersourcedrainsize = _P.nwidth / 2,
        innersourcedrainalign = "bottom",
        outersourcedrainsize = _P.nwidth / 2,
        outersourcedrainalign = "bottom"
    })
    gate:merge_into(pcell.create_layout("transistor"):move_anchor("topgate"))
    pcell.restore_defaults("transistor")

    -- drain connection
    gate:merge_into(geometry.path(
        generics.metal(1),
        {
            point.create(0, -_P.separation / 2 - _P.pwidth),
            point.create(0, -_P.separation / 2 - _P.sdwidth / 2),
            point.create(xpitch, -_P.separation / 2 - _P.sdwidth / 2),
            point.create(xpitch, _P.separation / 2 + _P.nwidth),
        },
        _P.sdwidth, 
        true
    ))
    gate:add_anchor("left", point.create(-(2 * _P.fingers + _P.dummies) * xpitch / 2, 0))
    gate:add_anchor("right", point.create((2 * _P.fingers + _P.dummies) * xpitch / 2, 0))
end
