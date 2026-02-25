function parameters()
    pcell.add_parameters(
        { "contype",                    "p" },
        { "oxidetype",                  1 },
        { "width",                      5000, posvals = positive() },
        { "height",                     5000, posvals = positive() },
        { "drawoxidetype",              true },
        { "extendall",                  0 },
        { "extendalltop",               0, follow = "extendall" },
        { "extendallbottom",            0, follow = "extendall" },
        { "extendallleft",              0, follow = "extendall" },
        { "extendallright",             0, follow = "extendall" },
        { "extendimplantleft",          technology.get_dimension("Minimum Implant Extension"), follow = "extendallleft" },
        { "extendimplantright",         technology.get_dimension("Minimum Implant Extension"), follow = "extendallright" },
        { "extendimplanttop",           technology.get_dimension("Minimum Implant Extension"), follow = "extendalltop" },
        { "extendimplantbottom",        technology.get_dimension("Minimum Implant Extension"), follow = "extendallbottom" },
        { "extendsoiopenleft",          technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "extendallleft" },
        { "extendsoiopenright",         technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "extendallright" },
        { "extendsoiopentop",           technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "extendalltop" },
        { "extendsoiopenbottom",        technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "extendallbottom" },
        { "extendwellleft",             technology.get_dimension("Minimum Well Extension"), follow = "extendallleft" },
        { "extendwellright",            technology.get_dimension("Minimum Well Extension"), follow = "extendallright" },
        { "extendwelltop",              technology.get_dimension("Minimum Well Extension"), follow = "extendalltop" },
        { "extendwellbottom",           technology.get_dimension("Minimum Well Extension"), follow = "extendallbottom" },
        { "extendoxidetypeleft",        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallleft" },
        { "extendoxidetyperight",       technology.get_dimension("Minimum Oxide Extension"), follow = "extendallright" },
        { "extendoxidetypetop",         technology.get_dimension("Minimum Oxide Extension"), follow = "extendalltop" },
        { "extendoxidetypebottom",      technology.get_dimension("Minimum Oxide Extension"), follow = "extendallbottom" },
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
        "oxide",
        "region of the oxide type layer",
        "drawoxidetype == true"
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
    if _P.drawoxidetype then
        geometry.rectanglebltr(welltap, generics.oxide(_P.oxidetype),
            point.create(-_P.extendoxidetypeleft, -_P.extendoxidetypebottom),
            point.create(_P.width + _P.extendoxidetyperight, _P.height + _P.extendoxidetypetop)
        )
    end
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
    if _P.drawoxidetype then
        welltap:add_area_anchor_bltr(
            "oxide",
            point.create(-_P.extendoxidetypeleft, -_P.extendoxidetypebottom),
            point.create(_P.width + _P.extendoxidetyperight, _P.height + _P.extendoxidetypetop)
        )
    end
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
