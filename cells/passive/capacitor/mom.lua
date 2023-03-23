function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)", 4 },
        { "fwidth(Finger Width)",     100 },
        { "fspace(Finger Spacing)",   100 },
        { "fheight(Finger Height)",  1000 },
        { "foffset(Finger Offset)",   100 },
        { "rwidth(Rail Width)",       100 },
        { "rext(Rail Extension)",       0 },
        { "firstmetal(Start Metal)",    1 },
        { "lastmetal(End Metal)",       2 },
        { "alternatingpolarity",     true },
        { "flippolarity",           false },
        --{ "flat",                    true },
        { "drawvia",                 true },
        { "drawfill",               false },
        { "fillmetals",                {} },
        { "fillwidth",                100 },
        { "fillheight",               100 },
        { "fillxspace",               100 },
        { "fillyspace",               100 },
        { "fillxextend",                0 },
        { "fillyextend",                0 }
    )
end

function layout(momcap, _P)
    local pitch = _P.fwidth + _P.fspace

    local firstmetal = technology.resolve_metal(_P.firstmetal)
    local lastmetal = technology.resolve_metal(_P.lastmetal)
    for m = firstmetal, lastmetal do
        -- rails
        geometry.rectanglebltr(
            momcap, generics.metal(m),
            point.create(-_P.rext, 0),
            point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.rwidth)
        )
        geometry.rectanglebltr(
            momcap, generics.metal(m),
            point.create(-_P.rext, _P.fheight + 2 * _P.foffset + _P.rwidth),
            point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + 2 * _P.foffset + 2 * _P.rwidth)
        )
        -- fingers
        for f = 1, _P.fingers do
            local xshift = (f - 1) * pitch
            local polarity = 0
            if _P.alternatingpolarity then
                polarity = (m - firstmetal) % 2
            end
            local yshift = (f % 2 == polarity) and 0 or _P.foffset
            geometry.rectanglebltr(
                momcap, generics.metal(m),
                point.create(xshift, _P.rwidth + yshift),
                point.create(xshift + _P.fwidth, _P.rwidth + yshift + _P.fheight + _P.foffset)
            )
        end
    end
    if _P.drawvia then
        if firstmetal ~= lastmetal then
            -- FIXME: support continuous vias
            geometry.viabltr(
                momcap, firstmetal, lastmetal,
                point.create(-_P.rext, 0),
                point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.rwidth)
            )
            geometry.viabltr(
                momcap, firstmetal, lastmetal,
                point.create(-_P.rext, _P.fheight + 2 * _P.foffset + _P.rwidth),
                point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + 2 * _P.foffset + 2 * _P.rwidth)
            )
        end
    end

    if _P.drawfill then
        local xpitch = _P.fillwidth + _P.fillxspace
        local ypitch = _P.fillheight + _P.fillyspace
        local totalwidth = 2 * _P.rext + _P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + 2 * _P.fillxextend
        local totalheight = 2 * _P.rwidth + _P.fheight + 2 * _P.foffset + 2 * _P.fillyextend
        local xrep = (totalwidth + _P.fillxspace) // xpitch
        local yrep = (totalheight + _P.fillyspace) // ypitch
        local xshift = (totalwidth - xrep * _P.fillwidth - (xrep - 1) * _P.fillxspace) / 2
        local yshift = (totalheight - yrep * _P.fillheight - (yrep - 1) * _P.fillyspace) / 2
        for _, m in ipairs(_P.fillmetals) do
            geometry.rectanglearray(
                momcap, generics.metal(m),
                _P.fillwidth, _P.fillheight,
                xshift - _P.rext - _P.fillxextend, yshift - _P.fillyextend,
                xrep, yrep,
                _P.fillwidth + _P.fillxspace,
                _P.fillheight + _P.fillyspace
            )
        end
    end

    momcap:add_area_anchor_bltr("upperrail",
        point.create(-_P.rext, _P.fheight + 2 * _P.foffset + _P.rwidth),
        point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + 2 * _P.foffset + 2 * _P.rwidth)
    )
    momcap:add_area_anchor_bltr("lowerrail",
        point.create(-_P.rext, 0),
        point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.rwidth)
    )
    momcap:set_alignment_box(
        point.create(-_P.rext, 0),
        point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + _P.foffset + _P.rwidth),
        point.create(-_P.rext, _P.rwidth),
        point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + _P.foffset)
    )
end
