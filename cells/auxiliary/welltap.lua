function parameters()
    pcell.add_parameters(
        { "contype",                    "p" },
        { "width",                      5000 },
        { "height",                     5000 },
        { "extendalltop",               50 },
        { "extendallbottom",            50 },
        { "extendallleft",              50 },
        { "extendallright",             50 },
        { "extendimplantleft",          50, follow = "extendallleft" },
        { "extendimplantright",         50, follow = "extendallright" },
        { "extendimplanttop",           50, follow = "extendalltop" },
        { "extendimplantbottom",        50, follow = "extendallbottom" },
        { "extendsoiopenleft",          50, follow = "extendallleft" },
        { "extendsoiopenright",         50, follow = "extendallright" },
        { "extendsoiopentop",           50, follow = "extendalltop" },
        { "extendsoiopenbottom",        50, follow = "extendallbottom" },
        { "extendwellleft",             50, follow = "extendallleft" },
        { "extendwellright",            50, follow = "extendallright" },
        { "extendwelltop",              50, follow = "extendalltop" },
        { "extendwellbottom",           50, follow = "extendallbottom" },
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
        point.create(-_P.extendimplantleft, -_P.extendimplantbottom),
        point.create(_P.width + _P.extendimplantright, _P.height + _P.extendimplanttop)
    )
    geometry.rectanglebltr(welltap, generics.other("soiopen"),
        point.create(-_P.extendsoiopenleft, -_P.extendsoiopenbottom),
        point.create(_P.width + _P.extendsoiopenright, _P.height + _P.extendsoiopentop)
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
        point.create(-_P.extendwellleft, -_P.extendwellbottom),
        point.create(_P.width + _P.extendwellright, _P.height + _P.extendwelltop)
    )

    -- anchors
    welltap:add_area_anchor_bltr(
        "boundary",
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    welltap:add_area_anchor_bltr(
        "well",
        point.create(-_P.extendwellleft, -_P.extendwellbottom),
        point.create(_P.width + _P.extendwellright, _P.height + _P.extendwelltop)
    )
    welltap:add_area_anchor_bltr(
        "implant",
        point.create(-_P.extendimplantleft, -_P.extendimplantbottom),
        point.create(_P.width + _P.extendimplantright, _P.height + _P.extendimplanttop)
    )
    welltap:add_area_anchor_bltr(
        "soiopen",
        point.create(-_P.extendsoiopenleft, -_P.extendsoiopenbottom),
        point.create(_P.width + _P.extendsoiopenright, _P.height + _P.extendsoiopentop)
    )

    -- alignment box
    welltap:set_alignment_box(
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
end
