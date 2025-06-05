function parameters()
    pcell.add_parameters(
        { "inductormetal", -1 },
        { "tracewidth", 5000 },
        { "tracespace", 5000 },
        { "turns", 1 },
        { "innerdiameter", 50000 },
        { "separation", 10000 },
        { "drawfillexcludes", true },
        { "dlfgroundshield", false },
        { "dlfgroundshieldwidth", 100 },
        { "dlfgroundshieldspace", 100 },
        { "dlfgroundshieldfillouteroffset", 500 },
        { "dlfgroundshieldvmetal", 1 },
        { "dlfgroundshieldhmetal", 2 },
        { "drawmetalfill", true },
        { "fillmetals", { 1, 2 } },
        { "fillmetalwidth", 100 },
        { "fillmetalheight", 100 },
        { "fillxspace", 100 },
        { "fillyspace", 100 },
        { "metalfillouteroffset", 500 },
        { "drawtopmetalfill", true },
        { "topmetalfillouteroffset", 2000 },
        { "topmetalfill", { { layer = -1, width = 2000, space = 6000 } } },
        { "usecircularinductor", false },
        { "circularinductorgrid", 100 },
        { "fillextension", 2000 },
        { "fillasdrawing", true },
        { "breakinductor", false },
        { "placeresonator", true },
        { "drawlvsresistor", false },
        { "fillinneroffset", 5000 },
        { "fillcenteroffset", 10000 },
        { "fillinductorcenter", true },
        { "drawactivefill", true },
        { "activewidth", 500 },
        { "activeheight", 500 },
        { "activexspace", 500 },
        { "activeyspace", 500 },
        { "activefillouteroffset", 500 },
        { "dopingmarkeroffset", 500 },
        { "markeroffset", 1000 },
        { "lvslayers", {} }
    )
end

