function parameters()
    pcell.add_parameters(
        { "contype",        "p" },
        { "width",         5000 },
        { "height",        5000 },
        { "ringwidth",      200 },
        { "extension",       50 },
        { "fillwell",      true },
        { "drawdeepwell", false },
        { "deepwelloffset",   0 }
    )
end

function layout(guardring, _P)
    -- active, implant and SOI opening
    guardring:merge_into_shallow(geometry.ring(generics.other("active"), _P.width, _P.height, _P.ringwidth))
    guardring:merge_into_shallow(geometry.ring(generics.other(string.format("%simpl", _P.contype)), _P.width, _P.height, _P.ringwidth + 2 * _P.extension))
    guardring:merge_into_shallow(geometry.ring(generics.other("soiopen"), _P.width, _P.height, _P.ringwidth + 2 * _P.extension))

    -- M1 and contacts
    guardring:merge_into_shallow(geometry.ring(generics.metal(1), _P.width, _P.height, _P.ringwidth))
    guardring:merge_into_shallow(geometry.rectangle(generics.contact("active"), _P.width - _P.ringwidth, _P.ringwidth):translate(0,  _P.height / 2))
    guardring:merge_into_shallow(geometry.rectangle(generics.contact("active"), _P.width - _P.ringwidth, _P.ringwidth):translate(0, -_P.height / 2))
    guardring:merge_into_shallow(geometry.rectangle(generics.contact("active"), _P.ringwidth, _P.height - _P.ringwidth):translate(-_P.width / 2, 0))
    guardring:merge_into_shallow(geometry.rectangle(generics.contact("active"), _P.ringwidth, _P.height - _P.ringwidth):translate( _P.width / 2, 0))

    -- well
    if _P.fillwell then
        guardring:merge_into_shallow(geometry.rectangle(generics.other(string.format("%swell", _P.contype)), _P.width + _P.ringwidth + 2 * _P.extension, _P.height + _P.ringwidth + 2 * _P.extension))
    else
        guardring:merge_into_shallow(geometry.ring(generics.other(string.format("%swell", _P.contype)), _P.width, _P.height, _P.ringwidth + 2 * _P.extension))
    end
    -- draw deep n/p-well
    if _P.drawdeepwell then
        guardring:merge_into_shallow(geometry.rectangle(generics.other(string.format("deep%swell", _P.contype)), _P.width + _P.ringwidth + 2 * _P.extension - 2 * _P.deepwelloffset, _P.height + _P.ringwidth + 2 * _P.extension - 2 * _P.deepwelloffset))
    end

    -- alignment box
    guardring:set_alignment_box(
        point.create(-_P.width / 2, -_P.height / 2),
        point.create( _P.width / 2,  _P.height / 2)
    )
end
