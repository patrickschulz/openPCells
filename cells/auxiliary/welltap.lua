function parameters()
    pcell.add_parameters(
        { "contype",          "p" },
        { "width",           5000 },
        { "height",          5000 },
        { "extension",         50 },
        { "continuousvias", false }
    )
end

function layout(welltap, _P)
    -- active, implant and SOI opening
    geometry.rectangle(welltap, generics.other("active"), _P.width, _P.height)
    geometry.rectangle(welltap, generics.other(string.format("%simplant", _P.contype)), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension)
    geometry.rectangle(welltap, generics.other("soiopen"), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension)

    -- M1 and contacts
    geometry.rectangle(welltap, generics.metal(1), _P.width, _P.height)
    geometry.contact(welltap, "active", _P.width, _P.height)

    -- well
    geometry.rectangle(welltap, generics.other(string.format("%swell", _P.contype)), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension)

    -- alignment box
    welltap:set_alignment_box(
        point.create(-_P.width / 2, -_P.height / 2),
        point.create( _P.width / 2,  _P.height / 2)
    )
end
