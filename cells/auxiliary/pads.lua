function parameters()
    pcell.add_parameters(
        { "numpads",       3 },
        { "padwidth",  60000 },
        { "padheight", 80000 },
        { "padpitch", 100000 }
    )
end

function layout(pads, _P)
    pads:merge_into(geometry.multiple(
        geometry.rectangle(generics.metal(-1), _P.padwidth, _P.padheight),
        _P.numpads, 1, _P.padpitch, 0
    ))
end
