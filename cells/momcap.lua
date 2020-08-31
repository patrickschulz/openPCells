function parameters()
    pcell.add_parameters(
        { "fingers",    4   },
        { "fwidth",     0.1 },
        { "fspace",     0.1 },
        { "fheight",    1   },
        { "foffset",    0.1 },
        { "rwidth",     0.1 },
        { "firstmetal", 1   },
        { "lastmetal",  2   }
    )
end

function layout()
    local pitch = _P.fwidth + _P.fspace

    local momcap = object.create()

    for i = _P.firstmetal, _P.lastmetal do
        momcap:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(i), _P.fwidth, _P.fheight),
            _P.fingers + 1, 1, 2 * pitch, 0
        ):translate(0, _P.foffset))
        momcap:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(i), _P.fwidth, _P.fheight),
            _P.fingers, 1, 2 * pitch, 0
        ):translate(0, -_P.foffset))
        -- rails
        momcap:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(i), 
                (2 * _P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth
            ),
            1, 2, 0, 2 * _P.foffset + _P.fheight + _P.rwidth
        ))
    end
    momcap:merge_into(geometry.multiple(
        geometry.rectangle(generics.via(_P.firstmetal, _P.lastmetal), 
            (2 * _P.fingers + 1) * (_P.fwidth + _P.fspace), _P.rwidth
        ),
        1, 2, 0, 2 * _P.foffset + _P.fheight + _P.rwidth
    ))

    return momcap
end
