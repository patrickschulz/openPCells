function parameters()
    pcell.add_parameters(
        { "type",                           "npn", posvals = set("npn", "pnp") },
        { "basewidth",                      100 },
        { "basegap",                        100 },
        { "basemetal",                      1 },
        { "base_contactpos",           "all", posvals = set("all", "leftright", "topbottom") },
        { "emitterwidth",                   500 },
        { "emitterheight",                  500 },
        { "emittercontact_xoffset",         0 },
        { "emittercontact_yoffset",         0 },
        { "emittermetal",                   1 },
        { "emitter_via_height",             0 },
        { "emitter_via_width",             0 },
        { "collectorwidth",                 200 },
        { "collectorgap",                   100 },
        { "collectormetal",                 1 },
        { "collector_contactpos",           "all", posvals = set("all", "leftright", "topbottom") },
        { "collectorimplantextension",      technology.get_dimension("Minimum Implant Extension") },
        { "collectorwellextension",      technology.get_dimension("Minimum Well Extension") },
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
    if _P.type == "npn" then
        geometry.rectanglebltr(bjt, generics.implant("n"),
            point.create(-_P.basegap / 2, -_P.basegap / 2),
            point.create(_P.emitterwidth + _P.basegap / 2, _P.emitterheight + _P.basegap / 2)
        )
        geometry.rectanglebltr(bjt, generics.other("pwell"),
            point.create(-_P.basegap / 2, -_P.basegap / 2),
            point.create(_P.emitterwidth + _P.basegap / 2, _P.emitterheight + _P.basegap / 2)
        )
    else
        geometry.rectanglebltr(bjt, generics.implant("p"),
            point.create(-_P.basegap / 2, -_P.basegap / 2),
            point.create(_P.emitterwidth + _P.basegap / 2, _P.emitterheight + _P.basegap / 2)
        )
        geometry.rectanglebltr(bjt, generics.other("nwell"),
            point.create(-_P.basegap / 2, -_P.basegap / 2),
            point.create(_P.emitterwidth + _P.basegap / 2, _P.emitterheight + _P.basegap / 2)
        )
    end
    geometry.contactbarebltr(bjt, "active",
        point.create(_P.emittercontact_xoffset, _P.emittercontact_yoffset),
        point.create(_P.emitterwidth - _P.emittercontact_xoffset, _P.emitterheight - _P.emittercontact_yoffset)
    )
    geometry.rectanglebltr(bjt, generics.metal(1),
        point.create(0, 0),
        point.create(_P.emitterwidth, _P.emitterheight)
    )
    local emitter_via_height = _P.emitterheight
    if _P.emitter_via_height > 0 then
        emitter_via_height = _P.emitter_via_height
    end
    geometry.viabltr(bjt, 1, _P.emittermetal,
        point.create(0, (_P.emitterheight - emitter_via_height) / 2),
        point.create(_P.emitterwidth, (_P.emitterheight + emitter_via_height) / 2)
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
    geometry.unequal_ring_pts(bjt, generics.metal(1),
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
    if _P.type == "npn" then
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
    else
        geometry.unequal_ring_pts(bjt, generics.implant("n"),
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
        geometry.unequal_ring_pts(bjt, generics.other("nwell"),
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
    end
    if _P.base_contactpos == "all" then
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth,
                -_P.basegap
            ),
            point.create(
                -_P.basegap,
                _P.emitterheight + _P.basegap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                _P.emitterwidth + _P.basegap,
                -_P.basegap
            ),
            point.create(
                _P.emitterwidth + _P.basegap + _P.basewidth,
                _P.emitterheight + _P.basegap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap,
                -_P.basegap - _P.basewidth
            ),
            point.create(
                _P.emitterheight + _P.basegap,
                -_P.basegap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap,
                _P.emitterwidth + _P.basegap
            ),
            point.create(
                _P.emitterheight + _P.basegap,
                _P.emitterwidth + _P.basegap + _P.basewidth
            )
        )
    elseif _P.base_contactpos == "leftright" then
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
    else
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth,
                -_P.basegap - _P.basewidth
            ),
            point.create(
                _P.emitterheight + _P.basegap + _P.basewidth,
                -_P.basegap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth,
                _P.emitterwidth + _P.basegap
            ),
            point.create(
                _P.emitterheight + _P.basegap + _P.basewidth,
                _P.emitterwidth + _P.basegap + _P.basewidth
            )
        )
    end
    --[[
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
    --]]
    bjt:add_area_anchor_bltr("topbase",
        point.create(
            -_P.basegap - _P.basewidth,
            -_P.basegap - _P.basewidth
        ),
        point.create(
            _P.emitterheight + _P.basegap + _P.basewidth,
            -_P.basegap
        )
    )
    bjt:add_area_anchor_bltr("bottombase",
        point.create(
            -_P.basegap - _P.basewidth,
            _P.emitterwidth + _P.basegap
        ),
        point.create(
            _P.emitterheight + _P.basegap + _P.basewidth,
            _P.emitterwidth + _P.basegap + _P.basewidth
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
    if _P.type == "npn" then
        geometry.unequal_ring_pts(bjt, generics.implant("n"),
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.collectorimplantextension,
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.collectorimplantextension
            ),
            point.create(
                _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.collectorimplantextension,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.collectorimplantextension
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
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.collectorwellextension,
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.collectorwellextension
            ),
            point.create(
                _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.collectorwellextension,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.collectorwellextension
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
    else
        geometry.unequal_ring_pts(bjt, generics.implant("p"),
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.collectorimplantextension,
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth - _P.collectorimplantextension
            ),
            point.create(
                _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.collectorimplantextension,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth + _P.collectorimplantextension
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
        geometry.unequal_ring_pts(bjt, generics.other("pwell"),
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
    end
    if _P.collector_contactpos == "all" then
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
                -_P.basegap - _P.basewidth - _P.collectorgap
            ),
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap,
                -_P.basegap - _P.basewidth - _P.collectorgap
            ),
            point.create(
                _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap,
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
            ),
            point.create(
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap,
                -_P.basegap - _P.basewidth - _P.collectorgap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap
            ),
            point.create(
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
            )
        )
    elseif _P.collector_contactpos == "leftright" then
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
    else
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
            ),
            point.create(
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
                -_P.basegap - _P.basewidth - _P.collectorgap
            )
        )
        geometry.contactbarebltr(bjt, "active",
            point.create(
                -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap
            ),
            point.create(
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
                _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
            )
        )
    end
    geometry.unequal_ring_pts(bjt, generics.metal(1),
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
    --[[
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
    --]]
    bjt:add_area_anchor_bltr("topcollector",
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap
        ),
        point.create(
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        )
    )
    bjt:add_area_anchor_bltr("bottomcollector",
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterheight + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap
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
    bjt:add_area_anchor_bltr("rightcollector",
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

    -- alignment box
    bjt:set_alignment_box(
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth,
            -_P.basegap - _P.basewidth - _P.collectorgap - _P.collectorwidth
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth,
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap + _P.collectorwidth
        ),
        point.create(
            -_P.basegap - _P.basewidth - _P.collectorgap,
            -_P.basegap - _P.basewidth - _P.collectorgap
        ),
        point.create(
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap,
            _P.emitterwidth + _P.basegap + _P.basewidth + _P.collectorgap
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