function layout(resonator, _P)
    local fillfunc = _P.fillasdrawing and generics.metal or generics.metalfill
    local mptfillfunc = _P.fillasdrawing and generics.mptmetal or generics.mptmetalfill

    local outerdiameter = _P.innerdiameter + 2 * (_P.turns - 1) *  (_P.tracewidth + _P.tracespace)

    local boundarywidth = outerdiameter + 2 * _P.fillextension

    local indbaseoptions = {
        topmetal = _P.inductormetal,
        width = _P.tracewidth,
        radius = (_P.innerdiameter - _P.tracewidth) / 2,
        separation = _P.tracespace,
        extsep = _P.separation,
        extension = _P.fillextension,
        outlineextension = _P.fillextension,
        drawlvsresistor = _P.drawlvsresistor,
        breaklines = _P.breakinductor,
        boundaryouterextension = _P.fillinneroffset,
        boundaryinnerextension = _P.fillcenteroffset,
        fillboundary = not _P.fillinductorcenter,
        drawlowsubstratedopingmarker = true,
        dopingmarkerextension = _P.fillextension - _P.dopingmarkeroffset,
        drawinductormarker = true,
        inductormarkerextension = _P.fillextension - _P.markeroffset,
    }

    local inductor
    if not _P.usecircularinductor then
        inductor = pcell.create_layout("passive/inductor/octagonal", "inductor", util.add_options(indbaseoptions, {
            turns = _P.turns,
            drawlvsmarker = true,
            drawinductormarker = true,
        }))
    else
        inductor = pcell.create_layout("passive/inductor/circular", "inductor", util.add_options(indbaseoptions, {
            --turns = _P.turns,
            grid = _P.circularinductorgrid,
        }))
    end
    if _P.placeresonator then
        resonator:merge_into(inductor)
    end
    resonator:inherit_area_anchor(inductor, "leftline")
    resonator:inherit_area_anchor(inductor, "rightline")

    -- place additional LVS recognition layers
    for _, layer in ipairs(_P.lvslayers) do
        geometry.rectanglebltr(resonator, generics.premapped(layer.name, layer.entries),
            inductor:get_area_anchor("outline").bl,
            inductor:get_area_anchor("outline").tr
        )
    end

    --[[
    resonator:add_label("p1", generics.premapped("lvs1_drawing4", {
            gds = { layer = 200, purpose = 214 },
            SKILL = { layer = "LVS1", purpose = "drawing4" },
        }),
        inductor:get_area_anchor("leftline").tl:translate_y(-200)
    )
    resonator:add_label("p2", generics.premapped("lvs1_drawing4", {
            gds = { layer = 200, purpose = 214 },
            SKILL = { layer = "LVS1", purpose = "drawing4" },
        }),
        inductor:get_area_anchor("rightline").tr:translate_y(-200)
    )
    --]]

    local boundary = inductor:get_boundary()
    local xmin = util.polygon_xmin(boundary)
    local ymin = util.polygon_ymin(boundary)
    local xmax = util.polygon_xmax(boundary)
    local ymax = util.polygon_ymax(boundary)

    resonator:set_boundary_rectangular(
        point.create(-boundarywidth / 2, -boundarywidth / 2),
        point.create( boundarywidth / 2,  boundarywidth / 2)
    )
    resonator:add_area_anchor_bltr("boundary",
        point.create(-boundarywidth / 2, -boundarywidth / 2),
        point.create( boundarywidth / 2,  boundarywidth / 2)
    )

    -- dual-layer patterned floating shield
    -- "A High-Q Spiral Inductor with Dual-Layer Patterned Floating Shield in a Class-B VCO Achieving a 190.5-dBc/Hz FoM"
    -- Chee-Cheow Lim et. al.
    -- ISCAS 2016
    if _P.placeresonator and _P.dlfgroundshield then
        local width = _P.dlfgroundshieldwidth
        local space = _P.dlfgroundshieldspace
        local fillwidth = boundarywidth - 2 * _P.dlfgroundshieldfillouteroffset
        local xrep = math.ceil(fillwidth / (width + space))
        local yrep = math.ceil(fillwidth / (width + space))
        for x = 1, xrep do
            local shift = x * (width + space) - (xrep + 1) * (width + space) / 2
            geometry.rectanglebltr(resonator, generics.metal(_P.dlfgroundshieldvmetal),
                point.create(-width / 2 + shift, -fillwidth / 2),
                point.create( width / 2 + shift,  fillwidth / 2)
            )
        end
        for y = 1, yrep do
            local shift = y * (width + space) - (yrep + 1) * (width + space) / 2
            geometry.rectanglebltr(resonator, generics.metal(_P.dlfgroundshieldhmetal),
                point.create(-fillwidth / 2, -width / 2 + shift),
                point.create( fillwidth / 2,  width / 2 + shift)
            )
        end
    end

    -- lower metal fill (covering area beneath the inductor traces)
    if _P.drawmetalfill then
        local shiftsigns = { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } }
        local xshiftamount = (_P.fillmetalwidth + _P.fillxspace) / 2
        local yshiftamount = (_P.fillmetalheight + _P.fillyspace) / 2
        local fillwidth = boundarywidth -2 * _P.markeroffset - 2 * _P.metalfillouteroffset - (_P.fillmetalwidth / 2 + 4) -- FIXME: + 4?
        for i, fillmetal in ipairs(_P.fillmetals) do
            local shiftentry = shiftsigns[((i - 1) % #shiftsigns) + 1]
            local xshift = shiftentry[1] * xshiftamount
            local yshift = shiftentry[2] * yshiftamount
            local fillarea = {
                point.create(-fillwidth / 2, -fillwidth / 2),
                point.create( fillwidth / 2, -fillwidth / 2),
                point.create( fillwidth / 2,  fillwidth / 2),
                point.create(-fillwidth / 2,  fillwidth / 2),
            }
            if _P.placeresonator then
                if technology.has_multiple_patterning(fillmetal) then
                    local num = technology.multiple_patterning_number(fillmetal)
                    for i = 1, num do
                        geometry.rectangle_fill_in_boundary(resonator,
                            mptfillfunc(fillmetal, i),
                            _P.fillmetalwidth, _P.fillmetalheight,
                            num * (_P.fillxspace + _P.fillmetalwidth), 1 * (_P.fillyspace + _P.fillmetalheight),
                            (i - 1) * (_P.fillxspace + _P.fillmetalwidth) + xshift, yshift,
                            fillarea
                        )
                    end
                else
                    geometry.rectangle_fill_in_boundary(resonator,
                        fillfunc(fillmetal),
                        _P.fillmetalwidth, _P.fillmetalheight,
                        _P.fillxspace + _P.fillmetalwidth, _P.fillyspace + _P.fillmetalheight,
                        xshift, yshift,
                        fillarea
                    )
                end
            end
        end
    end

    -- top metal fill (not covering area beneath the inductor traces)
    -- FIXME: for circular inductor: inner fill?
    if _P.drawtopmetalfill then
        local fillwidth = boundarywidth - 2 * _P.topmetalfillouteroffset
        local fillarea = {
            point.create(-fillwidth / 2, -fillwidth / 2),
            point.create( fillwidth / 2, -fillwidth / 2),
            point.create( fillwidth / 2,  fillwidth / 2),
            point.create(-fillwidth / 2,  fillwidth / 2),
        }
        local topmetalfillexcludes = {
            util.rectangle_to_polygon(
                inductor:get_area_anchor("leftline").bl:translate_x(-_P.fillinneroffset),
                inductor:get_area_anchor("rightline").tr:translate_x(_P.fillinneroffset)
            ),
        }
        local lboundaries = inductor:get_layer_boundary(generics.metal(_P.inductormetal))
        for _, lboundary in ipairs(lboundaries) do
            table.insert(topmetalfillexcludes, lboundary)
        end
        for _, entry in ipairs(_P.topmetalfill) do
            if _P.placeresonator then
                geometry.rectangle_fill_in_boundary(resonator,
                    fillfunc(entry.layer),
                    entry.width, entry.width,
                    entry.width + entry.space, entry.width + entry.space,
                    0, 0,
                    fillarea,
                    topmetalfillexcludes
                )
            end
            -- fill excludes
            if _P.drawfillexcludes then
                geometry.rectanglebltr(resonator, generics.metalexclude(entry.layer),
                    point.create(-boundarywidth / 2, -boundarywidth / 2),
                    point.create(boundarywidth / 2, boundarywidth / 2)
                )
            end
        end
    end

    -- active region fill
    if _P.drawactivefill then
        local fillwidth = boundarywidth - 2 * _P.activefillouteroffset
        if _P.placeresonator then
            local activefillcell = object.create("resonator_activefillcell")
            geometry.rectanglebltr(activefillcell, generics.other("activefill"),
                point.create(-_P.activexspace / 2 - _P.activewidth, _P.activeyspace / 2                  ),
                point.create(-_P.activexspace / 2                 , _P.activeyspace / 2 + _P.activeheight)
            )
            geometry.rectanglebltr(activefillcell, generics.other("polyfill"),
                point.create( _P.activexspace / 2                 , _P.activeyspace / 2                  ),
                point.create( _P.activexspace / 2 + _P.activewidth, _P.activeyspace / 2 + _P.activeheight)
            )
            geometry.rectanglebltr(activefillcell, generics.other("activefill"),
                point.create(-_P.activexspace / 2 - _P.activewidth, -_P.activeyspace / 2 - _P.activeheight),
                point.create(-_P.activexspace / 2                 , -_P.activeyspace / 2                  )
            )
            geometry.rectanglebltr(activefillcell, generics.other("polyfill"),
                point.create( _P.activexspace / 2                 , -_P.activeyspace / 2 - _P.activeheight),
                point.create( _P.activexspace / 2 + _P.activewidth, -_P.activeyspace / 2                  )
            )
            geometry.rectanglebltr(activefillcell,
                generics.other("pimplantfill"),
                point.create(-(_P.activewidth + _P.activexspace), -_P.activeheight - _P.activeyspace),
                point.create( (_P.activewidth + _P.activexspace),  0)
            )
            geometry.rectanglebltr(activefillcell,
                generics.other("nimplantfill"),
                point.create(-(_P.activewidth + _P.activexspace), 0),
                point.create( (_P.activewidth + _P.activexspace), _P.activeheight + _P.activeyspace)
            )
            activefillcell:set_alignment_box(
                point.create(-(_P.activewidth + _P.activexspace), -_P.activeheight - _P.activeyspace),
                point.create( (_P.activewidth + _P.activexspace), _P.activeheight + _P.activeyspace)
            )
            local filltargetbl = point.create(
                -fillwidth / 2 + _P.activewidth + _P.activexspace,
                -fillwidth / 2 + _P.activeheight + _P.activeyspace
            )
            local filltargettr = point.create(
                fillwidth / 2 - _P.activewidth - _P.activexspace,
                fillwidth / 2 - _P.activeheight - _P.activeyspace
            )
            placement.place_within_rectangular_boundary(resonator, activefillcell, "activefill", filltargetbl, filltargettr)
        end
        -- fill excludes
        if _P.drawfillexcludes then
            geometry.rectanglebltr(resonator, generics.other("activeexclude"),
                point.create(-boundarywidth / 2, -boundarywidth / 2),
                point.create(boundarywidth / 2, boundarywidth / 2)
            )
            geometry.rectanglebltr(resonator, generics.other("gateexclude"),
                point.create(-boundarywidth / 2, -boundarywidth / 2),
                point.create(boundarywidth / 2, boundarywidth / 2)
            )
        end
    end

    -- fill excludes
    if _P.drawfillexcludes then
        for i, fillmetal in ipairs(_P.fillmetals) do
            geometry.rectanglebltr(resonator, generics.metalexclude(fillmetal),
                point.create(-boundarywidth / 2, -boundarywidth / 2),
                point.create(boundarywidth / 2, boundarywidth / 2)
            )
        end
    end

    -- topmetal fill exclude
    if _P.drawfillexcludes then
        geometry.rectanglebltr(resonator, generics.metalexclude(-1),
            point.create(-boundarywidth / 2, -boundarywidth / 2),
            point.create(boundarywidth / 2, boundarywidth / 2)
        )
    end

    -- alignment box
    resonator:set_alignment_box(
        point.create(-boundarywidth / 2, -boundarywidth / 2),
        point.create( boundarywidth / 2,  boundarywidth / 2)
    )
end
