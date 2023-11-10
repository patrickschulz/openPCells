function parameters()
    pcell.add_parameters(
        { "fingers(Number of Fingers)", 4 },
        { "fingerwidth(Finger Width)",     100 },
        { "fingerspace(Finger Spacing)",   100 },
        { "fingerheight(Finger Height)",  1000 },
        { "fingeroffset(Finger Offset)",   100 },
        { "railwidth(Rail Width)",       100 },
        { "urailwidth",                  100, follow = "railwidth" },
        { "lrailwidth",                  100, follow = "railwidth" },
        { "rext(Rail Extension)",       0 },
        { "firstmetal(Start Metal)",    1 },
        { "lastmetal(End Metal)",       2 },
        { "alternatingpolarity",     true },
        { "flippolarity",           false },
        --{ "flat",                    true },
        { "drawvia",                 true },
        { "viaxcontinuous",         false },
        { "viaycontinuous",         false },
        { "drawfill",               false },
        { "fillmetals",                {} },
        { "fillwidth",                100 },
        { "fillheight",               100 },
        { "fillxspace",               100 },
        { "fillyspace",               100 },
        { "fillxextend",                0 },
        { "fillyextend",                0 }
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
        geometry.rectanglebltr(
            momcap, generics.metal(m),
            point.create(-_P.rext, 0),
            point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.lrailwidth)
        )
        geometry.rectanglebltr(
            momcap, generics.metal(m),
            point.create(-_P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth),
            point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth + _P.urailwidth)
        )
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
    if _P.drawvia then
        if firstmetal ~= lastmetal then
            -- FIXME: support continuous vias
            viafunc(
                momcap, firstmetal, lastmetal,
                point.create(-_P.rext, 0),
                point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.lrailwidth)
            )
            viafunc(
                momcap, firstmetal, lastmetal,
                point.create(-_P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth),
                point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth + _P.urailwidth)
            )
        end
    end

    if _P.drawfill then
        local xpitch = _P.fillwidth + _P.fillxspace
        local ypitch = _P.fillheight + _P.fillyspace
        local totalwidth = 2 * _P.rext + _P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + 2 * _P.fillxextend
        local totalheight = _P.lrailwidth + _P.urailwidth + _P.fingerheight + 2 * _P.fingeroffset + 2 * _P.fillyextend
        local xrep = (totalwidth + _P.fillxspace) // xpitch
        local yrep = (totalheight + _P.fillyspace) // ypitch
        local xshift = (totalwidth - xrep * _P.fillwidth - (xrep - 1) * _P.fillxspace) / 2
        local yshift = (totalheight - yrep * _P.fillheight - (yrep - 1) * _P.fillyspace) / 2
        for _, m in ipairs(_P.fillmetals) do
            geometry.rectanglearray(
                momcap, generics.metal(m),
                _P.fillwidth, _P.fillheight,
                xshift - _P.rext - _P.fillxextend, yshift - _P.fillyextend,
                xrep, yrep,
                _P.fillwidth + _P.fillxspace,
                _P.fillheight + _P.fillyspace
            )
        end
    end

    momcap:add_area_anchor_bltr("upperrail",
        point.create(-_P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth),
        point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth + _P.urailwidth)
    )
    momcap:add_area_anchor_bltr("lowerrail",
        point.create(-_P.rext, 0),
        point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.lrailwidth)
    )
    momcap:set_alignment_box(
        point.create(-_P.rext, 0),
        point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth + _P.urailwidth),
        point.create(-_P.rext, _P.lrailwidth),
        point.create(_P.fingers * _P.fingerwidth + (_P.fingers - 1) * _P.fingerspace + _P.rext, _P.fingerheight + 2 * _P.fingeroffset + _P.lrailwidth)
    )
end
