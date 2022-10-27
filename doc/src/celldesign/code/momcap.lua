function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)", 5 },
        { "fwidth(Finger Width)",     100 },
        { "fspace(Finger Spacing)",   100 },
        { "fheight(Finger Height)",  1000 },
        { "foffset(Finger Offset)",   100 },
        { "rwidth(Rail Width)",       200 },
        { "firstmetal(Start Metal)",    1 },
        { "lastmetal(End Metal)",       2 }
    )
end

function layout(momcap, _P)
    local pitch = _P.fwidth + _P.fspace

    -- fingers
    for i = _P.firstmetal, _P.lastmetal do
        geometry.rectangle(
            momcap, generics.metal(i),
            _P.fwidth, _P.fheight, -- width and height
            0, -_P.foffset / 2, -- xshift and yshift
            _P.fingers // 2, 1, 2 * (_P.fwidth + _P.fspace), 0 -- repetition
        )
        geometry.rectangle(
            momcap, generics.metal(i),
            _P.fwidth, _P.fheight, -- width and height
            0, _P.foffset / 2, -- xshift and yshift
            _P.fingers // 2 + 1, 1, 2 * (_P.fwidth + _P.fspace), 0 -- repetition
        )
    end
    -- rails
    for i = _P.firstmetal, _P.lastmetal do
        geometry.rectangle(
            momcap, generics.metal(i),
            (_P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth,
            0, 0,
            1, 2, 0, _P.foffset + _P.fheight + _P.rwidth
        )
    end
    -- vias
    for i = _P.firstmetal, _P.lastmetal do
        geometry.via(
            momcap, _P.firstmetal, _P.lastmetal,
            (_P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth,
            0, 0,
            1, 2, 0, _P.foffset + _P.fheight + _P.rwidth
        )
    end
    --if _P.firstmetal ~= _P.lastmetal then
    --    geometry.viabltr(
    --        momcap, _P.firstmetal, _P.lastmetal,
    --        point.create(-(_P.fingers + 1) * (_P.fwidth + _P.fspace) / 2, -_P.rwidth / 2),
    --        point.create( (_P.fingers + 1) * (_P.fwidth + _P.fspace) / 2,  _P.rwidth / 2),
    --        1, 2, 0, _P.foffset + _P.fheight + _P.rwidth
    --    ) -- FIXME: make via continuous
    --end

    --[[
    momcap:add_anchor("plus", point.create(0,   _P.foffset / 2 + _P.fheight / 2 + _P.rwidth / 2))
    momcap:add_anchor("minus", point.create(0, -_P.foffset / 2 - _P.fheight / 2 - _P.rwidth / 2))
    momcap:set_alignment_box(
        point.create(-_P.fingers * (_P.fwidth + _P.fspace), -_P.foffset / 2 - _P.fheight / 2 - _P.rwidth / 2),
        point.create( _P.fingers * (_P.fwidth + _P.fspace),  _P.foffset / 2 + _P.fheight / 2 + _P.rwidth / 2)
    )
    --]]
end
