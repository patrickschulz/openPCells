function parameters()
    pcell.add_parameters(
        { "type",                           "npn", posvals = set("npn", "pnp") },
        { "basewidth",                      100 },
        { "basegap",                        100 },
        { "basemetal",                      1 },
        { "emitterwidth",                   500 },
        { "emitterheight",                  500 },
        { "emittermetal",                   1 },
        { "collectorwidth",                 200 },
        { "collectorgap",                   100 },
        { "collectormetal",                 1 },
        { "soiopen_xextension",             100 },
        { "soiopen_yextension",             100 }
    )
end

function check(_P)
    if _P.basegap % 2 ~= 0 then
        return false, string.format("basegap must be even, got '%d'", _P.basegap)
    end
    if _P.collectorgap % 2 ~= 0 then
        return false, string.format("collectorgap must be even, got '%d'", _P.collectorgap)
    end
    return true
end

function layout(bjt, _P)
    -- emitter
    geometry.rectanglebltr(bjt, generics.other("active"),
        point.create(0, 0),
        point.create(_P.emitterwidth, _P.emitterheight)
    )
    geometry.rectanglebltr(bjt, generics.implant("n"),
        point.create(-_P.basegap / 2, -_P.basegap / 2),
        point.create(_P.emitterwidth + _P.basegap / 2, _P.emitterheight + _P.basegap / 2)
    )
    geometry.rectanglebltr(bjt, generics.other("nwell"),
        point.create(-_P.basegap / 2, -_P.basegap / 2),
        point.create(_P.emitterwidth + _P.basegap / 2, _P.emitterheight + _P.basegap / 2)
    )
    geometry.contactbarebltr(bjt, "active",
        point.create(0, 0),
        point.create(_P.emitterwidth, _P.emitterheight)
    )
    geometry.viabltr(bjt, 1, _P.emittermetal,
        point.create(0, 0),
        point.create(_P.emitterwidth, _P.emitterheight)
    )
    bjt:add_area_anchor_bltr("emitter",
        point.create(0, 0),
        point.create(_P.emitterwidth, _P.emitterheight)
    )

    -- base
    geometry.unequal_ring_pts(bjt, generics.other("active"),
        point.create(
            -_P.basegap - _P.basewidth,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth,
            _P.emitterheight + _P.basegap + _P.basewidth
        ),
        point.create(
            -_P.basegap,
            -_P.basegap
        ),
        point.create(
            _P.emitterwidth + _P.basegap,
            _P.emitterheight + _P.basegap
        )
    )
    geometry.unequal_ring_pts(bjt, generics.implant("p"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap / 2,
            -_P.basegap - _P.basewidth - _P.collectorgap / 2
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap / 2,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap / 2
        ),
        point.create(
            -_P.basegap + _P.basegap / 2,
            -_P.basegap + _P.basegap / 2
        ),
        point.create(
            _P.emitterwidth + _P.basegap - _P.basegap / 2,
            _P.emitterheight + _P.basegap - _P.basegap / 2
        )
    )
    geometry.unequal_ring_pts(bjt, generics.other("pwell"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap / 2,
            -_P.basegap - _P.basewidth - _P.collectorgap / 2
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap / 2,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap / 2
        ),
        point.create(
            -_P.basegap + _P.basegap / 2,
            -_P.basegap + _P.basegap / 2
        ),
        point.create(
            _P.emitterwidth + _P.basegap - _P.basegap / 2,
            _P.emitterheight + _P.basegap - _P.basegap / 2
        )
    )
    geometry.contactbarebltr(bjt, "active",
        point.create(
            -_P.basegap - _P.basewidth,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            -_P.basegap,
            _P.emitterheight + _P.basegap + _P.basewidth
        )
    )
    geometry.contactbarebltr(bjt, "active",
        point.create(
            _P.emitterwidth + _P.basegap,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth,
            _P.emitterheight + _P.basegap + _P.basewidth
        )
    )
    geometry.viabltr(bjt, 1, _P.basemetal,
        point.create(
            -_P.basegap - _P.basewidth,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            -_P.basegap,
            _P.emitterheight + _P.basegap + _P.basewidth
        )
    )
    geometry.viabltr(bjt, 1, _P.basemetal,
        point.create(
            _P.emitterwidth + _P.basegap,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth,
            _P.emitterheight + _P.basegap + _P.basewidth
        )
    )
    bjt:add_area_anchor_bltr("leftbase",
        point.create(
            -_P.basegap - _P.basewidth,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            -_P.basegap,
            _P.emitterheight + _P.basegap + _P.basewidth
        )
    )
    bjt:add_area_anchor_bltr("rightbase",
        point.create(
            _P.emitterwidth + _P.basegap,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth,
            _P.emitterheight + _P.basegap + _P.basewidth
        )
    )

    -- colletor
    geometry.unequal_ring_pts(bjt, generics.other("active"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap,
            -_P.basegap - _P.basewidth - _P.collectorgap
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap
        )
    )
    geometry.unequal_ring_pts(bjt, generics.implant("n"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap + _P.collectorgap / 2,
            -_P.basegap - _P.basewidth - _P.collectorgap + _P.collectorgap / 2
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap - _P.collectorgap / 2,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap - _P.collectorgap / 2
        )
    )
    geometry.unequal_ring_pts(bjt, generics.other("nwell"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap + _P.collectorgap / 2,
            -_P.basegap - _P.basewidth - _P.collectorgap + _P.collectorgap / 2
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap - _P.collectorgap / 2,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap - _P.collectorgap / 2
        )
    )
    geometry.contactbarebltr(bjt, "active",
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )
    geometry.contactbarebltr(bjt, "active",
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )
    geometry.viabltr(bjt, 1, _P.collectormetal,
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )
    geometry.viabltr(bjt, 1, _P.collectormetal,
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )
    bjt:add_area_anchor_bltr("leftcollector",
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )
    bjt:add_area_anchor_bltr("leftcollector",
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )

    -- soiopen
    geometry.rectanglebltr(bjt, generics.other("soiopen"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.soiopen_xextension,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.soiopen_yextension
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.soiopen_xextension,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.soiopen_yextension
        )
    )

    --[[
    -- lvs marker
    geometry.rectanglebltr(bjt, generics.other("bjtlvsmarker"),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.lvsmarker_xextension,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.lvsmarker_yextension
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.lvsmarker_xextension,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.lvsmarker_yextension
        )
    )
    --]]
end
