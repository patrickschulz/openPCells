function parameters()
    pcell.add_parameters(
        { "contype",                                       "p" },
        { "topmetal",                                        1 },
        { "drawmetal",                                    true },
        { "holewidth",                                    5000 },
        { "holeheight",                                   5000 },
        { "ringwidth",                                     200 },
        { "drawsegments", { "left", "right", "top", "bottom" } },
        { "extendall",                                      50 },
        { "extendallinner",                                 50, follow = "extendall" },
        { "extendallouter",                                 50, follow = "extendall" },
        { "wellinnerextension",                             50, follow = "extendallinner" },
        { "wellouterextension",                             50, follow = "extendallouter" },
        { "drawsoiopen",                                    true, },
        { "fillsoiopen",                                    false },
        { "soiopeninnerextension",                          50 , follow = "extendallinner" },
        { "soiopenouterextension",                          50 , follow = "extendallouter" },
        { "implantinnerextension",                          50, follow = "extendallinner" },
        { "implantouterextension",                          50, follow = "extendallouter" },
        { "drawimplant",                                  true },
        { "fillinnerimplant",                            false },
        { "innerimplantpolarity",                          "p" },
        { "innerimplantspace",                               0 },
        { "fillwell",                                     true },
        { "fillwelldrawhole",                            false },
        { "fillwellholeoffsettop",                           0 },
        { "fillwellholeoffsetbottom",                        0 },
        { "fillwellholeoffsetleft",                          0 },
        { "fillwellholeoffsetright",                         0 },
        { "drawdeepwell",                                false },
        { "deepwelloffset",                                  0 },
        { "fit",                                         false },
        { "failifnotfit",                                false }
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
                point.create(holewidth, holeheight + _P.ringwidth)
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
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.ringwidth, holeheight),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
        -- implant
        if _P.drawimplant then
            geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                point.create(-_P.ringwidth - _P.implantouterextension, holeheight - _P.implantinnerextension),
                point.create(holewidth + _P.ringwidth + _P.implantouterextension, holeheight + _P.ringwidth + _P.implantouterextension)
            )
        end
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.other("soiopen"),
                point.create(-_P.ringwidth - _P.soiopenouterextension, holeheight - _P.soiopeninnerextension),
                point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, holeheight + _P.ringwidth + _P.soiopenouterextension)
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
                point.create(holewidth, 0)
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
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, 0)
        )
        if _P.drawimplant then
            geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                point.create(-_P.ringwidth - _P.implantouterextension, -_P.implantouterextension - _P.ringwidth),
                point.create(holewidth + _P.ringwidth + _P.implantouterextension, _P.implantinnerextension)
            )
        end
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.other("soiopen"),
                point.create(-_P.ringwidth - _P.soiopenouterextension, -_P.ringwidth - _P.soiopenouterextension),
                point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, _P.soiopeninnerextension)
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
                point.create(0,  holeheight)
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
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(-_P.ringwidth, -_P.ringwidth),
            point.create(0,  holeheight + _P.ringwidth)
        )
        if _P.drawimplant then
            geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                point.create(-_P.implantouterextension - _P.ringwidth, -_P.implantouterextension - _P.ringwidth),
                point.create(_P.implantinnerextension, holeheight + _P.implantouterextension + _P.ringwidth)
            )
        end
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.other("soiopen"),
                point.create(-_P.soiopenouterextension- _P.ringwidth, -_P.soiopenouterextension - _P.ringwidth),
                point.create(_P.soiopeninnerextension, holeheight + _P.soiopenouterextension + _P.ringwidth)
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
                point.create(holewidth + _P.ringwidth, holeheight)
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
        geometry.rectanglebltr(guardring, generics.other("active"),
            point.create(holewidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
        if _P.drawimplant then
            geometry.rectanglebltr(guardring, generics.implant(_P.contype),
                point.create(holewidth - _P.implantinnerextension, -_P.implantouterextension - _P.ringwidth),
                point.create(holewidth + _P.implantouterextension + _P.ringwidth, holeheight + _P.implantouterextension + _P.ringwidth)
            )
        end
        if _P.drawsoiopen and not _P.fillsoiopen then
            geometry.rectanglebltr(guardring, generics.other("soiopen"),
                point.create(holewidth - _P.soiopeninnerextension, -_P.soiopenouterextension - _P.ringwidth),
                point.create(holewidth + _P.soiopenouterextension + _P.ringwidth, holeheight + _P.soiopenouterextension + _P.ringwidth)
            )
        end
        guardring:add_area_anchor_bltr("rightsegment",
            point.create(holewidth, -_P.ringwidth),
            point.create(holewidth + _P.ringwidth, holeheight + _P.ringwidth)
        )
    end

    -- well
    if _P.fillwell then
        if _P.fillwelldrawhole then
            geometry.unequal_ring_pts(guardring, generics.other(string.format("%swell", _P.contype)),
                point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
                point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension),
                point.create(_P.fillwellholeoffsetleft, _P.fillwellholeoffsetbottom),
                point.create(holewidth - _P.fillwellholeoffsetright, holeheight - _P.fillwellholeoffsettop)
            )
        else
            geometry.rectanglebltr(guardring, generics.other(string.format("%swell", _P.contype)),
                point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
                point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension)
            )
        end
    else
        geometry.unequal_ring_pts(guardring, generics.other(string.format("%swell", _P.contype)),
            point.create(-_P.ringwidth - _P.wellouterextension, -_P.ringwidth - _P.wellouterextension),
            point.create(holewidth + _P.ringwidth + _P.wellouterextension, holeheight + _P.ringwidth + _P.wellouterextension),
            point.create(_P.wellinnerextension, _P.wellinnerextension),
            point.create(holewidth - _P.wellinnerextension, holeheight - _P.wellinnerextension)
        )
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
    if _P.drawdeepwell then
        geometry.rectanglebltr(guardring, generics.other(string.format("deep%swell", _P.contype)),
            point.create(-_P.ringwidth - _P.wellouterextension + _P.deepwelloffset, -_P.ringwidth - _P.wellouterextension + _P.deepwelloffset),
            point.create(holewidth + _P.ringwidth + _P.wellouterextension - _P.deepwelloffset, holeheight + _P.ringwidth + _P.wellouterextension - _P.deepwelloffset)
        )
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

    if _P.drawsoiopen and _P.fillsoiopen then
        geometry.rectanglebltr(guardring, generics.other("soiopen"),
            point.create(-_P.ringwidth - _P.soiopenouterextension, -_P.ringwidth - _P.soiopenouterextension),
            point.create(holewidth + _P.ringwidth + _P.soiopenouterextension, holeheight + _P.ringwidth + _P.soiopenouterextension)
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
