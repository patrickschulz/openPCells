function parameters()
    pcell.add_parameters(
        { "height", 100 },
        --{ "fingers(Number of Fingers)", 4 },
        { "fingerwidth(Finger Width)",     100 },
        { "fingerspace(Finger Spacing)",   100 },
        --{ "fingerheight(Finger Height)",  1000 },
        --{ "fingeroffset(Finger Offset)",   100 },
        --{ "railwidth(Rail Width)",       100 },
        --{ "urailwidth",                  100, follow = "railwidth" },
        --{ "lrailwidth",                  100, follow = "railwidth" },
        --{ "rext(Rail Extension)",       0 },
        { "firstmetal(Start Metal)",    1 },
        { "lastmetal(End Metal)",       2 }
        --{ "alternatingpolarity",     true },
        --{ "flippolarity",           false },
        ----{ "flat",                    true },
        --{ "drawvia",                 true },
        --{ "viaxcontinuous",         false },
        --{ "viaycontinuous",         false },
        --{ "drawfill",               false },
        --{ "fillmetals",                {} },
        --{ "fillwidth",                100 },
        --{ "fillheight",               100 },
        --{ "fillxspace",               100 },
        --{ "fillyspace",               100 },
        --{ "fillxextend",                0 },
        --{ "fillyextend",                0 }
    )
end

function layout(cap, _P)
    local pitch = _P.fingerwidth + _P.fingerspace

    local firstmetal = technology.resolve_metal(_P.firstmetal)
    local lastmetal = technology.resolve_metal(_P.lastmetal)

    geometry.rectanglebltr(cap, generics.metal(firstmetal),
        point.create(-_P.fingerwidth - _P.fingerspace, 0),
        point.create(2 * _P.fingerwidth + _P.fingerspace, _P.height)
    )
    geometry.rectanglebltr(cap, generics.metal(lastmetal),
        point.create(-_P.fingerwidth - _P.fingerspace, 0),
        point.create(2 * _P.fingerwidth + _P.fingerspace, _P.height)
    )
    for m = firstmetal, lastmetal - 1 do
        geometry.viabltr(cap, m, m + 1,
            point.create(-_P.fingerwidth - _P.fingerspace, 0),
            point.create(-_P.fingerspace, _P.height)
        )
        geometry.viabltr(cap, m, m + 1,
            point.create(_P.fingerwidth + _P.fingerspace, 0),
            point.create(2 * _P.fingerwidth + _P.fingerspace, _P.height)
        )
    end
    -- middle line
    for m = firstmetal + 1, lastmetal - 1 do
        geometry.rectanglebltr(cap, generics.metal(m),
            point.create(0, 0),
            point.create(_P.fingerwidth, _P.height)
        )
    end
    for m = firstmetal + 1, lastmetal - 2 do
        geometry.viabarebltr(cap, m, m + 1,
            point.create(0, 0),
            point.create(_P.fingerwidth, _P.height)
        )
    end

    cap:add_area_anchor_bltr("innerfinger",
        point.create(0, 0),
        point.create(_P.fingerwidth, _P.height)
    )
    cap:add_area_anchor_bltr("outerleftfinger",
        point.create(-_P.fingerwidth - _P.fingerspace, 0),
        point.create(-_P.fingerspace, _P.height)
    )
    cap:add_area_anchor_bltr("outerrightfinger",
        point.create(_P.fingerwidth + _P.fingerspace, 0),
        point.create(2 * _P.fingerwidth + _P.fingerspace, _P.height)
    )
end
