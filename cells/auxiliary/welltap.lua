function parameters()
    pcell.add_parameters(
        { "contype",                    "p" },
        { "width",                      5000, posvals = positive() },
        { "height",                     5000, posvals = positive() },
        { "extendall",                  50 },
        { "extendalltop",               50, follow = "extendall" },
        { "extendallbottom",            50, follow = "extendall" },
        { "extendallleft",              50, follow = "extendall" },
        { "extendallright",             50, follow = "extendall" },
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

function anchors()
    pcell.add_area_anchor_documentation(
        "boundary",
        "region of the active diffusion"
    )
    pcell.add_area_anchor_documentation(
        "well",
        "region of the well"
    )
    pcell.add_area_anchor_documentation(
        "implant",
        "region of the implant"
    )
    pcell.add_area_anchor_documentation(
        "soiopen",
        "region of the soi opening layer. Always present, but only meaningful in an SOI node"
    )
end

function layout(welltap, _P)
    -- active, implant and SOI opening
    geometry.rectanglebltr(welltap, generics.active(), 
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
    geometry.rectanglebltr(welltap, generics.implant(_P.contype),
        point.create(-_P.extendimplantleft, -_P.extendimplantbottom),
        point.create(_P.width + _P.extendimplantright, _P.height + _P.extendimplanttop)
    )
    geometry.rectanglebltr(welltap, generics.feol("soiopen"),
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
        "welltabcontacts",
        { xcontinuous = _P.xcontinuous, ycontinuous = _P.ycontinuous }
    )

    -- well
    geometry.rectanglebltr(welltap, generics.well(_P.contype),
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
