function parameters()
    pcell.add_parameters(
        { "flavour", "cap", posvals = set("ground", "cap") },
        { "cellsize", 10000 },
        { "meshmetals", { 1, 2, 3, 4, 5, 6, 7, 8 } },
        { "gridmetals", { 9, 10 } },
        { "interconnectmetal", 8 },
        { "guardringwidth", 500 },
        { "drawguardring", true },
        { "drawmesh", true },
        { "drawgrid", true },
        { "drawleft", true },
        { "drawright", true },
        { "drawtop", true },
        { "drawbottom", true },
        { "connecttopmetal", false },
        { "metalwidths", { 500, 500, 800, 800, 800, 800, 1000, 1000, 5000, 5000 } },
        { "needmultiplepatterning", { true, true, false, false, false, false, false, false } }
    )
end

function layout(mesh, _P)
    -- guard ring
    if _P.drawguardring and aux.find(_P.meshmetals, 1) then
        mesh:merge_into(pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = "p",
            holewidth = _P.cellsize - 2 * _P.guardringwidth,
            holeheight = _P.cellsize - 2 * _P.guardringwidth,
            ringwidth = _P.guardringwidth,
            fit = true
        }))
    end

    -- mesh metals
    if _P.drawmesh then
        for i = 1, #_P.meshmetals do
            geometry.ring(mesh, generics.metal(_P.meshmetals[i]), _P.cellsize, _P.cellsize, _P.metalwidths[i])
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local mwidth = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
                    geometry.via(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        mwidth, _P.cellsize,
                        -_P.cellsize / 2 + mwidth / 2, 0,
                        1, 1, 0, 0,
                        { equal_pitch = true }
                    )
                    geometry.via(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        mwidth, _P.cellsize,
                        _P.cellsize / 2 - mwidth / 2, 0,
                        1, 1, 0, 0,
                        { equal_pitch = true }
                    )
                    geometry.via(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        _P.cellsize, mwidth,
                        0, -_P.cellsize / 2 + mwidth / 2,
                        1, 1, 0, 0,
                        { equal_pitch = true }
                    )
                    geometry.via(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1,
                        _P.cellsize, mwidth,
                        0,  _P.cellsize / 2 - mwidth / 2,
                        1, 1, 0, 0,
                        { equal_pitch = true }
                    )
                end
            end
            -- fill exclude
            geometry.rectangle(mesh, generics.metalexclude(_P.meshmetals[i]), _P.cellsize, _P.cellsize)
        end
    end

    -- grid metals
    if _P.drawgrid then
        for i = 1, #_P.gridmetals do
            local metal = _P.gridmetals[i]
            local width = _P.metalwidths[i + #_P.meshmetals]
            if _P.drawright then
                geometry.rectangle(mesh, generics.metal(metal), width, width, width / 2, 0)
            end
            if _P.drawleft then
                geometry.rectangle(mesh, generics.metal(metal), width, width, -width / 2, 0)
            end
            if _P.drawtop then
                geometry.rectangle(mesh, generics.metal(metal), width, width, 0, width / 2)
            end
            if _P.drawbottom then
                geometry.rectangle(mesh, generics.metal(metal), width, width, 0, -width / 2)
            end
            if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
                local mwidth = math.min(_P.metalwidths[i + #_P.meshmetals], _P.metalwidths[i + 1 + #_P.meshmetals])
                geometry.via(mesh, _P.gridmetals[i], _P.gridmetals[i] + 1, mwidth, mwidth)
            end
            -- fill exclude
            geometry.rectangle(mesh, generics.metalexclude(_P.gridmetals[i]), _P.cellsize, _P.cellsize)
        end
        -- connect to top metal
        if _P.connecttopmetal then
            geometry.via(mesh, _P.gridmetals[#_P.gridmetals], _P.gridmetals[#_P.gridmetals] + 1, _P.metalwidths[#_P.metalwidths], _P.metalwidths[#_P.metalwidths])
        end
    end

    local foffset = 100
    local fwidth = 50
    local fspace = 50
    local flippolarity = true
    if _P.flavour == "cap" then
        for i = 1, #_P.meshmetals do
            if _P.meshmetals[i] == _P.interconnectmetal then
                break
            end
            local nfingers = 2 * math.floor((_P.cellsize - 2 * _P.metalwidths[i]) / (2 * (fwidth + fspace))) - 10
            local topcap = pcell.create_layout("passive/capacitor/mom", "topcap", {
                firstmetal = _P.meshmetals[i], lastmetal = _P.meshmetals[i],
                fingers = nfingers,
                fwidth = fwidth,
                fspace = fspace,
                foffset = foffset,
                rwidth = _P.metalwidths[i],
                fheight = _P.cellsize / 2 - _P.metalwidths[i] / 2 - _P.metalwidths[i] - 2 * foffset,
                alternatingpolarity = alternatingpolarity,
                flippolarity = flippolarity,
            })
            flippolarity = not flippolarity
            local botcap = topcap:copy()
            topcap:move_anchor("minus")
            botcap:move_anchor("plus")
            botcap:flipy()
            mesh:merge_into(topcap)
            mesh:merge_into(botcap)
            -- inner rail via
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local nfingersnext = 2 * math.floor((_P.cellsize - 2 * _P.metalwidths[i + 1]) / (2 * (fwidth + fspace))) - 10
                    local viawidth = (math.min(nfingers, nfingersnext) + 1) * (fwidth + fspace)
                    local viaheight = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
                    geometry.via(mesh, _P.meshmetals[i], _P.meshmetals[i] + 1, viawidth, viaheight)
                end
            end
        end
        -- connect cap to grid
        if _P.drawgrid then
            geometry.via(mesh, _P.interconnectmetal, _P.interconnectmetal + 1, _P.metalwidths[#_P.meshmetals + 2], _P.metalwidths[#_P.meshmetals + 2])
        end
    else -- flavour == "ground"
        for i = 1, #_P.meshmetals do
            if _P.needmultiplepatterning[i] then
                local density = 0.5
                local numlines = math.floor(density * (_P.cellsize - 2 * _P.metalwidths[i]) / _P.metalwidths[i])
                if numlines % 2 == 0 then
                    numlines = numlines - 1
                end
                for j = 1, numlines do
                    geometry.rectangle(mesh, generics.metal(_P.meshmetals[i]),
                        _P.cellsize - 4 * _P.metalwidths[i], _P.metalwidths[i],
                        0, (j - (numlines + 1) / 2) * _P.cellsize / (numlines + 1)
                    )
                end
            else
                geometry.rectangle(mesh, generics.metal(_P.meshmetals[i]), _P.metalwidths[i], _P.cellsize)
                geometry.rectangle(mesh, generics.metal(_P.meshmetals[i]), _P.cellsize, _P.metalwidths[i])
            end
        end
        -- connect mesh to grid
        if _P.drawgrid then
            if _P.drawleft then
                geometry.via(mesh, _P.interconnectmetal, _P.interconnectmetal + 1, _P.cellsize / 4, _P.metalwidths[#_P.meshmetals + 2], -_P.cellsize / 2 + _P.cellsize / 8, 0)
            end
            if _P.drawright then
                geometry.via(mesh, _P.interconnectmetal, _P.interconnectmetal + 1, _P.cellsize / 4, _P.metalwidths[#_P.meshmetals + 2],  _P.cellsize / 2 - _P.cellsize / 8, 0)
            end
            if _P.drawbottom then
                geometry.via(mesh, _P.interconnectmetal, _P.interconnectmetal + 1, _P.metalwidths[#_P.meshmetals + 2], _P.cellsize / 4, 0, -_P.cellsize / 2 + _P.cellsize / 8)
            end
            if _P.drawtop then
                geometry.via(mesh, _P.interconnectmetal, _P.interconnectmetal + 1, _P.metalwidths[#_P.meshmetals + 2], _P.cellsize / 4, 0,  _P.cellsize / 2 - _P.cellsize / 8)
            end
        end
    end

    -- FIXME: this should depend on parameters
    mesh:add_anchor_area_bltr(
        "gridcenter",
        point.create(-2500, -2500),
        point.create( 2500,  2500)
    )

    mesh:set_alignment_box(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )
end
