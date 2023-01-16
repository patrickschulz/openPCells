function parameters()
    pcell.add_parameters(
        { "contype",          "p" },
        { "width",           5000 },
        { "height",          5000 },
        { "extension",         50 },
        { "xcontinuous",    false },
        { "ycontinuous",    false }
    )
end

function layout(welltap, _P)
    -- active, implant and SOI opening
    geometry.rectanglebltr(welltap, generics.other("active"), 
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    geometry.rectanglebltr(welltap, generics.other(string.format("%simplant", _P.contype)),
        point.create(-_P.extension, -_P.extension),
        point.create(_P.width + _P.extension, _P.height + _P.extension)
    )
    geometry.rectanglebltr(welltap, generics.other("soiopen"),
        point.create(-_P.extension, -_P.extension),
        point.create(_P.width + _P.extension, _P.height + _P.extension)
    )

    -- M1 and contacts
    geometry.rectanglebltr(welltap, generics.metal(1), 
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    geometry.contactbltr(welltap, "active",
        point.create(0, 0),
        point.create(_P.width, _P.height),
        1, 1, 0, 0,
        { xcontinuous = _P.xcontinuous, ycontinuous = _P.ycontinuous }
    )

    -- well
    geometry.rectanglebltr(welltap, generics.other(string.format("%swell", _P.contype)),
        point.create(-_P.extension, -_P.extension),
        point.create(_P.width + _P.extension, _P.height + _P.extension)
    )

    -- alignment box
    welltap:set_alignment_box(
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
end
