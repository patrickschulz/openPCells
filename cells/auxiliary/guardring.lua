function parameters()
    pcell.add_parameters(
        { "contype",                                       "p", posvals = set("p", "n", "none") },
        { "topmetal",                                       1 },
        { "drawmetal",                                      true },
        { "holewidth",                                      5000, posvals = positive() },
        { "holeheight",                                     5000, posvals = positive() },
        { "ringwidth",                                      technology.get_dimension("Minimum Active Contact Region Size"), posvals = positive() },
        { "drawsegments",                                   { "left", "right", "top", "bottom" } },
        { "extendall",                                      0 },
        { "extendallinner",                                 0, follow = "extendall" },
        { "extendallouter",                                 0, follow = "extendall" },
        { "wellinnerextension",                             technology.get_dimension("Minimum Well Extension"), follow = "extendallinner" },
        { "wellouterextension",                             technology.get_dimension("Minimum Well Extension"), follow = "extendallouter" },
        { "drawsoiopen",                                    true, },
        { "fillsoiopen",                                    false },
        { "soiopeninnerextension",                          technology.get_optional_dimension("Minimum Soiopen Extension", 0) , follow = "extendallinner" },
        { "soiopenouterextension",                          technology.get_optional_dimension("Minimum Soiopen Extension", 0) , follow = "extendallouter" },
        { "implantinnerextension",                          technology.get_dimension("Minimum Implant Extension"), follow = "extendallinner" },
        { "implantouterextension",                          technology.get_dimension("Minimum Implant Extension"), follow = "extendallouter" },
        { "drawimplant",                                    true },
        { "fillinnerimplant",                               false },
        { "innerimplantpolarity",                           "p" },
        { "innerimplantspace",                              0 },
        { "drawoxidetype",                                  true },
        { "oxidetype",                                      1 },
        { "filloxidetype",                                  true },
        { "oxidetypeinnerextension",                        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallinner" },
        { "oxidetypeouterextension",                        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallouter" },
        { "drawwell",                                       true },
        { "fillwell",                                       true },
        { "fillwelldrawhole",                               false },
        { "fillwellholeoffsettop",                          0 },
        { "fillwellholeoffsetbottom",                       0 },
        { "fillwellholeoffsetleft",                         0 },
        { "fillwellholeoffsetright",                        0 },
        { "drawdeepwell",                                   false },
        { "deepwelloffset",                                 technology.get_optional_dimension("Deep Well Offset", 0) },
        { "fit",                                            false },
        { "failifnotfit",                                   false }
    )
end

function anchors()
    pcell.add_area_anchor_documentation(
        "topsegment",
        "rectangular area of the active diffusion of the top guardring part",
        "'drawsegments' includes 'top'"
    )
    pcell.add_area_anchor_documentation(
        "bottomsegment",
        "rectangular area of the active diffusion of the bottom guardring part",
        "'drawsegments' includes 'bottom'"
    )
    pcell.add_area_anchor_documentation(
        "leftsegment",
        "rectangular area of the active diffusion of the left guardring part",
        "'drawsegments' includes 'left'"
    )
    pcell.add_area_anchor_documentation(
        "rightsegment",
        "rectangular area of the active diffusion of the right guardring part",
        "'drawsegments' includes 'right'"
    )
    pcell.add_area_anchor_documentation(
        "outerwell",
        "rectangular area of the outer well boundary"
    )
    pcell.add_area_anchor_documentation(
        "innerwell",
        "rectangular area of the inner well boundary"
    )
    pcell.add_area_anchor_documentation(
        "outerdeepwell",
        "rectangular area of the outer deep well boundary"
    )
    pcell.add_area_anchor_documentation(
        "outerimplant",
        "rectangular area of the outer implant boundary"
    )
    pcell.add_area_anchor_documentation(
        "innerimplant",
        "rectangular area of the inner implant boundary"
    )
    pcell.add_area_anchor_documentation(
        "outersoiopen",
        "rectangular area of the outer soiopen boundary. Always present, but only meaningful in an SOI node"
    )
    pcell.add_area_anchor_documentation(
        "innersoiopen",
        "rectangular area of the inner soiopen boundary. Always present, but only meaningful in an SOI node"
    )
    pcell.add_area_anchor_documentation(
        "outeroxidetype",
        "rectangular area of the outer oxidetype boundary. Always present, but only meaningful in an SOI node"
    )
    pcell.add_area_anchor_documentation(
        "inneroxidetype",
        "rectangular area of the inner oxidetype boundary. Always present, but only meaningful in an SOI node"
    )
    pcell.add_area_anchor_documentation(
        "outerboundary",
        "rectangular area of the outer active diffusion boundary"
    )
    pcell.add_area_anchor_documentation(
        "innerboundary",
        "rectangular area of the inner active diffusion boundary"
    )
end

function check(_P)
    if _P.failifnotfit then
        if _P.holewidth % _P.ringwidth ~= 0 then
        end
        if _P.holeheight % _P.ringwidth ~= 0 then
            return nil, string.format("could not exactly fit guardring height. holeheight (%d) is not a integer multiple of ringwidth (%d)", _P.holeheight, _P.ringwidth)
        end
    end
    return true
end

function layout(guardring, _P)
    local contactbase
    local xrep, yrep
    local holewidth, holeheight
    if _P.fit then
        xrep = math.ceil(_P.holewidth / _P.ringwidth)
        yrep = math.ceil(_P.holeheight / _P.ringwidth)
        holewidth = _P.ringwidth * xrep
        holeheight = _P.ringwidth * yrep
        contactbase = object.create("_contact")
        geometry.contactbarebltr(contactbase, "active",
            point.create(0, 0),
            point.create(_P.ringwidth, _P.ringwidth),
            "basecontact",
             { xcontinuous = true, ycontinuous = true }
        )
    else
        holewidth = _P.holewidth
        holeheight = _P.holeheight
    end

    local topmetal = technology.resolve_metal(_P.topmetal)
    if util.any_of("top", _P.drawsegments) then
        if _P.fit then
            for i = 1, xrep + 2 do
                guardring:merge_into(contactbase:move_to((i - 2) * _P.ringwidth, holeheight))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(0, holeheight),
                point.create(holewidth, holeheight + _P.ringwidth),
                string.format("top contacts:\n    x parameters: holewidth (%d)\n    y parameters: ringwidth (%d)", holewidth, _P.ringwidth)
            )
        end
        if _P.drawmetal then
            for i = 1, topmetal do
                geometry.rectanglebltr(guardring, generics.metal(i),
                    point.create(-_P.ringwidth, holeheight),
                    point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
                )
            end
        end
        if topmetal ~= 1 then
            geometry.viabarebltr(guardring, 1, topmetal,
                point.create(0, holeheight),
                point.create(holewidth, holeheight + _P.ringwidth)
            )
        end
        geometry.rectanglebltr(guardring, generics.active(),
            point.create(-_P.ringwidth, holeheight),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
        -- implant
        if _P.contype ~= "none" then
            if _P.drawimplant then
                geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                    point.create(-_P.ringwidth - _P.implantouterextension, holeheight - _P.implantinnerextension),
                    point.create(holewidth + _P.ringwidth + _P.implantouterextension, holeheight + _P.ringwidth + _P.implantouterextension)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(-_P.ringwidth - _P.soiopenouterextension, holeheight - _P.soiopeninnerextension),
                point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, holeheight + _P.ringwidth + _P.soiopenouterextension)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(-_P.ringwidth - _P.oxidetypeouterextension, holeheight - _P.oxidetypeinnerextension),
                point.create(holewidth + _P.ringwidth + _P.oxidetypeouterextension, holeheight + _P.ringwidth + _P.oxidetypeouterextension)
            )
        end
        guardring:add_area_anchor_bltr("topsegment",
            point.create(-_P.ringwidth, holeheight),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
    end
    if util.any_of("bottom", _P.drawsegments) then
        if _P.fit then
            for i = 1, xrep + 2 do
                guardring:merge_into(contactbase:move_to((i - 2) * _P.ringwidth, -_P.ringwidth))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(0, -_P.ringwidth),
                point.create(holewidth, 0),
                string.format("bottom contacts:\n    x parameters: holewidth (%d)\n    y parameters: ringwidth (%d)", holewidth, _P.ringwidth)
            )
        end
        if _P.drawmetal then
            for i = 1, topmetal do
                geometry.rectanglebltr(guardring, generics.metal(i),
                    point.create(-_P.ringwidth, -_P.ringwidth),
                    point.create(holewidth + _P.ringwidth, 0)
                )
            end
        end
        if topmetal ~= 1 then
            geometry.viabarebltr(guardring, 1, topmetal,
                point.create(0, -_P.ringwidth),
                point.create(holewidth, 0)
            )
        end
        geometry.rectanglebltr(guardring, generics.active(),
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, 0)
        )
        if _P.contype ~= "none" then
            if _P.drawimplant then
                geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                    point.create(-_P.ringwidth - _P.implantouterextension, -_P.implantouterextension - _P.ringwidth),
                    point.create(holewidth + _P.ringwidth + _P.implantouterextension, _P.implantinnerextension)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(-_P.ringwidth - _P.soiopenouterextension, -_P.ringwidth - _P.soiopenouterextension),
                point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, _P.soiopeninnerextension)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(-_P.ringwidth - _P.oxidetypeouterextension, -_P.ringwidth - _P.oxidetypeouterextension),
                point.create(holewidth + _P.ringwidth + _P.oxidetypeouterextension, _P.oxidetypeinnerextension)
            )
        end
        guardring:add_area_anchor_bltr("bottomsegment",
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, 0)
        )
    end
    if util.any_of("left", _P.drawsegments) then
        if _P.fit then
            for i = 1, yrep + 2 do
                guardring:merge_into(contactbase:move_to(-_P.ringwidth, (i - 2) * _P.ringwidth))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(-_P.ringwidth, 0),
                point.create(0,  holeheight),
                string.format("left contacts:\n    x parameters: ringwidth (%d)\n    y parameters: holeheight (%d)", _P.ringwidth, holeheight)
            )
        end
        if _P.drawmetal then
            for i = 1, topmetal do
                geometry.rectanglebltr(guardring, generics.metal(i),
                    point.create(-_P.ringwidth, -_P.ringwidth),
                    point.create(0,  holeheight + _P.ringwidth)
                )
            end
        end
        if topmetal ~= 1 then
            geometry.viabarebltr(guardring, 1, topmetal,
                point.create(-_P.ringwidth, 0),
                point.create(0,  holeheight)
            )
        end
        geometry.rectanglebltr(guardring, generics.active(),
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(0,  holeheight + _P.ringwidth)
        )
        if _P.contype ~= "none" then
            if _P.drawimplant then
                geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                    point.create(-_P.implantouterextension - _P.ringwidth, -_P.implantouterextension - _P.ringwidth),
                    point.create(_P.implantinnerextension, holeheight + _P.implantouterextension + _P.ringwidth)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(-_P.soiopenouterextension- _P.ringwidth, -_P.soiopenouterextension - _P.ringwidth),
                point.create(_P.soiopeninnerextension, holeheight + _P.soiopenouterextension + _P.ringwidth)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(-_P.oxidetypeouterextension- _P.ringwidth, -_P.oxidetypeouterextension - _P.ringwidth),
                point.create(_P.oxidetypeinnerextension, holeheight + _P.oxidetypeouterextension + _P.ringwidth)
            )
        end
        guardring:add_area_anchor_bltr("leftsegment",
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(0,  holeheight + _P.ringwidth)
        )
    end
    if util.any_of("right", _P.drawsegments) then
        if _P.fit then
            for i = 1, yrep + 2 do
                guardring:merge_into(contactbase:move_to(holewidth, (i - 2) * _P.ringwidth))
            end
        else
            geometry.contactbarebltr(guardring, "active",
                point.create(holewidth, 0),
                point.create(holewidth + _P.ringwidth, holeheight),
                string.format("right contacts:\n    x parameters: ringwidth (%d)\n    y parameters: holeheight (%d)", _P.ringwidth, holeheight)
            )
        end
        if _P.drawmetal then
            for i = 1, topmetal do
                geometry.rectanglebltr(guardring, generics.metal(i),
                    point.create(holewidth, -_P.ringwidth),
                    point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
                )
            end
        end
        if topmetal ~= 1 then
            geometry.viabarebltr(guardring, 1, topmetal,
                point.create(holewidth, 0),
                point.create(holewidth + _P.ringwidth,  holeheight)
            )
        end
        geometry.rectanglebltr(guardring, generics.active(),
            point.create(holewidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
        if _P.contype ~= "none" then
            if _P.drawimplant then
                geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                    point.create(holewidth - _P.implantinnerextension, -_P.implantouterextension - _P.ringwidth),
                    point.create(holewidth + _P.implantouterextension + _P.ringwidth, holeheight + _P.implantouterextension + _P.ringwidth)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(holewidth - _P.soiopeninnerextension, -_P.soiopenouterextension - _P.ringwidth),
                point.create(holewidth + _P.soiopenouterextension + _P.ringwidth, holeheight + _P.soiopenouterextension + _P.ringwidth)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(holewidth - _P.oxidetypeinnerextension, -_P.oxidetypeouterextension - _P.ringwidth),
                point.create(holewidth + _P.oxidetypeouterextension + _P.ringwidth, holeheight + _P.oxidetypeouterextension + _P.ringwidth)
            )
        end
        guardring:add_area_anchor_bltr("rightsegment",
            point.create(holewidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
    end

    -- well
    if _P.drawwell and _P.contype ~= "none" then
        if _P.fillwell then
            if _P.fillwelldrawhole then
                geometry.unequal_ring_pts(guardring, generics.well(_P.contype),
                    point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
                    point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension),
                    point.create(_P.fillwellholeoffsetleft, _P.fillwellholeoffsetbottom),
                    point.create(holewidth - _P.fillwellholeoffsetright, holeheight - _P.fillwellholeoffsettop)
                )
            else
                geometry.rectanglebltr(guardring, generics.well(_P.contype),
                    point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
                    point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension)
                )
            end
        else
            geometry.unequal_ring_pts(guardring, generics.well(_P.contype),
                point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
                point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension),
                point.create(_P.wellinnerextension, _P.wellinnerextension),
                point.create(holewidth - _P.wellinnerextension, holeheight - _P.wellinnerextension)
            )
        end
    end
    guardring:add_area_anchor_bltr("outerwell",
        point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
        point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension)
    )
    guardring:add_area_anchor_bltr("innerwell",
        point.create(_P.wellinnerextension, _P.wellinnerextension),
        point.create(holewidth - _P.wellinnerextension, holeheight - _P.wellinnerextension)
    )
    -- draw deep n/p-well
    if _P.contype ~= "none" then
        if _P.drawdeepwell then
            geometry.rectanglebltr(guardring, generics.well(_P.contype, "deep"),
                point.create(-_P.ringwidth - _P.wellouterextension + _P.deepwelloffset, -_P.ringwidth - _P.wellouterextension + _P.deepwelloffset),
                point.create(holewidth + _P.ringwidth + _P.wellouterextension - _P.deepwelloffset, holeheight + _P.ringwidth + _P.wellouterextension - _P.deepwelloffset)
            )
        end
    end
    guardring:add_area_anchor_bltr("outerdeepwell",
        point.create(-_P.ringwidth - _P.wellouterextension + _P.deepwelloffset, -_P.ringwidth - _P.wellouterextension + _P.deepwelloffset),
        point.create(holewidth + _P.ringwidth + _P.wellouterextension - _P.deepwelloffset, holeheight + _P.ringwidth + _P.wellouterextension - _P.deepwelloffset)
    )

    if _P.fillinnerimplant then
        geometry.rectanglebltr(guardring, generics.implant(_P.innerimplantpolarity),
            point.create(_P.implantinnerextension + _P.innerimplantspace, _P.implantinnerextension + _P.innerimplantspace),
            point.create(holewidth - _P.implantinnerextension - _P.innerimplantspace, holeheight - _P.implantinnerextension - _P.innerimplantspace)
        )
    end

    -- soiopen (filled)
    if _P.drawsoiopen and _P.fillsoiopen then
        geometry.rectanglebltr(guardring, generics.feol("soiopen"),
            point.create(-_P.ringwidth - _P.soiopenouterextension, -_P.ringwidth - _P.soiopenouterextension),
            point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, holeheight + _P.ringwidth + _P.soiopenouterextension)
        )
    end

    -- oxidetype (filled)
    if _P.drawoxidetype and _P.filloxidetype then
        geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
            point.create(-_P.ringwidth - _P.oxidetypeouterextension, -_P.ringwidth - _P.oxidetypeouterextension),
            point.create(holewidth + _P.ringwidth + _P.oxidetypeouterextension, holeheight + _P.ringwidth + _P.oxidetypeouterextension)
        )
    end

    -- useful anchors for alignment
    guardring:add_area_anchor_bltr("innerboundary",
        point.create(0, 0),
        point.create(holewidth, holeheight)
    )
    guardring:add_area_anchor_bltr("outerboundary",
        point.create(-_P.ringwidth, -_P.ringwidth),
        point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
    )
    guardring:add_area_anchor_bltr("innerimplant",
        point.create(_P.implantinnerextension, _P.implantinnerextension),
        point.create(holewidth - _P.implantinnerextension, holeheight - _P.implantinnerextension)
    )
    guardring:add_area_anchor_bltr("outerimplant",
        point.create(-_P.ringwidth - _P.implantouterextension, -_P.ringwidth - _P.implantouterextension),
        point.create(holewidth + _P.ringwidth + _P.implantouterextension, holeheight + _P.ringwidth + _P.implantouterextension)
    )
    guardring:add_area_anchor_bltr("innersoiopen",
        point.create(_P.soiopeninnerextension, _P.soiopeninnerextension),
        point.create(holewidth - _P.soiopeninnerextension, holeheight - _P.soiopeninnerextension)
    )
    guardring:add_area_anchor_bltr("outersoiopen",
        point.create(-_P.ringwidth - _P.soiopenouterextension, -_P.ringwidth - _P.soiopenouterextension),
        point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, holeheight + _P.ringwidth + _P.soiopenouterextension)
    )
    guardring:add_area_anchor_bltr("inneroxide",
        point.create(_P.oxidetypeinnerextension, _P.oxidetypeinnerextension),
        point.create(holewidth - _P.oxidetypeinnerextension, holeheight - _P.oxidetypeinnerextension)
    )
    guardring:add_area_anchor_bltr("outeroxide",
        point.create(-_P.ringwidth - _P.oxidetypeouterextension, -_P.ringwidth - _P.oxidetypeouterextension),
        point.create(holewidth + _P.ringwidth + _P.oxidetypeouterextension, holeheight + _P.ringwidth + _P.oxidetypeouterextension)
    )

    guardring:set_alignment_box(
        point.create(-_P.ringwidth, -_P.ringwidth),
        point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth),
        point.create(0, 0),
        point.create(holewidth, holeheight)
    )
    guardring:set_boundary({
        point.create(-_P.ringwidth, -_P.ringwidth),
        point.create(holewidth + _P.ringwidth, -_P.ringwidth),
        point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth),
        point.create(-_P.ringwidth, holeheight + _P.ringwidth),
    })
end
