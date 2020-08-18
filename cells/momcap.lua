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
    local P = pcell.get_params()

    local pitch = P.fwidth + P.fspace

    local momcap = object.create()

    for i = P.firstmetal, P.lastmetal do
        momcap:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(i), P.fwidth, P.fheight),
            P.fingers + 1, 1, 2 * pitch, 0
        ):translate(0, P.foffset))
        momcap:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(i), P.fwidth, P.fheight),
            P.fingers, 1, 2 * pitch, 0
        ):translate(0, -P.foffset))
        -- rails
        momcap:merge_into(geometry.multiple(
            geometry.rectangle(generics.metal(i), 
                (2 * P.fingers + 1) * (P.fwidth + P.fspace), P.rwidth
            ),
            1, 2, 0, 2 * P.foffset + P.fheight + P.rwidth
        ))
    end
    momcap:merge_into(geometry.multiple(
        geometry.rectangle(generics.via(P.firstmetal, P.lastmetal), 
            (2 * P.fingers + 1) * (P.fwidth + P.fspace), P.rwidth
        ),
        1, 2, 0, 2 * P.foffset + P.fheight + P.rwidth
    ))

    return momcap
end
