function parameters()
    pcell.add_parameters(
        { "contype",                    "p" },
        { "width",                      5000 },
        { "height",                     5000 },
        { "implantleftextension",       50 },
        { "implantrightextension",      50 },
        { "implanttopextension",        50 },
        { "implantbottomextension",     50 },
        { "soiopenleftextension",       50 },
        { "soiopenrightextension",      50 },
        { "soiopentopextension",        50 },
        { "soiopenbottomextension",     50 },
        { "wellleftextension",          50 },
        { "wellrightextension",         50 },
        { "welltopextension",           50 },
        { "wellbottomextension",        50 },
        { "xcontinuous",                false },
        { "ycontinuous",                false }
    )
end

function layout(welltap, _P)
    -- active, implant and SOI opening
    geometry.rectanglebltr(welltap, generics.other("active"), 
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    geometry.rectanglebltr(welltap, generics.other(string.format("%simplant", _P.contype)),
        point.create(-_P.implantleftextension, -_P.implantbottomextension),
        point.create(_P.width + _P.implantrightextension, _P.height + _P.implanttopextension)
    )
    geometry.rectanglebltr(welltap, generics.other("soiopen"),
        point.create(-_P.soiopenleftextension, -_P.soiopenbottomextension),
        point.create(_P.width + _P.soiopenrightextension, _P.height + _P.soiopentopextension)
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
        point.create(-_P.wellleftextension, -_P.wellbottomextension),
        point.create(_P.width + _P.wellrightextension, _P.height + _P.welltopextension)
    )

    -- anchors
    welltap:add_area_anchor_bltr(
        "boundary",
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    welltap:add_area_anchor_bltr(
        "well",
        point.create(-_P.wellleftextension, -_P.wellbottomextension),
        point.create(_P.width + _P.wellrightextension, _P.height + _P.welltopextension)
    )

    -- alignment box
    welltap:set_alignment_box(
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
end
