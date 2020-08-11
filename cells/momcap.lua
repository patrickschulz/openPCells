return function(args)
    pcell.setup(args)
    local fingers    = pcell.process_args("fingers",    4)
    local fwidth     = pcell.process_args("fwidth",     0.1)
    local fspace     = pcell.process_args("fspace",     0.1)
    local fheight    = pcell.process_args("fheight",    1)
    local foffset    = pcell.process_args("foffset",    0.1)
    local rwidth     = pcell.process_args("rwidth",     0.1)
    local firstmetal = pcell.process_args("firstmetal", 1)
    local lastmetal  = pcell.process_args("lastmetal",  2)
    pcell.check_args()

    local pitch = fwidth + fspace

    local momcap = object.create()

    for i = firstmetal, lastmetal do
        momcap:merge_into(layout.multiple(
            layout.rectangle(generics.metal(i), fwidth, fheight),
            fingers + 1, 1, 2 * pitch, 0
        ):translate(0, foffset))
        momcap:merge_into(layout.multiple(
            layout.rectangle(generics.metal(i), fwidth, fheight),
            fingers, 1, 2 * pitch, 0
        ):translate(0, -foffset))
        -- rails
        momcap:merge_into(layout.multiple(
            layout.rectangle(generics.metal(i), 
                (2 * fingers + 1) * (fwidth + fspace), rwidth
            ),
            1, 2, 0, 2 * foffset + fheight + rwidth
        ))
    end
    momcap:merge_into(layout.multiple(
        layout.rectangle(generics.via(firstmetal, lastmetal), 
            (2 * fingers + 1) * (fwidth + fspace), rwidth
        ),
        1, 2, 0, 2 * foffset + fheight + rwidth
    ))

    return momcap
end
