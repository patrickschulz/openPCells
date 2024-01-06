function parameters()
    pcell.add_parameters(
        { "cellsize", 10000 },
        { "meshmetals", { 1, 2, 3, 4, 5, 6, 7, 8 } },
        { "gridmetals", { 9, 10 } },
        { "interconnectmetal", 8 },
        { "guardringwidth", 500 },
        { "drawguardring", true },
        { "drawmoscap", true },
        { "moscapgatelength", 250 },
        { "moscapgatespace", 250 },
        { "moscapxspace", 250 },
        { "moscapyspace", 250 },
        { "moscapvthtype", 1 },
        { "moscapchanneltype", "nmos" },
        { "moscapflippedwell", false },
        { "moscapoxidetype", 1 },
        { "moscapgatemarker", 1 },
        { "moscapmosfetmarker", 1 },
        { "extendmoscapmarkerx", 0 },
        { "extendmoscapmarkery", 0 },
        { "drawmesh", true },
        { "fillmesh", false },
        { "drawgrid", true },
        { "drawmeshtogridvias", true, follow = "drawgrid" },
        { "drawleft", true },
        { "drawright", true },
        { "drawtop", true },
        { "drawbottom", true },
        { "restrictvss", false },
        { "drawtopmetal", false },
        { "topmetaldensity", 50 },
        { "connecttopmetal", false, follow = "drawtopmetal" },
        { "meshmetalwidths", { 500, 500, 800, 800, 800, 800, 1000, 1250, } },
        { "gridmetalwidths", { { vss = 2400, vdd = 3600 }, { vss = 2400, vdd = 3600 } } },
        { "capspace", { 500, 500, 500, 500, 500, 500, 500 } },
        { "wellextension", 0 },
        { "implantextension", 0 },
        { "soiopenextension", 0 },
        { "drawfillexcludes", true }
    )
end

