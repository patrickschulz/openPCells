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
        { "drawvia",                 true }
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
            point.create(-_P.rext, _P.fheight + _P.foffset),
            point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + _P.foffset + _P.rwidth)
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
                point.create(xshift + _P.fwidth, _P.fheight + yshift)
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
                point.create(-_P.rext, _P.fheight + _P.foffset),
                point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + _P.foffset + _P.rwidth)
            )
        end
    end

    momcap:add_area_anchor_bltr("upperrail",
        point.create(-_P.rext, _P.fheight + _P.foffset),
        point.create(_P.fingers * _P.fwidth + (_P.fingers - 1) * _P.fspace + _P.rext, _P.fheight + _P.foffset + _P.rwidth)
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
