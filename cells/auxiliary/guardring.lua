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
        { "wellinnerxextension",                            technology.get_dimension("Minimum Well Extension"), follow = "wellinnerextension" },
        { "wellinneryextension",                            technology.get_dimension("Minimum Well Extension"), follow = "wellinnerextension" },
        { "wellouterextension",                             technology.get_dimension("Minimum Well Extension"), follow = "extendallouter" },
        { "wellouterxextension",                            technology.get_dimension("Minimum Well Extension"), follow = "wellouterextension" },
        { "wellouteryextension",                            technology.get_dimension("Minimum Well Extension"), follow = "wellouterextension" },
        { "drawsoiopen",                                    true, },
        { "fillsoiopen",                                    false },
        { "soiopeninnerextension",                          technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "extendallinner" },
        { "soiopeninnerxextension",                         technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "soiopeninnerextension" },
        { "soiopeninneryextension",                         technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "soiopeninnerextension" },
        { "soiopenouterextension",                          technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "extendallouter" },
        { "soiopenouterxextension",                         technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "soiopenouterextension" },
        { "soiopenouteryextension",                         technology.get_optional_dimension("Minimum Soiopen Extension", 0), follow = "soiopenouterextension" },
        { "implantinnerextension",                          technology.get_dimension("Minimum Implant Extension"), follow = "extendallinner" },
        { "implantinnerxextension",                         technology.get_dimension("Minimum Implant Extension"), follow = "implantinnerextension" },
        { "implantinneryextension",                         technology.get_dimension("Minimum Implant Extension"), follow = "implantinnerextension" },
        { "implantouterextension",                          technology.get_dimension("Minimum Implant Extension"), follow = "extendallouter" },
        { "implantouterxextension",                         technology.get_dimension("Minimum Implant Extension"), follow = "implantouterextension" },
        { "implantouteryextension",                         technology.get_dimension("Minimum Implant Extension"), follow = "implantouterextension" },
        { "drawimplant",                                    true },
        { "fillinnerimplant",                               false },
        { "innerimplantpolarity",                           "p" },
        { "innerimplantspace",                              0 },
        { "drawoxidetype",                                  true },
        { "oxidetype",                                      1 },
        { "filloxidetype",                                  true },
        { "oxidetypeinnerextension",                        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallinner" },
        { "oxidetypeinnerxextension",                       technology.get_dimension("Minimum Oxide Extension"), follow = "oxidetypeinnerextension" },
        { "oxidetypeinneryextension",                       technology.get_dimension("Minimum Oxide Extension"), follow = "oxidetypeinnerextension" },
        { "oxidetypeouterextension",                        technology.get_dimension("Minimum Oxide Extension"), follow = "extendallouter" },
        { "oxidetypeouterxextension",                       technology.get_dimension("Minimum Oxide Extension"), follow = "oxidetypeouterextension" },
        { "oxidetypeouteryextension",                       technology.get_dimension("Minimum Oxide Extension"), follow = "oxidetypeouterextension" },
        { "drawwell",                                       true },
        { "fillwell",                                       true },
        { "fillwelldrawhole",                               false },
        { "fillwellholeoffset",                             0 },
        { "fillwellholeoffsettop",                          0, follow = "fillwellholeoffset" },
        { "fillwellholeoffsetbottom",                       0, follow = "fillwellholeoffset" },
        { "fillwellholeoffsetleft",                         0, follow = "fillwellholeoffset" },
        { "fillwellholeoffsetright",                        0, follow = "fillwellholeoffset" },
        { "drawdeepwell",                                   false },
        { "deepwelloffset",                                 technology.get_optional_dimension("Deep Well Offset", 0) },
        { "fit",                                            false },
        { "failifnotfit",                                   false },
        { "net",                                            "" },
        { "addtopbottomnet",                                false },
        { "addtopnet",                                      false, follow = "addtopbottomnet" },
        { "addbottomnet",                                   false, follow = "addtopbottomnet" },
        { "addleftrightnet",                                false },
        { "addleftnet",                                     false, follow = "addleftrightnet" },
        { "addrightnet",                                    false, follow = "addleftrightnet" }
    )
end

