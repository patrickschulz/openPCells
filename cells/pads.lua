function parameters()
    pcell.add_parameters(
        { "numpads",    3 },
        { "padwidth",  60.0 },
        { "padheight", 80.0 },
        { "padpitch", 100.0 }
    )
end

function layout()
    local pads = object.create()

    pads:merge_into(layout.multiple(
        layout.rectangle(generics.metal(-1), _P.padwidth, _P.padheight),
        _P.numpads, 1, _P.padpitch, 0
    ))

    return pads
end
