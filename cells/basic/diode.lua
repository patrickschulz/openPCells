function parameters()
    pcell.add_parameters(
        { "diodetype", "pn", posvals = set("pn", "np") },
        { "width", 1000 },
        { "height", 1000 },
        { "extension", 100 }
    )
end

function layout(diode, _P)
    geometry.rectanglebltr(diode, generics.active(),
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    geometry.rectanglebltr(diode, generics.contact("active"),
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    geometry.rectanglebltr(diode, generics.feol("soiopen"),
        point.create(-_P.extension, -_P.extension),
        point.create(_P.width + _P.extension, _P.height + _P.extension))
    --geometry.rectangle(diode, generics.diode(_P.diodetype), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension)
end
