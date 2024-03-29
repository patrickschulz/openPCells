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
        { "needmultiplepatterning", { true, true, false, false, false, false, false, false } },
        { "wellextension", 0 },
        { "implantextension", 0 },
        { "soiopenextension", 0 },
        { "drawfillexcludes", true },
        { "drawasplane", false }
    )
end

function layout(mesh, _P)
    if _P.drawasplane then -- FIXME: currently only support for ground cells, not cap cells
        -- FIXME: more checks needed (for instance 'drawmesh')
        -- mesh metals
        for i = 1, #_P.meshmetals do
            geometry.rectanglebltr(mesh, generics.metal(_P.meshmetals[i]),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    geometry.rectanglebltr(mesh, generics.viacut(_P.meshmetals[i], _P.meshmetals[i] + 1),
                        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                        point.create( _P.cellsize / 2,  _P.cellsize / 2)
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
        -- grid metals
        for i = 1, #_P.gridmetals do
            geometry.rectanglebltr(mesh, generics.metal(_P.gridmetals[i]),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
            if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
                geometry.rectanglebltr(mesh, generics.viacut(_P.gridmetals[i], _P.gridmetals[i] + 1),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
            -- fill exclude
            if _P.drawfillexcludes then
                geometry.rectanglebltr(mesh, generics.metalexclude(_P.gridmetals[i]),
                    point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                    point.create( _P.cellsize / 2,  _P.cellsize / 2)
                )
            end
        end
        geometry.rectanglebltr(mesh, generics.viacut(_P.interconnectmetal, _P.interconnectmetal + 1),
            point.create(-_P.cellsize / 2, -_P.cellsize / 2),
            point.create( _P.cellsize / 2,  _P.cellsize / 2)
        )
    else -- if _P.drawasplane
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
                geometry.ring(mesh, generics.metal(_P.meshmetals[i]), point.create(0, 0), _P.cellsize, _P.cellsize, _P.metalwidths[i])
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
                    local left = _P.drawleft and -width or -width / 2
                    local right = _P.drawright and width or width / 2
                    geometry.rectanglebltr(mesh, generics.metal(metal),
                        point.create(left, -width / 2),
                        point.create(right, width / 2)
                    )
                else
                    local bottom = _P.drawbottom and -width or -width / 2
                    local top = _P.drawtop and width or width / 2
                    geometry.rectanglebltr(mesh, generics.metal(metal),
                        point.create(-width / 2, bottom),
                        point.create( width / 2, top)
                    )
                end
                if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
                    local mwidth = math.min(_P.metalwidths[i + #_P.meshmetals], _P.metalwidths[i + 1 + #_P.meshmetals])
                    geometry.viabarebltr(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1,
                        point.create(-mwidth / 2, -mwidth / 2),
                        point.create( mwidth / 2,  mwidth / 2)
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
            if _P.connecttopmetal then
                geometry.viabarebltr(mesh, _P.gridmetals[#_P.gridmetals], _P.gridmetals[#_P.gridmetals] + 1,
                    point.create(-_P.metalwidths[#_P.metalwidths] / 2, -_P.metalwidths[#_P.metalwidths] / 2),
                    point.create( _P.metalwidths[#_P.metalwidths] / 2,  _P.metalwidths[#_P.metalwidths] / 2)
                )
            end
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

        for i = 1, #_P.meshmetals do
            if _P.needmultiplepatterning[i] then
                local density = 0.5
                local numlines = math.floor(density * (_P.cellsize - 2 * _P.metalwidths[i]) / _P.metalwidths[i])
                if numlines % 2 == 0 then
                    numlines = numlines - 1 -- make sure there is an odd number of lines (double patterning)
                end
                for j = 1, numlines do
                    geometry.rectanglebltr(mesh, generics.metal(_P.meshmetals[i]),
                        point.create(
                            -(_P.cellsize - 4 * _P.metalwidths[i]) / 2,
                            -_P.metalwidths[i] / 2 + (j - (numlines + 1) / 2) * _P.cellsize / (numlines + 1)
                        ),
                        point.create(
                            (_P.cellsize - 4 * _P.metalwidths[i]) / 2,
                            _P.metalwidths[i] / 2 + (j - (numlines + 1) / 2) * _P.cellsize / (numlines + 1)
                        )
                    )
                end
            else
                if i ~= _P.interconnectmetal then
                    geometry.rectanglebltr(mesh, generics.metal(_P.meshmetals[i]),
                        point.create(-_P.metalwidths[i], -_P.cellsize / 2),
                        point.create( _P.metalwidths[i],  _P.cellsize / 2)
                    )
                    geometry.rectanglebltr(mesh, generics.metal(_P.meshmetals[i]),
                        point.create(-_P.cellsize / 2, -_P.metalwidths[i]),
                        point.create( _P.cellsize / 2,  _P.metalwidths[i])
                    )
                end
            end
        end
        -- connect mesh to grid
        if _P.drawgrid then
            if _P.drawleft then
                geometry.viabltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(-_P.cellsize / 2, -_P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create(-_P.cellsize / 2 + _P.cellsize / 4,  _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
            end
            if _P.drawright then
                geometry.viabltr(mesh, _P.interconnectmetal, _P.interconnectmetal + 1,
                    point.create(_P.cellsize / 2 - _P.cellsize / 4, -_P.metalwidths[#_P.meshmetals + 2] / 2),
                    point.create(_P.cellsize / 2,  _P.metalwidths[#_P.meshmetals + 2] / 2)
                )
            end
            local leftright = true
            for i = 1, #_P.gridmetals do
                local metal = _P.gridmetals[i]
                if leftright and _P.drawleft then
                    geometry.rectanglebltr(mesh, generics.metal(metal),
                        point.create(-_P.cellsize / 2, -_P.metalwidths[metal] / 2),
                        point.create(-_P.cellsize / 2 + _P.cellsize / 4,  _P.metalwidths[metal] / 2)
                    )
                end
                if leftright and _P.drawright then
                    geometry.rectanglebltr(mesh, generics.metal(metal),
                        point.create(_P.cellsize / 2 - _P.cellsize / 4, -_P.metalwidths[metal] / 2),
                        point.create(_P.cellsize / 2,  _P.metalwidths[metal] / 2)
                    )
                end
                if not leftright and _P.drawbottom then
                    geometry.rectanglebltr(mesh, generics.metal(metal),
                        point.create(-_P.metalwidths[metal] / 2, _P.cellsize / 2 - _P.cellsize / 4),
                        point.create(_P.metalwidths[metal] / 2, _P.cellsize / 2)
                    )
                end
                if not leftright and _P.drawtop then
                    geometry.rectanglebltr(mesh, generics.metal(metal),
                        point.create(-_P.metalwidths[metal] / 2, -_P.cellsize / 2),
                        point.create(_P.metalwidths[metal] / 2,  -_P.cellsize / 2 + _P.cellsize / 4)
                    )
                end
                leftright = not leftright
            end
        end
    end -- drawasplane

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
