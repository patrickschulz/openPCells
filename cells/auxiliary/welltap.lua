function parameters()
    pcell.add_parameters(
        { "contype",        "p" },
        { "width",         5000 },
        { "height",        5000 },
        { "extension",       50 }
    )
end

function layout(welltap, _P)
    -- active, implant and SOI opening
    welltap:merge_into_shallow(geometry.rectangle(generics.other("active"), _P.width, _P.height))
    welltap:merge_into_shallow(geometry.rectangle(generics.other(string.format("%simpl", _P.contype)), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension))
    welltap:merge_into_shallow(geometry.rectangle(generics.other("soiopen"), _P.width + 2 * _P.extension, _P.height + 2 * _P.extension))

    -- M1 and contacts
    welltap:merge_into_shallow(geometry.rectangle(generics.metal(1), _P.width, _P.height))
    welltap:merge_into_shallow(geometry.rectangle(generics.contact("active"), _P.width, _P.height))

    -- well
    --welltap:merge_into_shallow(geometry.ring(generics.other(string.format("%swell", _P.contype)), _P.width, _P.height, _P.tapwidth + 2 * _P.extension))

    -- alignment box
    welltap:set_alignment_box(
        point.create(-_P.width / 2, -_P.height / 2),
        point.create( _P.width / 2,  _P.height / 2)
    )
end