function layout(decap, _P)
    -- guard ring
    if _P.drawguardring and util.find(_P.meshmetals, 1) then
        local guardring = pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = "p",
            holewidth = _P.cellsize - 2 * _P.guardringwidth,
            holeheight = _P.cellsize - 2 * _P.guardringwidth,
            ringwidth = _P.guardringwidth,
            fit = true,
            drawmetal = false,
            wellextension = _P.wellextension,
            implantextension = _P.implantextension,
            soiopenextension = _P.soiopenextension,
        })
        guardring:move_point(
            guardring:get_area_anchor("innerboundary").bl,
            point.create(-_P.cellsize / 2 + _P.meshmetalwidths[1], -_P.cellsize / 2 + _P.meshmetalwidths[1])
        )
        decap:merge_into(guardring)
    end

    -- decap metals
    if _P.drawmesh and not _P.fillmesh then
        for i = 1, #_P.meshmetals do
            if _P.meshmetals[i] == _P.interconnectmetal then
                geometry.ring(decap, generics.metal(_P.meshmetals[i]), point.create(0, 0), _P.cellsize + 2 * _P.meshmetalwidths[i], _P.cellsize + 2 * _P.meshmetalwidths[i], 2 * _P.meshmetalwidths[i])
            else
                geometry.ring(decap, generics.metal(_P.meshmetals[i]), point.create(0, 0), _P.cellsize, _P.cellsize, _P.meshmetalwidths[i])
            end
            if i < #_P.meshmetals then -- vias between layers of mesh
                if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local mwidth = math.min(_P.meshmetalwidths[i], _P.meshmetalwidths[i + 1])
                    geometry.viabarebltr(decap, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-mwidth / 2 + mwidth / 2 - _P.cellsize / 2, -_P.cellsize / 2),
                        point.create( mwidth / 2 + mwidth / 2 - _P.cellsize / 2,  _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                    geometry.viabarebltr(decap, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-mwidth / 2 - mwidth / 2 + _P.cellsize / 2, -_P.cellsize / 2),
                        point.create( mwidth / 2 - mwidth / 2 + _P.cellsize / 2,  _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                    geometry.viabarebltr(decap, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-_P.cellsize / 2, -mwidth / 2 + mwidth / 2 - _P.cellsize / 2),
                        point.create( _P.cellsize / 2,  mwidth / 2 + mwidth / 2 - _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                    geometry.viabarebltr(decap, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-_P.cellsize / 2, -mwidth / 2 - mwidth / 2 + _P.cellsize / 2),
                        point.create( _P.cellsize / 2,  mwidth / 2 - mwidth / 2 + _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                end
            end
            -- fill exclude
            if _P.drawfillexcludes then
                geometry.rectanglebltr(decap, generics.metalexclude(_P.meshmetals[i]),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
        end
    end

    if _P.fillmesh then
        for i, m in ipairs(_P.meshmetals) do
            if m == _P.interconnectmetal then
                geometry.ring(decap,
                    generics.metal(_P.meshmetals[i]),
                    point.create(0, 0),
                    _P.cellsize + 2 * _P.meshmetalwidths[i], _P.cellsize + 2 * _P.meshmetalwidths[i],
                    2 * _P.meshmetalwidths[i]
                )
                geometry.rectanglebltr(decap, generics.metal(_P.meshmetals[i]),
                    point.create(-_P.cellsize / 2 + _P.meshmetalwidths[i], -_P.meshmetalwidths[i] / 2),
                    point.create( _P.cellsize / 2 - _P.meshmetalwidths[i],  _P.meshmetalwidths[i] / 2)
                )
                geometry.rectanglebltr(decap, generics.metal(_P.meshmetals[i]),
                    point.create(-_P.meshmetalwidths[i] / 2, -_P.cellsize / 2 + _P.meshmetalwidths[i]),
                    point.create( _P.meshmetalwidths[i] / 2,  _P.cellsize / 2 - _P.meshmetalwidths[i])
                )
            else
                geometry.slotted_rectangle(decap, generics.metal(m),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2),
                    _P.meshmetalwidths[i], _P.meshmetalwidths[i],
                    _P.meshmetalwidths[i], _P.meshmetalwidths[i],
                    _P.meshmetalwidths[i] / 2, _P.meshmetalwidths[i] / 2
                )
            end
        end
    end

    -- grid metals
    local leftright = true
    if _P.drawgrid then
        for i = 1, #_P.gridmetals do
            local metal = _P.gridmetals[i]
            local vsswidth = _P.gridmetalwidths[i].vss
            local vddwidth = _P.gridmetalwidths[i].vdd
            if leftright then
                local vddleft = -_P.cellsize / 2 - vsswidth / 2
                local vddright = _P.cellsize / 2 + vsswidth / 2
                if not _P.drawleft then
                    vddleft = -vddwidth / 2
                end
                if not _P.drawright then
                    vddright = vddwidth / 2
                end
                local vssleft = -_P.cellsize / 2 - vsswidth / 2
                local vssleft = -_P.cellsize / 2 - vsswidth / 2
                local vssright = _P.cellsize / 2 + vsswidth / 2
                local vssright = _P.cellsize / 2 + vsswidth / 2
                if _P.restrictvss then
                    if not _P.drawleft then
                        vssleft = -vsswidth / 2
                    end
                    if not _P.drawright then
                        vssright = vsswidth / 2
                    end
                end
                if not _P.restrictvss or _P.drawbottom then
                    geometry.rectanglebltr(decap, generics.metal(metal),
                        point.create(vssleft,  -_P.cellsize / 2 - vsswidth / 2 ),
                        point.create(vssright, -_P.cellsize / 2 + vsswidth / 2 )
                    )
                end
                geometry.rectanglebltr(decap, generics.metal(metal),
                    point.create(vddleft, -vddwidth / 2),
                    point.create(vddright, vddwidth / 2)
                )
                if not _P.restrictvss or _P.drawtop then
                    geometry.rectanglebltr(decap, generics.metal(metal),
                        point.create(vssleft,  _P.cellsize / 2 - vsswidth / 2),
                        point.create(vssright, _P.cellsize / 2 + vsswidth / 2)
                    )
                end
            else
                local vddbottom = -_P.cellsize / 2 - vsswidth / 2
                local vddtop = _P.cellsize / 2 + vsswidth / 2
                if not _P.drawbottom then
                    vddbottom = -vddwidth / 2
                end
                if not _P.drawtop then
                    vddtop = vddwidth / 2
                end
                local vssbottom = -_P.cellsize / 2 - vsswidth / 2
                local vsstop = _P.cellsize / 2 + vsswidth / 2
                if _P.restrictvss then
                    if not _P.drawbottom then
                        vssbottom = -vsswidth / 2
                    end
                    if not _P.drawtop then
                        vsstop = vsswidth / 2
                    end
                end
                if not _P.restrictvss or not _P.drawleft then
                    geometry.rectanglebltr(decap, generics.metal(metal),
                        point.create(-_P.cellsize / 2 - vsswidth / 2, vssbottom),
                        point.create(-_P.cellsize / 2 + vsswidth / 2, vsstop)
                    )
                end
                geometry.rectanglebltr(decap, generics.metal(metal),
                    point.create(-vddwidth / 2, vddbottom),
                    point.create( vddwidth / 2, vddtop)
                )
                if not _P.restrictvss or not _P.drawright then
                    geometry.rectanglebltr(decap, generics.metal(metal),
                        point.create(_P.cellsize / 2 - vsswidth / 2, vssbottom),
                        point.create(_P.cellsize / 2 + vsswidth / 2, vsstop)
                    )
                end
            end
            if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
                local mwidth = math.min(_P.gridmetalwidths[i].vss, _P.gridmetalwidths[i + 1].vss)
                geometry.viabarebltr(decap, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create(-mwidth / 2, -mwidth / 2),
                    point.create( mwidth / 2,  mwidth / 2)
                )
                if not _P.restrictvss or (_P.drawleft and _P.drawbottom) then
                    geometry.viabarebltr(decap, _P.gridmetals[i], _P.gridmetals[i] + 1,
                        point.create(-_P.cellsize / 2 - mwidth / 2, -_P.cellsize / 2 - mwidth / 2),
                        point.create(-_P.cellsize / 2 + mwidth / 2, -_P.cellsize / 2 + mwidth / 2)
                    )
                end
                if not _P.restrictvss or (_P.drawright and _P.drawtop) then
                    geometry.viabarebltr(decap, _P.gridmetals[i], _P.gridmetals[i] + 1,
                        point.create( _P.cellsize / 2 - mwidth / 2,  _P.cellsize / 2 - mwidth / 2),
                        point.create( _P.cellsize / 2 + mwidth / 2,  _P.cellsize / 2 + mwidth / 2)
                    )
                end
                if not _P.restrictvss or (_P.drawleft and _P.drawtop) then
                    geometry.viabarebltr(decap, _P.gridmetals[i], _P.gridmetals[i] + 1,
                        point.create(-_P.cellsize / 2 - mwidth / 2,  _P.cellsize / 2 - mwidth / 2),
                        point.create(-_P.cellsize / 2 + mwidth / 2,  _P.cellsize / 2 + mwidth / 2)
                    )
                end
                if not _P.restrictvss or (_P.drawright and _P.drawbottom) then
                    geometry.viabarebltr(decap, _P.gridmetals[i], _P.gridmetals[i] + 1,
                        point.create( _P.cellsize / 2 - mwidth / 2, -_P.cellsize / 2 - mwidth / 2),
                        point.create( _P.cellsize / 2 + mwidth / 2, -_P.cellsize / 2 + mwidth / 2)
                    )
                end
            end
            -- fill exclude
            if _P.drawfillexcludes then
                geometry.rectanglebltr(decap, generics.metalexclude(_P.gridmetals[i]),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
            leftright = not leftright
        end
        -- connect to top metal
        if _P.connecttopmetal then
            geometry.viabarebltr(decap, _P.gridmetals[#_P.gridmetals], _P.gridmetals[#_P.gridmetals] + 1,
                point.create(-_P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2, -_P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2),
                point.create( _P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2,  _P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2)
            )
        end
        if _P.drawtopmetal then
            if _P.topmetaldensity == 100 then
                local left = -_P.cellsize / 2
                local right = _P.cellsize / 2
                local bottom = -_P.cellsize / 2
                local top = _P.cellsize / 2
                if not _P.drawleft then
                    left = -_P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2
                end
                if not _P.drawright then
                    right = _P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2
                end
                if not _P.drawbottom then
                    bottom = -_P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2
                end
                if not _P.drawtop then
                    top = _P.gridmetalwidths[#_P.gridmetalwidths].vdd / 2
                end
                geometry.rectanglebltr(decap, generics.metal(-1),
                    point.create(left, bottom),
                    point.create(right, top)
                )
            else
                local width = math.floor(math.sqrt(_P.topmetaldensity / 100) * _P.cellsize / 2 / 2) * 2
                local pts = {}
                if _P.drawleft then
                    table.insert(pts, point.create(-_P.cellsize / 2, width / 2))
                    table.insert(pts, point.create(-_P.cellsize / 2, -width / 2))
                end
                table.insert(pts, point.create(-width / 2, -width / 2))
                if _P.drawbottom then
                    table.insert(pts, point.create(-width / 2, -_P.cellsize / 2))
                    table.insert(pts, point.create( width / 2, -_P.cellsize / 2))
                end
                table.insert(pts, point.create( width / 2, -width / 2))
                if _P.drawright then
                    table.insert(pts, point.create( _P.cellsize / 2, -width / 2))
                    table.insert(pts, point.create( _P.cellsize / 2,  width / 2))
                end
                table.insert(pts, point.create( width / 2, width / 2))
                if _P.drawtop then
                    table.insert(pts, point.create( width / 2, _P.cellsize / 2))
                    table.insert(pts, point.create(-width / 2, _P.cellsize / 2))
                end
                table.insert(pts, point.create(-width / 2, width / 2))
                geometry.polygon(decap, generics.metal(-1), pts)
            end
            if _P.drawfillexcludes then
                geometry.rectanglebltr(decap, generics.metalexclude(-1),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
        end
    end

    local foffset = 100
    local fingerwidth = 50
    local fingerspace = 50
    local flippolarity = true
    if _P.drawmoscap then
        -- fill excludes
        if _P.drawfillexcludes then
            geometry.rectanglebltr(decap, generics.other("activeexclude"),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
            geometry.rectanglebltr(decap, generics.other("gateexclude"),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
        end
        local capfingers = 2 * math.floor((_P.cellsize - 2 * _P.meshmetalwidths[1] - 2 * _P.moscapxspace) / (2 * (_P.moscapgatelength + _P.moscapgatespace)))
        local moscap = pcell.create_layout("basic/mosfet", "moscap", {
            fingers = capfingers,
            fingerwidth = (_P.cellsize - 3 * _P.meshmetalwidths[1]) / 2 - 2 * _P.moscapyspace,
            gatelength = _P.moscapgatelength,
            gatespace = _P.moscapgatespace,
            drawbotgate = true,
            botgatewidth = _P.meshmetalwidths[1],
            botgatespace = _P.moscapyspace,
            sdwidth = 100,
            sourcemetal = 2,
            drainmetal = 2,
            connectsource = true,
            connectsourceinverse = _P.moscapchanneltype == "nmos",
            connectdraininverse = _P.moscapchanneltype == "pmos",
            connectdrain = true,
            connectsourcewidth = _P.meshmetalwidths[1],
            connectdrainwidth = _P.meshmetalwidths[1],
            connectsourcespace = _P.moscapyspace,
            connectdrainspace = _P.moscapyspace,
            channeltype = _P.moscapchanneltype,
            flippedwell = _P.moscapflippedwell,
            vthtype = _P.moscapvthtype,
            oxidetype = _P.moscapoxidetype,
            gatemarker = _P.moscapgatemarker,
            mosfetmarker = _P.moscapmosfetmarker,
            extendalltop = _P.extendmoscapmarkery,
            extendallbottom = _P.extendmoscapmarkery,
            extendallleft = _P.extendmoscapmarkerx,
            extendallright = _P.extendmoscapmarkerx,
        })
        moscap:move_point(
            point.combine(
                moscap:get_area_anchor("botgatestrap").bl,
                moscap:get_area_anchor("botgatestrap").br
            ),
            point.create(0, -_P.meshmetalwidths[1] / 2))
        decap:merge_into(moscap)
        moscap:mirror_at_xaxis() -- FIXME: depends on absolute placement
        decap:merge_into(moscap)
    end

    -- metal capacitor
    if _P.drawmesh and not _P.fillmesh then
        for i = 1, #_P.meshmetals do
            if _P.meshmetals[i] == _P.interconnectmetal then
                break
            end
            local nfingers = 2 * math.floor((_P.cellsize - 2 * _P.meshmetalwidths[i] - 2 * _P.capspace[i]) / (2 * (fingerwidth + fingerspace)))
            local capwidth = nfingers * fingerwidth + (nfingers - 1) * fingerspace
            if not ((_P.meshmetals[i] == 1 or _P.meshmetals[i] == 2) and _P.drawmoscap) then
                local topcap = pcell.create_layout("passive/capacitor/mom", "topcap", {
                    firstmetal = _P.meshmetals[i], lastmetal = _P.meshmetals[i],
                    fingers = nfingers,
                    fingerwidth = fingerwidth,
                    fingerspace = fingerspace,
                    fingeroffset = foffset,
                    railwidth = _P.meshmetalwidths[i],
                    fingerheight = _P.cellsize / 2 - _P.meshmetalwidths[i] / 2 - _P.meshmetalwidths[i] - 2 * foffset,
                    alternatingpolarity = alternatingpolarity,
                    flippolarity = flippolarity,
                })
                flippolarity = not flippolarity
                local botcap = topcap:copy()
                topcap:move_point(topcap:get_area_anchor("lowerrail").bl,
                    point.create(-capwidth / 2, -_P.meshmetalwidths[i] / 2))
                botcap:flipy()
                botcap:move_point(botcap:get_area_anchor("lowerrail").tl,
                    point.create(-capwidth / 2,  _P.meshmetalwidths[i] / 2))
                decap:merge_into(topcap)
                decap:merge_into(botcap)
            end
            -- inner rail via
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] == _P.interconnectmetal then
                    local viaheight = math.min(_P.meshmetalwidths[i], _P.meshmetalwidths[i + 1])
                    geometry.viabltr(decap, _P.interconnectmetal - 1, _P.interconnectmetal,
                        point.create(-_P.gridmetalwidths[1].vss / 2, -viaheight / 2),
                        point.create( _P.gridmetalwidths[1].vss / 2,  viaheight / 2)
                    )
                elseif _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local nfingersnext = 2 * math.floor((_P.cellsize - 2 * _P.meshmetalwidths[i + 1] - 2 * _P.capspace[i]) / (2 * (fingerwidth + fingerspace)))
                    local capwidthnext = nfingersnext * fingerwidth + (nfingersnext - 1) * fingerspace
                    local viawidth = math.min(capwidth, capwidthnext)
                    local viaheight = math.min(_P.meshmetalwidths[i], _P.meshmetalwidths[i + 1])
                    geometry.viabltr(decap, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-viawidth / 2, -viaheight / 2),
                        point.create( viawidth / 2,  viaheight / 2)
                    )
                end
            end
        end
        -- connect cap to grid
        if _P.drawmeshtogridvias then
            if util.any_of(_P.interconnectmetal, _P.meshmetals) then
                geometry.rectanglebltr(decap, generics.metal(_P.interconnectmetal),
                    point.create(-_P.gridmetalwidths[1].vss / 2, -_P.gridmetalwidths[1].vss / 2),
                    point.create( _P.gridmetalwidths[1].vss / 2,  _P.gridmetalwidths[1].vss / 2)
                )
                geometry.viabarebltr(decap, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.gridmetalwidths[1].vss / 2, -_P.gridmetalwidths[1].vss / 2),
                    point.create( _P.gridmetalwidths[1].vss / 2,  _P.gridmetalwidths[1].vss / 2)
                )
            end
        end
    end

    -- connect ground to grid
    if _P.drawmesh and _P.drawmeshtogridvias then
        if util.any_of(_P.interconnectmetal, _P.meshmetals) then
            if not _P.restrictvss or (_P.drawleft and _P.drawbottom) then
                geometry.viabarebltr(decap, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2, -_P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2),
                    point.create(-_P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2, -_P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2)
                )
            end
            if not _P.restrictvss or (_P.drawleft and _P.drawtop) then
                geometry.viabarebltr(decap, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2,  _P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2),
                    point.create(-_P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2,  _P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2)
                )
            end
            if not _P.restrictvss or (_P.drawright and _P.drawbottom) then
                geometry.viabarebltr(decap, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create( _P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2, -_P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2),
                    point.create( _P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2, -_P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2)
                )
            end
            if _P.restrictvss or (_P.drawright and _P.drawtop) then
                geometry.viabarebltr(decap, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create( _P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2,  _P.cellsize / 2 - _P.gridmetalwidths[1].vss / 2),
                    point.create( _P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2,  _P.cellsize / 2 + _P.gridmetalwidths[1].vss / 2)
                )
            end
        end
    end

    decap:add_area_anchor_bltr("outerboundary",
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )

    decap:set_alignment_box(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )

    decap:set_boundary_rectangular(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )
end
