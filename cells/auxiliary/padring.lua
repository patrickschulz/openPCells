function parameters()
    pcell.add_parameters(
        { "padpitch", 100000 },
        { "padsperside", 16 },
        { "sidedistance", 200000 }
    )
end

function layout(padring, _P)
    padring:merge_into_shallow(pcell.create_layout("auxiliary/pads", { padpitch = _P.padpitch, numpads = _P.padsperside, orientation = "vertical" }):translate( (_P.padsperside - 1) * _P.padpitch / 2 + _P.sidedistance, 0))
    padring:merge_into_shallow(pcell.create_layout("auxiliary/pads", { padpitch = _P.padpitch, numpads = _P.padsperside, orientation = "vertical" }):translate(-(_P.padsperside - 1) * _P.padpitch / 2 - _P.sidedistance, 0))
    padring:merge_into_shallow(pcell.create_layout("auxiliary/pads", { padpitch = _P.padpitch, numpads = _P.padsperside, orientation = "horizontal" }):translate(0,  (_P.padsperside - 1) * _P.padpitch / 2 + _P.sidedistance))
    padring:merge_into_shallow(pcell.create_layout("auxiliary/pads", { padpitch = _P.padpitch, numpads = _P.padsperside, orientation = "horizontal" }):translate(0, -(_P.padsperside - 1) * _P.padpitch / 2 - _P.sidedistance))
end
