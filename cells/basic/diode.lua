function parameters()
    pcell.add_parameters(
        { "diodetype", "pn", posvals = set("pn", "np") },
        { "width", 1000 },
        { "height", 1000 },
        { "extension", 100 }
    )
end

function layout(diode, _P)
    diode:merge_into_shallow(geometry.rectangle(generics.other("active"), _P.width, _P.height))
    diode:merge_into_shallow(geometry.rectangle(generics.contact("active"), _P.width, _P.height))
    diode:merge_into_shallow(geometry.rectangle(generics.other("soiopen"), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension))
    --diode:merge_into_shallow(geometry.rectangle(generics.diode(_P.diodetype), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension))
end
