function parameters()
    pcell.add_parameters(
        { "numpads(Number of Pads)",                 3 },
        { "padwidth(Width of Pad)",              60000 },
        { "padheight(Height of Pad)",            80000 },
        { "padpitch(Pitch between Pads)",       100000 },
        { "orientation(Pad Orientation)", "horizontal" }
    )
end

function layout(pads, _P)
    if _P.orientation == "horizontal" then
        pads:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.metal(-1), _P.padwidth, _P.padheight),
            _P.numpads, _P.padpitch
        ))
    else -- vertical
        pads:merge_into(geometry.multiple_y(
            geometry.rectangle(generics.metal(-1), _P.padheight, _P.padwidth),
            _P.numpads, _P.padpitch
        ))
    end
end
