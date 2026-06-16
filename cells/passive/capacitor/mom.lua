function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)",         5 },
        { "fingerwidth(Finger Width)",          technology.get_dimension_max("Minimum M1 Width", "Minimum M2 Width") },
        { "fingerspace(Finger Space)",          technology.get_dimension_max("Minimum M1 Space", "Minimum M2 Space") },
        { "fingerheight(Finger Height)",        1000 },
        { "fingeroffset(Finger Offset)",        technology.get_dimension_max("Minimum M1 Space", "Minimum M2 Space") },
        { "railwidth(Rail Width)",              technology.get_dimension_max("Minimum M1 Width", "Minimum M2 Width") },
        { "urailwidth",                         technology.get_dimension_max("Minimum M1 Width", "Minimum M2 Width"), follow = "railwidth" },
        { "lrailwidth",                         technology.get_dimension_max("Minimum M1 Width", "Minimum M2 Width"), follow = "railwidth" },
        { "rext(Rail Extension)",               0 },
        { "firstmetal(Start Metal)",            1 },
        { "lastmetal(End Metal)",               2 },
        { "alternatingpolarity",                true },
        { "flippolarity",                       false },
        { "drawurail",                          true },
        { "drawlrail",                          true },
        { "urext",                              0, follow = "rext" },
        { "lrext",                              0, follow = "rext" },
        { "drawvia",                            true },
        { "drawuvia",                           true, follow = "drawvia" },
        { "drawlvia",                           true, follow = "drawvia" },
        { "uviashrink",                         0 },
        { "lviashrink",                         0 },
        { "viaxcontinuous",                     false },
        { "viaycontinuous",                     false },
        { "drawfill",                           false },
        { "fillmetals",                         {} },
        { "fillwidth",                          100 },
        { "fillheight",                         100 },
        { "fillxspace",                         100 },
        { "fillyspace",                         100 },
        { "fillxextend",                        0 },
        { "fillyextend",                        0 },
        { "alignmentbox_include_halffinger",    false }
    )
end

function anchors()
    pcell.add_area_anchor_documentation(
        "upperrail",
        "metal area of upper input rail",
        "drawurail == true"
    )
    pcell.add_area_anchor_documentation(
        "lowerrail",
        "metal area of lower input rail",
        "drawlrail == true"
    )
    pcell.add_anchor_line_documentation(
        "railbottom",
        "(y-line) lowest point of the entire capacitor, including rails"
    )
    pcell.add_anchor_line_documentation(
        "railtop",
        "(y-line) highest point of the entire capacitor, including rails"
    )
end

