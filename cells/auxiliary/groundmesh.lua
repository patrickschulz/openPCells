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
        { "drawgrid", true },
        { "drawleft", true },
        { "drawright", true },
        { "drawtop", true },
        { "drawbottom", true },
        { "connecttopmetal", false },
        { "drawtopmetal", false },
        { "metalwidths", { 500, 500, 800, 800, 800, 800, 1000, 2500, 5000, 5000 } },
        { "capspace", { 500, 500, 500, 500, 500, 500, 500 } },
        { "wellextension", 0 },
        { "implantextension", 0 },
        { "soiopenextension", 0 },
        { "drawfillexcludes", true }
    )
end

function layout(mesh, _P)
    -- guard ring
    if _P.drawguardring and aux.find(_P.meshmetals, 1) then
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
            point.create(-_P.cellsize / 2 + _P.metalwidths[1], -_P.cellsize / 2 + _P.metalwidths[1])
        )
        mesh:merge_into(guardring)
    end

    -- mesh metals
    if _P.drawmesh then
        for i = 1, #_P.meshmetals do
            if _P.meshmetals[i] == _P.interconnectmetal then
                geometry.ring(mesh, generics.metal(_P.meshmetals[i]), point.create(0, 0), _P.cellsize + 2 * _P.metalwidths[i], _P.cellsize + 2 * _P.metalwidths[i], 2 * _P.metalwidths[i])
            else
                geometry.ring(mesh, generics.metal(_P.meshmetals[i]), point.create(0, 0), _P.cellsize, _P.cellsize, _P.metalwidths[i])
            end
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local mwidth = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
                    geometry.viabarebltr(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-mwidth / 2 + mwidth / 2 - _P.cellsize / 2, -_P.cellsize / 2),
                        point.create( mwidth / 2 + mwidth / 2 - _P.cellsize / 2,  _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                    geometry.viabarebltr(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-mwidth / 2 - mwidth / 2 + _P.cellsize / 2, -_P.cellsize / 2),
                        point.create( mwidth / 2 - mwidth / 2 + _P.cellsize / 2,  _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                    geometry.viabarebltr(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-_P.cellsize / 2, -mwidth / 2 + mwidth / 2 - _P.cellsize / 2),
                        point.create( _P.cellsize / 2,  mwidth / 2 + mwidth / 2 - _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                    geometry.viabarebltr(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-_P.cellsize / 2, -mwidth / 2 - mwidth / 2 + _P.cellsize / 2),
                        point.create( _P.cellsize / 2,  mwidth / 2 - mwidth / 2 + _P.cellsize / 2),
                        { equal_pitch = true }
                    )
                end
            end
            -- fill exclude
            if _P.drawfillexcludes then
                geometry.rectanglebltr(mesh, generics.metalexclude(_P.meshmetals[i]),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
        end
    end

    -- grid metals
    local leftright = true
    if _P.drawgrid then
        for i = 1, #_P.gridmetals do
            local metal = _P.gridmetals[i]
            local width = _P.metalwidths[i + #_P.meshmetals]
            if leftright then
                local left = _P.drawleft and -_P.cellsize / 2 - width / 2 or -width / 2
                local right = _P.drawright and _P.cellsize / 2 + width / 2 or width / 2
                geometry.rectanglebltr(mesh, generics.metal(metal),
                    point.create(left,  -_P.cellsize / 2 - width / 2 ),
                    point.create(right, -_P.cellsize / 2 + width / 2 )
                )
                geometry.rectanglebltr(mesh, generics.metal(metal),
                    point.create(left, -width / 2),
                    point.create(right, width / 2)
                )
                geometry.rectanglebltr(mesh, generics.metal(metal),
                    point.create(left,  _P.cellsize / 2 - width / 2),
                    point.create(right, _P.cellsize / 2 + width / 2)
                )
            else
                local bottom = _P.drawbottom and -_P.cellsize / 2 - width / 2 or -width / 2
                local top = _P.drawtop and _P.cellsize / 2 + width / 2 or width / 2
                geometry.rectanglebltr(mesh, generics.metal(metal),
                    point.create(-_P.cellsize / 2 - width / 2, bottom),
                    point.create(-_P.cellsize / 2 + width / 2, top)
                )
                geometry.rectanglebltr(mesh, generics.metal(metal),
                    point.create(-width / 2, bottom),
                    point.create( width / 2, top)
                )
                geometry.rectanglebltr(mesh, generics.metal(metal),
                    point.create(_P.cellsize / 2 - width / 2, bottom),
                    point.create(_P.cellsize / 2 + width / 2, top)
                )
            end
            if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
                local mwidth = math.min(_P.metalwidths[i + #_P.meshmetals], _P.metalwidths[i + 1 + #_P.meshmetals])
                geometry.viabarebltr(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create(-mwidth / 2, -mwidth / 2),
                    point.create( mwidth / 2,  mwidth / 2)
                )
                geometry.viabarebltr(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create(-_P.cellsize / 2 - mwidth / 2, -_P.cellsize / 2 - mwidth / 2),
                    point.create(-_P.cellsize / 2 + mwidth / 2, -_P.cellsize / 2 + mwidth / 2)
                )
                geometry.viabarebltr(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create( _P.cellsize / 2 - mwidth / 2,  _P.cellsize / 2 - mwidth / 2),
                    point.create( _P.cellsize / 2 + mwidth / 2,  _P.cellsize / 2 + mwidth / 2)
                )
                geometry.viabarebltr(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create(-_P.cellsize / 2 - mwidth / 2,  _P.cellsize / 2 - mwidth / 2),
                    point.create(-_P.cellsize / 2 + mwidth / 2,  _P.cellsize / 2 + mwidth / 2)
                )
                geometry.viabarebltr(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create( _P.cellsize / 2 - mwidth / 2, -_P.cellsize / 2 - mwidth / 2),
                    point.create( _P.cellsize / 2 + mwidth / 2, -_P.cellsize / 2 + mwidth / 2)
                )
            end
            -- fill exclude
            if _P.drawfillexcludes then
                geometry.rectanglebltr(mesh, generics.metalexclude(_P.gridmetals[i]),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
            leftright = not leftright
        end
        -- connect to top metal
        --if _P.connecttopmetal then
        --    geometry.viabarebltr(mesh, _P.gridmetals[#_P.gridmetals], _P.gridmetals[#_P.gridmetals] + 1,
        --        point.create(-_P.metalwidths[#_P.metalwidths] / 2, -_P.metalwidths[#_P.metalwidths] / 2),
        --        point.create( _P.metalwidths[#_P.metalwidths] / 2,  _P.metalwidths[#_P.metalwidths] / 2)
        --    )
        --end
        if _P.drawtopmetal then
            geometry.rectanglebltr(mesh, generics.metal(-1),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
        end
    end

    local foffset = 100
    local fingerwidth = 50
    local fingerspace = 50
    local flippolarity = true
    if _P.drawmoscap then
        -- fill excludes
        if _P.drawfillexcludes then
            geometry.rectanglebltr(mesh, generics.other("activeexclude"),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
            geometry.rectanglebltr(mesh, generics.other("gateexclude"),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
        end
        local capfingers = 2 * math.floor((_P.cellsize - 2 * _P.metalwidths[1] - 2 * _P.moscapxspace) / (2 * (_P.moscapgatelength + _P.moscapgatespace)))
        local moscap = pcell.create_layout("basic/mosfet", "moscap", {
            fingers = capfingers,
            fingerwidth = (_P.cellsize - 3 * _P.metalwidths[1]) / 2 - 2 * _P.moscapyspace,
            gatelength = _P.moscapgatelength,
            gatespace = _P.moscapgatespace,
            drawbotgate = true,
            botgatewidth = _P.metalwidths[1],
            botgatespace = _P.moscapyspace,
            sdwidth = 100,
            sourcemetal = 2,
            drainmetal = 2,
            connectsource = true,
            connectsourceinverse = _P.moscapchanneltype == "nmos",
            connectdraininverse = _P.moscapchanneltype == "pmos",
            connectdrain = true,
            connectsourcewidth = _P.metalwidths[1],
            connectdrainwidth = _P.metalwidths[1],
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
            point.create(0, -_P.metalwidths[1] / 2))
        mesh:merge_into(moscap)
        moscap:mirror_at_xaxis() -- FIXME: depends on absolute placement
        mesh:merge_into(moscap)
    end

    -- metal capacitor
    if _P.drawmesh then
        for i = 1, #_P.meshmetals do
            if _P.meshmetals[i] == _P.interconnectmetal then
                break
            end
            local nfingers = 2 * math.floor((_P.cellsize - 2 * _P.metalwidths[i] - 2 * _P.capspace[i]) / (2 * (fingerwidth + fingerspace)))
            local capwidth = nfingers * fingerwidth + (nfingers - 1) * fingerspace
            if not (_P.meshmetals[i] == 1 or _P.meshmetals[i] == 2) then
                local topcap = pcell.create_layout("passive/capacitor/mom", "topcap", {
                    firstmetal = _P.meshmetals[i], lastmetal = _P.meshmetals[i],
                    fingers = nfingers,
                    fingerwidth = fingerwidth,
                    fingerspace = fingerspace,
                    fingeroffset = foffset,
                    railwidth = _P.metalwidths[i],
                    fingerheight = _P.cellsize / 2 - _P.metalwidths[i] / 2 - _P.metalwidths[i] - 2 * foffset,
                    alternatingpolarity = alternatingpolarity,
                    flippolarity = flippolarity,
                })
                flippolarity = not flippolarity
                local botcap = topcap:copy()
                topcap:move_point(topcap:get_area_anchor("lowerrail").bl,
                    point.create(-capwidth / 2, -_P.metalwidths[i] / 2))
                botcap:flipy()
                botcap:move_point(botcap:get_area_anchor("lowerrail").tl,
                    point.create(-capwidth / 2,  _P.metalwidths[i] / 2))
                mesh:merge_into(topcap)
                mesh:merge_into(botcap)
            end
            -- inner rail via
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] == _P.interconnectmetal then
                    local viaheight = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
                    geometry.viabltr(mesh, _P.interconnectmetal - 1, _P.interconnectmetal,
                        point.create(-_P.metalwidths[#_P.meshmetals + 2] / 2, -viaheight / 2),
                        point.create( _P.metalwidths[#_P.meshmetals + 2] / 2,  viaheight / 2)
                    )
                elseif _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local nfingersnext = 2 * math.floor((_P.cellsize - 2 * _P.metalwidths[i + 1] - 2 * _P.capspace[i]) / (2 * (fingerwidth + fingerspace)))
                    local capwidthnext = nfingersnext * fingerwidth + (nfingersnext - 1) * fingerspace
                    local viawidth = math.min(capwidth, capwidthnext)
                    local viaheight = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
                    geometry.viabltr(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        point.create(-viawidth / 2, -viaheight / 2),
                        point.create( viawidth / 2,  viaheight / 2)
                    )
                end
            end
        end
        -- connect cap to grid
        if _P.drawgrid then
            if aux.any_of(_P.interconnectmetal, _P.meshmetals) then
                geometry.rectanglebltr(mesh, generics.metal(_P.interconnectmetal),
                    point.create(-_P.metalwidths[#_P.meshmetals + 2] / 2, -_P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create( _P.metalwidths[#_P.meshmetals + 2] / 2,  _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
                geometry.viabarebltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.metalwidths[#_P.meshmetals + 2] / 2, -_P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create( _P.metalwidths[#_P.meshmetals + 2] / 2,  _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
            end
        end
        -- connect ground to grid
        if _P.drawgrid then
            if aux.any_of(_P.interconnectmetal, _P.meshmetals) then
                geometry.viabarebltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2, -_P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create(-_P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2, -_P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
                geometry.viabarebltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2,  _P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create(-_P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2,  _P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
                geometry.viabarebltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create( _P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2, -_P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create( _P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2, -_P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
                geometry.viabarebltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create( _P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2,  _P.cellsize / 2 - _P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create( _P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2,  _P.cellsize / 2 + _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
            end
        end
    end

    mesh:add_area_anchor_bltr("outerboundary",
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )

    mesh:set_alignment_box(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )

    mesh:set_boundary_rectangular(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )
end
