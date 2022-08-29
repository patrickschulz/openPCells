function parameters()
    pcell.add_parameters(
        { "contype",            "p" },
        { "holewidth",         5000 },
        { "holeheight",        5000 },
        { "ringwidth",          200 },
        { "wellextension",       50 },
        { "soiopenextension",    50 },
        { "implantextension",    50 },
        { "fillwell",          true },
        { "drawdeepwell",     false },
        { "deepwelloffset",       0 }
    )
end

function layout(guardring, _P)
    -- active, implant and SOI opening
    geometry.ring(guardring, generics.other("active"), _P.holewidth, _P.holeheight, _P.ringwidth)
    geometry.ring(guardring, generics.implant(_P.contype), _P.holewidth - 2 * _P.implantextension, _P.holeheight - 2 * _P.implantextension, _P.ringwidth + 2 * _P.implantextension)
    geometry.ring(guardring, generics.other("soiopen"), _P.holewidth - 2 * _P.soiopenextension, _P.holeheight - 2 * _P.soiopenextension, _P.ringwidth + 2 * _P.soiopenextension)

    -- M1 and contacts
    geometry.ring(guardring, generics.metal(1), _P.holewidth, _P.holeheight, _P.ringwidth)
    geometry.contactbltr(guardring, "active", 
        point.create(-_P.holewidth / 2, _P.holeheight / 2),
        point.create( _P.holewidth / 2, _P.holeheight / 2 + _P.ringwidth)
    )
    geometry.contactbltr(guardring, "active", 
        point.create(-_P.holewidth / 2, -_P.holeheight / 2 - _P.ringwidth),
        point.create( _P.holewidth / 2, -_P.holeheight / 2)
    )
    geometry.contactbltr(guardring, "active", 
        point.create(-_P.holewidth / 2 - _P.ringwidth, -_P.holeheight / 2),
        point.create(-_P.holewidth / 2,  _P.holeheight / 2)
    )
    geometry.contactbltr(guardring, "active", 
        point.create( _P.holewidth / 2, -_P.holeheight / 2),
        point.create( _P.holewidth / 2 + _P.ringwidth,  _P.holeheight / 2)
    )

    -- well
    if _P.fillwell then
        geometry.rectangle(guardring, generics.other(string.format("%swell", _P.contype)), _P.holewidth + _P.ringwidth + 2 * _P.wellextension, _P.holeheight + _P.ringwidth + 2 * _P.wellextension)
    else
        geometry.ring(guardring, generics.other(string.format("%swell", _P.contype)), _P.holewidth - 2 * _P.wellextension, _P.holeheight - 2 * _P.wellextension, _P.ringwidth + 2 * _P.wellextension)
    end
    -- draw deep n/p-well
    if _P.drawdeepwell then
        geometry.rectangle(guardring, generics.other(string.format("deep%swell", _P.contype)), _P.holewidth + _P.ringwidth - 2 * _P.deepwelloffset, _P.holeheight + _P.ringwidth - 2 * _P.deepwelloffset)
    end

    -- alignment box
    guardring:set_alignment_box(
        point.create(-(_P.holewidth + _P.ringwidth) / 2, -(_P.holeheight + _P.ringwidth) / 2),
        point.create( (_P.holewidth + _P.ringwidth) / 2,  (_P.holeheight + _P.ringwidth) / 2)
    )
end