function layout(momcap, _P)
    local pitch = _P.fingerwidth + _P.fingerspace

    local viafunc
    if not _P.viaxcontinuous and not _P.viaycontinuous then
        viafunc = geometry.viabltr
    elseif _P.viaxcontinuous and not _P.viaycontinuous then
        viafunc = geometry.viabltr_xcontinuous
    elseif not _P.viaxcontinuous and _P.viaycontinuous then
        viafunc = geometry.viabltr_ycontinuous
    else
        viafunc = geometry.viabltr_continuous
    end

    local firstmetal = technology.resolve_metal(_P.firstmetal)
    local lastmetal = technology.resolve_metal(_P.lastmetal)
    for m = firstmetal, lastmetal do
        -- rails
        if _P.drawlrail then
            momcap:add_area_anchor_bltr("lowerrail",
                point.create(
                    -_P.lrext,
                    0
                ),
                point.create(
                    _P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.lrext,
                    _P.lrailwidth
                )
            )
            geometry.rectanglebltr(momcap, generics.metal(m),
                momcap:get_area_anchor("lowerrail").bl,
                momcap:get_area_anchor("lowerrail").tr
            )
        end
        if _P.drawurail then
            momcap:add_area_anchor_bltr("upperrail",
                point.create(
                    -_P.urext,
                    _P.fingerheight + 2 * _P.fingeroffset + _P.urailwidth
                ),
                point.create(
                    _P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.urext,
                    _P.fingerheight + 2 * _P.fingeroffset + _P.urailwidth + _P.urailwidth
                )
            )
            geometry.rectanglebltr(
                momcap, generics.metal(m),
                momcap:get_area_anchor("upperrail").bl,
                momcap:get_area_anchor("upperrail").tr
            )
        end
        -- fingers
        for f = 1, _P.fingers do
            local xshift = (f - 1) * pitch
            local polarity = 0
            if _P.alternatingpolarity then
                polarity = (m - firstmetal) % 2
            end
            local yshift = (f % 2 == polarity) and 0 or _P.fingeroffset
            geometry.rectanglebltr(
                momcap, generics.metal(m),
                point.create(xshift, _P.lrailwidth + yshift),
                point.create(xshift + _P.fingerwidth, _P.lrailwidth + yshift + _P.fingerheight + _P.fingeroffset)
            )
        end
    end
    momcap:add_anchor_line_y("railbottom", 0)
    momcap:add_anchor_line_y("railtop", _P.fingerheight + 2 * _P.fingeroffset + _P.urailwidth + _P.urailwidth)
    if _P.drawurail and _P.drawuvia then
        if firstmetal ~= lastmetal then
            viafunc(
                momcap, firstmetal, lastmetal,
                momcap:get_area_anchor("upperrail").bl:translate_x(_P.uviashrink),
                momcap:get_area_anchor("upperrail").tr:translate_x(-_P.uviashrink),
                string.format(
                    "lower rail via:\n    x parameters: urext (%d), fingers (%d), fingerwidth (%d), fingerspace (%d)\n    y parameters: lrailwidth (%d)",
                    _P.urext, _P.fingers, _P.fingerwidth, _P.fingerspace, _P.lrailwidth)
            )
        end
    end
    if _P.drawlrail and _P.drawlvia then
        if firstmetal ~= lastmetal then
            viafunc(
                momcap, firstmetal, lastmetal,
                momcap:get_area_anchor("lowerrail").bl:translate_x(_P.lviashrink),
                momcap:get_area_anchor("lowerrail").tr:translate_x(-_P.lviashrink),
                string.format(
                    "upper rail via:\n    x parameters: lrext (%d), fingers (%d), fingerwidth (%d), fingerspace (%d)\n    y parameters: lrailwidth (%d)",
                    _P.lrext, _P.fingers, _P.fingerwidth, _P.fingerspace, _P.urailwidth)
            )
        end
    end

    if _P.drawfill then
        local xpitch = _P.fillwidth + _P.fillxspace
        local ypitch = _P.fillheight + _P.fillyspace
        local totalwidth = 2 * math.max(_P.urext, _P.lrext) + _P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + 2 * _P.fillxextend
        local totalheight = _P.lrailwidth + _P.urailwidth + _P.fingerheight + 2 * _P.fingeroffset + 2 * _P.fillyextend
        local xrep = (totalwidth + _P.fillxspace) // xpitch
        local yrep = (totalheight + _P.fillyspace) // ypitch
        local xshift = (totalwidth - xrep * _P.fillwidth - (xrep - 1) * _P.fillxspace) / 2
        local yshift = (totalheight - yrep * _P.fillheight - (yrep - 1) * _P.fillyspace) / 2
        for _, m in ipairs(_P.fillmetals) do
            geometry.rectanglearray(
                momcap, generics.metal(m),
                _P.fillwidth, _P.fillheight,
                xshift - math.max(_P.urext, _P.lrext) - _P.fillxextend, yshift - _P.fillyextend,
                xrep, yrep,
                _P.fillwidth + _P.fillxspace,
                _P.fillheight + _P.fillyspace
            )
        end
    end

    if _P.alignmentbox_include_halffinger then
        momcap:set_alignment_box(
            point.create(0, 0),
            point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth + _P.urailwidth),
            point.create(_P.fingerwidth, _P.lrailwidth),
            point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace - _P.fingerwidth, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth)
        )
    else
        momcap:set_alignment_box(
            point.create(-math.max(_P.urext, _P.lrext), 0),
            point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + math.max(_P.urext, _P.lrext), _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth + _P.urailwidth),
            point.create(-math.max(_P.urext, _P.lrext), _P.lrailwidth),
            point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + math.max(_P.urext, _P.lrext), _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth)
        )
    end
end
