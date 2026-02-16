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
        { "lastmetal(End Metal)",       2 }
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
            local yshift = (f % 2 == 0) and 0 or _P.foffset
            geometry.rectanglebltr(
                momcap, generics.metal(m),
                point.create(xshift, _P.rwidth + yshift),
                point.create(xshift + _P.fwidth, _P.rwidth + yshift + _P.fheight + _P.foffset)
            )
        end
    end
    if firstmetal ~= lastmetal then
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
