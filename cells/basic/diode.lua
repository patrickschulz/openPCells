function parameters()
    pcell.add_parameters(
        { "diodetype", "pn", posvals = set("pn", "np") },
        { "width", 1000 },
        { "height", 1000 },
        { "extension", 100 }
    )
end

function layout(diode, _P)
    geometry.rectangle(diode, generics.other("active"), _P.width, _P.height)
    geometry.rectangle(diode, generics.contact("active"), _P.width, _P.height)
    geometry.rectangle(diode, generics.other("soiopen"), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension)
    --geometry.rectangle(diode, generics.diode(_P.diodetype), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension)
end
