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
    geometry.ring(guardring, generics.other("active"), _P.width, _P.height, _P.ringwidth)
    geometry.ring(guardring, generics.implant(_P.contype), _P.width, _P.height, _P.ringwidth + 2 * _P.extension)
    geometry.ring(guardring, generics.other("soiopen"), _P.width, _P.height, _P.ringwidth + 2 * _P.extension)

    -- M1 and contacts
    geometry.ring(guardring, generics.metal(1), _P.width, _P.height, _P.ringwidth)
    geometry.contactbltr(guardring, "active", 
        point.create(-(_P.width - _P.ringwidth) / 2, _P.height / 2 - _P.ringwidth / 2),
        point.create( (_P.width - _P.ringwidth) / 2, _P.height / 2 + _P.ringwidth / 2)
    )
    geometry.contactbltr(guardring, "active", 
        point.create(-(_P.width - _P.ringwidth) / 2, -_P.height / 2 - _P.ringwidth / 2),
        point.create( (_P.width - _P.ringwidth) / 2, -_P.height / 2 + _P.ringwidth / 2)
    )
    geometry.contactbltr(guardring, "active", 
        point.create(-_P.width - _P.ringwidth / 2, -_P.height - _P.ringwidth / 2),
        point.create(-_P.width + _P.ringwidth / 2,  _P.height - _P.ringwidth / 2)
    )
    geometry.contactbltr(guardring, "active", 
        point.create( _P.width - _P.ringwidth / 2, -_P.height - _P.ringwidth / 2),
        point.create( _P.width + _P.ringwidth / 2,  _P.height - _P.ringwidth / 2)
    )

    -- well
    if _P.fillwell then
        geometry.rectangle(guardring, generics.other(string.format("%swell", _P.contype)), _P.width + _P.ringwidth + 2 * _P.extension, _P.height + _P.ringwidth + 2 * _P.extension)
    else
        geometry.ring(guardring, generics.other(string.format("%swell", _P.contype)), _P.width, _P.height, _P.ringwidth + 2 * _P.extension)
    end
    -- draw deep n/p-well
    if _P.drawdeepwell then
        geometry.rectangle(guardring, generics.other(string.format("deep%swell", _P.contype)), _P.width + _P.ringwidth + 2 * _P.extension - 2 * _P.deepwelloffset, _P.height + _P.ringwidth + 2 * _P.extension - 2 * _P.deepwelloffset)
    end

    -- alignment box
    guardring:set_alignment_box(
        point.create(-_P.width / 2, -_P.height / 2),
        point.create( _P.width / 2,  _P.height / 2)
    )
end
