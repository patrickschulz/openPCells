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
    pcell.inherit_all_parameters("logic/_base")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    gate:merge_into(pcell.create_layout("logic/harness", { 
        glength = _P.glength, 
        fingers = 2 * _P.fingers, 
        leftdummies = _P.leftdummies, 
        rightdummies = _P.rightdummies, 
        dummycontheight = _P.dummycontheight,
        leftadapt = _P.fingers % 2 ~= 0,
    }))

    local block = object.create()

    -- common transistor options
    pcell.overwrite_defaults("transistor", { 
        fingers = 2,
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
        drawinnersourcedrain = false,
        drawoutersourcedrain = false,
    })

    -- pmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "pmos",
        fwidth = _P.pwidth,
        gtopext = _P.powerspace + _P.dummycontheight,
        gbotext = _P.separation / 2,
        clipbot = true,
    })
    block:merge_into(pcell.create_layout("transistor"):move_anchor("botgate"))
    pcell.restore_defaults("transistor")

    -- nmos
    pcell.overwrite_defaults("transistor", { 
        channeltype = "nmos",
        fwidth = _P.nwidth,
        gbotext = _P.powerspace + _P.dummycontheight, gtopext = _P.separation / 2,
        gtopext = _P.separation / 2,
        cliptop = true,
    })
    block:merge_into(pcell.create_layout("transistor"):move_anchor("topgate"))
    pcell.restore_defaults("transistor")

    -- gate contacts
    block:merge_into(geometry.rectangle(
        generics.contact("gate"), _P.glength, _P.gstwidth
    ):translate(xpitch / 2, _P.separation / 4))
    block:merge_into(geometry.rectangle(
        generics.contact("gate"), _P.glength, _P.gstwidth
    ):translate(-xpitch / 2, -_P.separation / 4))
    local num = 2 * _P.fingers - 1 - math.abs(_P.fingers % 2 - 1)
    local num2 = 2 * _P.fingers - 1 + math.abs(_P.fingers % 2 - 1)
    gate:merge_into(geometry.rectangle(
        generics.metal(1), num * _P.glength + (num - 1) * _P.gspace, _P.gstwidth
    ):translate(-(_P.fingers % 2) * xpitch / 2, -_P.separation / 4))
    gate:merge_into(geometry.rectangle(
        generics.metal(1), num2 * _P.glength + (num2 - 1) * _P.gspace, _P.gstwidth
    ):translate((_P.fingers % 2) * xpitch / 2, _P.separation / 4))

    -- pmos source/drain contacts
    block:merge_into(geometry.rectangle(
        generics.contact("active"), _P.sdwidth, _P.pwidth / 2
    ):translate(0, (_P.separation + _P.pwidth / 2) / 2))
    block:merge_into(geometry.multiple(
        geometry.rectangle(generics.contact("active"), _P.sdwidth, _P.pwidth / 2),
        2, 1, 2 * xpitch, 0
    ):translate(0, _P.separation / 2 + _P.pwidth * 3 / 4))
    block:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(1), _P.sdwidth, _P.powerspace),
        2, 1, 2 * xpitch, 0
    ):translate(0, _P.separation / 2 + _P.pwidth + _P.powerspace / 2))
    -- nmos source/drain contacts
    block:merge_into(geometry.rectangle(
        generics.contact("active"), _P.sdwidth, _P.pwidth / 2
    ):translate(-xpitch, -(_P.separation + _P.nwidth / 2) / 2))
    block:merge_into(geometry.rectangle(
        generics.contact("active"), _P.sdwidth, _P.pwidth / 2
    ):translate(xpitch, -_P.separation / 2 - _P.nwidth * 3 / 4))
    block:merge_into(geometry.rectangle(
        generics.metal(1), _P.sdwidth, _P.powerspace
    ):translate(xpitch, -_P.separation / 2 - _P.nwidth - _P.powerspace / 2))

    for i = 1, _P.fingers do
        local shift = 2 * (i - 1) - (_P.fingers - 1)
        if i % 2 == 0 then
            gate:merge_into(block:copy():flipx():translate(-shift * xpitch, 0))
        else
            gate:merge_into(block:copy():translate(-shift * xpitch, 0))
        end
    end

    -- drain connection
    local poffset = _P.fingers % 2 == 0 and (_P.fingers - 2) or _P.fingers
    gate:merge_into(geometry.path(
        generics.metal(1),
        {
            point.create(-_P.fingers * xpitch + xpitch, (_P.separation + _P.sdwidth) / 2),
            point.create(_P.fingers * xpitch,  (_P.separation + _P.sdwidth) / 2),
            point.create(_P.fingers * xpitch, -(_P.separation + _P.sdwidth) / 2),
            point.create(-poffset * xpitch, -(_P.separation + _P.sdwidth) / 2),
        },
        _P.sdwidth, 
        true
    ))

    -- anchors
    gate:add_anchor("left", point.create(-(2 * _P.fingers + _P.leftdummies) * xpitch / 2, 0))
    gate:add_anchor("right", point.create((2 * _P.fingers + _P.rightdummies) * xpitch / 2, 0))
end
