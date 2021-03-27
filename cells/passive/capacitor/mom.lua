function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)", 4 },
        { "fwidth(Finger Width)",     100 },
        { "fspace(Finger Spacing)",   100 },
        { "fheight(Finger Height)",  1000 },
        { "foffset(Finger Offset)",   100 },
        { "rwidth(Rail Width)",       100 },
        { "firstmetal(Start Metal)",    1 },
        { "lastmetal(End Metal)",       2 }
    )
end

function layout(momcap, _P)
    local pitch = _P.fwidth + _P.fspace

    for i = _P.firstmetal, _P.lastmetal do
        momcap:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.metal(i), _P.fwidth, _P.fheight),
            _P.fingers + 1, 2 * pitch
        ):translate(0, _P.foffset))
        momcap:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.metal(i), _P.fwidth, _P.fheight),
            _P.fingers, 2 * pitch
        ):translate(0, -_P.foffset))
        -- rails
        momcap:merge_into(geometry.multiple_y(
            geometry.rectangle(generics.metal(i),
                (2 * _P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth
            ),
            2, 2 * _P.foffset + _P.fheight + _P.rwidth
        ))
    end
    momcap:merge_into(geometry.multiple_y(
        geometry.rectangle(generics.via(_P.firstmetal, _P.lastmetal),
            (2 * _P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth
        ),
        2, 2 * _P.foffset + _P.fheight + _P.rwidth
    ))
end
