function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)", 4 },
        { "fwidth(Finger Width)",     100 },
        { "fspace(Finger Spacing)",   100 },
        { "fheight(Finger Height)",  1000 },
        { "foffset(Finger Offset)",   100 },
        { "rwidth(Rail Width)",       100 },
        { "firstmetal(Start Metal)",    1 },
        { "lastmetal(End Metal)",       2 },
        { "flat",                   false }
    )
end

function layout(momcap, _P)
    local pitch = _P.fwidth + _P.fspace

    if _P.flat then
        for i = _P.firstmetal, _P.lastmetal do
            local finger = geometry.rectangle(generics.metal(i), _P.fwidth, _P.fheight)
            local xreptop, xrepbottom = evenodddiv2(_P.fingers)
            local xshift = (_P.fingers % 2 == 0) and pitch / 2 or 0
            momcap:merge_into_shallow(geometry.multiple_x(
                finger,
                xreptop, 2 * pitch
            ):translate(-xshift, _P.foffset / 2))
            momcap:merge_into_shallow(geometry.multiple_x(
                finger,
                xrepbottom, 2 * pitch
            ):translate(xshift, -_P.foffset / 2))
        end
        -- rails
        for i = _P.firstmetal, _P.lastmetal do
            momcap:merge_into_shallow(geometry.multiple_y(
                geometry.rectangle(generics.metal(i),
                    (_P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth
                ),
                2, _P.foffset + _P.fheight + _P.rwidth
            ))
        end
        -- vias
        if _P.firstmetal ~= _P.lastmetal then
            momcap:merge_into_shallow(geometry.multiple_y(
                geometry.via(_P.firstmetal, _P.lastmetal,
                    (_P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth,
                    { xcontinuous = true }
                ),
                2, _P.foffset + _P.fheight + _P.rwidth
            ))
        end
    else
        local fingerref = object.create()
        for i = _P.firstmetal, _P.lastmetal do
            fingerref:merge_into_shallow(geometry.rectangle(generics.metal(i), _P.fwidth, _P.fheight))
        end
        if _P.firstmetal ~= _P.lastmetal then
            local viaref = object.create()
            fingerref:merge_into_shallow(geometry.multiple_y(
                geometry.via(_P.firstmetal, _P.lastmetal,
                    (_P.fwidth + _P.fspace), _P.rwidth,
                    { xcontinuous = true }
                ),
                2, _P.foffset + _P.fheight + _P.rwidth
            ):translate(0, _P.foffset / 2))
        end
        local fingername = pcell.add_cell_reference(fingerref, "momcapfinger")
        momcap:add_child_array(fingername, _P.fingers + 1, 1, 2 * pitch, 0):flipy():translate(-_P.fingers * pitch, -_P.foffset / 2)
        momcap:add_child_array(fingername, _P.fingers, 1, 2 * pitch, 0):translate(-_P.fingers * pitch + pitch, -_P.foffset / 2)
    end

    momcap:add_anchor("plus", point.create(0,   _P.foffset / 2 + _P.fheight / 2 + _P.rwidth / 2))
    momcap:add_anchor("minus", point.create(0, -_P.foffset / 2 - _P.fheight / 2 - _P.rwidth / 2))
    momcap:set_alignment_box(
        point.create(-_P.fingers * (_P.fwidth + _P.fspace), -_P.foffset / 2 - _P.fheight / 2 - _P.rwidth / 2),
        point.create( _P.fingers * (_P.fwidth + _P.fspace),  _P.foffset / 2 + _P.fheight / 2 + _P.rwidth / 2)
    )
end