function check(_P)
    if _P.net ~= "" and not (_P.addtopnet or _P.addbottomnet or _P.addleftnet or _P.addrightnet) then
        return false, "if a non-empty net is given, at least one segment must be specified as to be added to the net (e.g. 'addtopnet = true')"
    end
    return true
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
                    point.create(-_P.ringwidth - _P.implantouterxextension, holeheight - _P.implantinneryextension),
                    point.create(holewidth + _P.ringwidth + _P.implantouterxextension, holeheight + _P.ringwidth + _P.implantouteryextension)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(-_P.ringwidth - _P.soiopenouterxextension, holeheight - _P.soiopeninneryextension),
                point.create(holewidth + _P.ringwidth + _P.soiopenouterxextension, holeheight + _P.ringwidth + _P.soiopenouteryextension)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(-_P.ringwidth - _P.oxidetypeouterxextension, holeheight - _P.oxidetypeinneryextension),
                point.create(holewidth + _P.ringwidth + _P.oxidetypeouterxextension, holeheight + _P.ringwidth + _P.oxidetypeouteryextension)
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
                    point.create(-_P.ringwidth - _P.implantouterxextension, -_P.implantouteryextension - _P.ringwidth),
                    point.create(holewidth + _P.ringwidth + _P.implantouterxextension, _P.implantinneryextension)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(-_P.ringwidth - _P.soiopenouterxextension, -_P.ringwidth - _P.soiopenouteryextension),
                point.create(holewidth + _P.ringwidth + _P.soiopenouterxextension, _P.soiopeninneryextension)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(-_P.ringwidth - _P.oxidetypeouterxextension, -_P.ringwidth - _P.oxidetypeouteryextension),
                point.create(holewidth + _P.ringwidth + _P.oxidetypeouterxextension, _P.oxidetypeinneryextension)
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
                    point.create(-_P.implantouterxextension - _P.ringwidth, -_P.implantouteryextension - _P.ringwidth),
                    point.create(_P.implantinnerxextension, holeheight + _P.implantouteryextension + _P.ringwidth)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(-_P.soiopenouterxextension- _P.ringwidth, -_P.soiopenouteryextension - _P.ringwidth),
                point.create(_P.soiopeninnerxextension, holeheight + _P.soiopenouteryextension + _P.ringwidth)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(-_P.oxidetypeouterxextension- _P.ringwidth, -_P.oxidetypeouteryextension - _P.ringwidth),
                point.create(_P.oxidetypeinnerxextension, holeheight + _P.oxidetypeouteryextension + _P.ringwidth)
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
                    point.create(holewidth - _P.implantinnerxextension, -_P.implantouteryextension - _P.ringwidth),
                    point.create(holewidth + _P.implantouteryextension + _P.ringwidth, holeheight + _P.implantouterxextension + _P.ringwidth)
                )
            end
        end
        -- soiopen
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.feol("soiopen"),
                point.create(holewidth - _P.soiopeninnerxextension, -_P.soiopenouteryextension - _P.ringwidth),
                point.create(holewidth + _P.soiopenouterxextension + _P.ringwidth, holeheight + _P.soiopenouteryextension + _P.ringwidth)
            )
        end
        -- oxidetype
        if _P.drawoxidetype and not _P.filloxidetype then
            geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
                point.create(holewidth - _P.oxidetypeinnerxextension, -_P.oxidetypeouteryextension - _P.ringwidth),
                point.create(holewidth + _P.oxidetypeouterxextension + _P.ringwidth, holeheight + _P.oxidetypeouteryextension + _P.ringwidth)
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
                    point.create(-_P.ringwidth - _P.wellouterxextension, -_P.ringwidth - _P.wellouteryextension),
                    point.create(holewidth + _P.ringwidth + _P.wellouterxextension, holeheight + _P.ringwidth + _P.wellouteryextension),
                    point.create(_P.fillwellholeoffsetleft, _P.fillwellholeoffsetbottom),
                    point.create(holewidth - _P.fillwellholeoffsetright, holeheight - _P.fillwellholeoffsettop)
                )
            else
                geometry.rectanglebltr(guardring, generics.well(_P.contype),
                    point.create(-_P.ringwidth - _P.wellouterxextension, -_P.ringwidth - _P.wellouteryextension),
                    point.create(holewidth + _P.ringwidth + _P.wellouterxextension, holeheight + _P.ringwidth + _P.wellouteryextension)
                )
            end
        else
            geometry.unequal_ring_pts(guardring, generics.well(_P.contype),
                point.create(-_P.ringwidth - _P.wellouterxextension, -_P.ringwidth - _P.wellouteryextension),
                point.create(holewidth + _P.ringwidth + _P.wellouterxextension, holeheight + _P.ringwidth + _P.wellouteryextension),
                point.create(_P.wellinnerxextension, _P.wellinneryextension),
                point.create(holewidth - _P.wellinnerxextension, holeheight - _P.wellinneryextension)
            )
        end
    end
    guardring:add_area_anchor_bltr("outerwell",
        point.create(-_P.ringwidth - _P.wellouterxextension, -_P.ringwidth - _P.wellouteryextension),
        point.create(holewidth + _P.ringwidth + _P.wellouterxextension, holeheight + _P.ringwidth + _P.wellouteryextension)
    )
    guardring:add_area_anchor_bltr("innerwell",
        point.create(_P.wellinnerxextension, _P.wellinneryextension),
        point.create(holewidth - _P.wellinnerxextension, holeheight - _P.wellinneryextension)
    )
    -- draw deep n/p-well
    if _P.contype ~= "none" then
        if _P.drawdeepwell then
            geometry.rectanglebltr(guardring, generics.well(_P.contype, "deep"),
                point.create(-_P.ringwidth - _P.wellouterxextension + _P.deepwelloffset, -_P.ringwidth - _P.wellouteryextension + _P.deepwelloffset),
                point.create(holewidth + _P.ringwidth + _P.wellouterxextension - _P.deepwelloffset, holeheight + _P.ringwidth + _P.wellouteryextension - _P.deepwelloffset)
            )
        end
    end
    guardring:add_area_anchor_bltr("outerdeepwell",
        point.create(-_P.ringwidth - _P.wellouterxextension + _P.deepwelloffset, -_P.ringwidth - _P.wellouteryextension + _P.deepwelloffset),
        point.create(holewidth + _P.ringwidth + _P.wellouterxextension - _P.deepwelloffset, holeheight + _P.ringwidth + _P.wellouteryextension - _P.deepwelloffset)
    )

    if _P.fillinnerimplant then
        geometry.rectanglebltr(guardring, generics.implant(_P.innerimplantpolarity),
            point.create(_P.implantinnerxextension + _P.innerimplantspace, _P.implantinneryextension + _P.innerimplantspace),
            point.create(holewidth - _P.implantinnerxextension - _P.innerimplantspace, holeheight - _P.implantinneryextension - _P.innerimplantspace)
        )
    end

    -- soiopen (filled)
    if _P.drawsoiopen and _P.fillsoiopen then
        geometry.rectanglebltr(guardring, generics.feol("soiopen"),
            point.create(-_P.ringwidth - _P.soiopenouterxextension, -_P.ringwidth - _P.soiopenouteryextension),
            point.create(holewidth + _P.ringwidth + _P.soiopenouterxextension, holeheight + _P.ringwidth + _P.soiopenouteryextension)
        )
    end

    -- oxidetype (filled)
    if _P.drawoxidetype and _P.filloxidetype then
        geometry.rectanglebltr(guardring, generics.oxide(_P.oxidetype),
            point.create(-_P.ringwidth - _P.oxidetypeouterxextension, -_P.ringwidth - _P.oxidetypeouteryextension),
            point.create(holewidth + _P.ringwidth + _P.oxidetypeouterxextension, holeheight + _P.ringwidth + _P.oxidetypeouteryextension)
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
        point.create(_P.implantinnerxextension, _P.implantinneryextension),
        point.create(holewidth - _P.implantinnerxextension, holeheight - _P.implantinneryextension)
    )
    guardring:add_area_anchor_bltr("outerimplant",
        point.create(-_P.ringwidth - _P.implantouterxextension, -_P.ringwidth - _P.implantouteryextension),
        point.create(holewidth + _P.ringwidth + _P.implantouterxextension, holeheight + _P.ringwidth + _P.implantouteryextension)
    )
    guardring:add_area_anchor_bltr("innersoiopen",
        point.create(_P.soiopeninnerxextension, _P.soiopeninneryextension),
        point.create(holewidth - _P.soiopeninnerxextension, holeheight - _P.soiopeninneryextension)
    )
    guardring:add_area_anchor_bltr("outersoiopen",
        point.create(-_P.ringwidth - _P.soiopenouterxextension, -_P.ringwidth - _P.soiopenouteryextension),
        point.create(holewidth + _P.ringwidth + _P.soiopenouterxextension, holeheight + _P.ringwidth + _P.soiopenouteryextension)
    )
    guardring:add_area_anchor_bltr("inneroxide",
        point.create(_P.oxidetypeinnerxextension, _P.oxidetypeinneryextension),
        point.create(holewidth - _P.oxidetypeinnerxextension, holeheight - _P.oxidetypeinneryextension)
    )
    guardring:add_area_anchor_bltr("outeroxide",
        point.create(-_P.ringwidth - _P.oxidetypeouterxextension, -_P.ringwidth - _P.oxidetypeouteryextension),
        point.create(holewidth + _P.ringwidth + _P.oxidetypeouterxextension, holeheight + _P.ringwidth + _P.oxidetypeouteryextension)
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

    -- add net to segments
    if _P.net ~= "" then
        if util.any_of("top", _P.drawsegments) and _P.addtopnet then
            guardring:add_net_shape(
                _P.net,
                guardring:get_area_anchor("topsegment").bl,
                guardring:get_area_anchor("topsegment").tr,
                generics.metal(_P.topmetal)
            )
        end
        if util.any_of("bottom", _P.drawsegments) and _P.addbottomnet then
            guardring:add_net_shape(
                _P.net,
                guardring:get_area_anchor("bottomsegment").bl,
                guardring:get_area_anchor("bottomsegment").tr,
                generics.metal(_P.topmetal)
            )
        end
        if util.any_of("left", _P.drawsegments) and _P.addleftnet then
            guardring:add_net_shape(
                _P.net,
                guardring:get_area_anchor("leftsegment").bl,
                guardring:get_area_anchor("leftsegment").tr,
                generics.metal(_P.topmetal)
            )
        end
        if util.any_of("right", _P.drawsegments) and _P.addrightnet then
            guardring:add_net_shape(
                _P.net,
                guardring:get_area_anchor("rightsegment").bl,
                guardring:get_area_anchor("rightsegment").tr,
                generics.metal(_P.topmetal)
            )
        end
    end
end
