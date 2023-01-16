function parameters()
    pcell.add_parameters(
        { "rows", 2, },
        { "columns", 2 },
        { "flavour", "cap", posvals = set("ground", "cap") },
        { "cellsize", 10000 },
        { "meshmetals", { 1, 2, 3, 4, 5, 6, 7, 8 } },
        { "gridmetals", { 9, 10 } },
        { "interconnectmetal", 8 },
        { "guardringwidth", 500 },
        { "drawleft", false },
        { "drawright", false },
        { "drawtop", false },
        { "drawbottom", false },
        { "connecttopmetal", false },
        { "metalwidths", { 500, 500, 800, 800, 800, 800, 1000, 1000, 5000, 5000 } },
        { "needmultiplepatterning", { true, true, false, false, false, false, false, false } }
    )
end

function layout(cell, _P)
    local baseref = object.create("base")
    -- guard ring
    if aux.find(_P.meshmetals, 1) then
        baseref:merge_into(pcell.create_layout("auxiliary/guardring", "guardring", {
            contype = "p",
            holewidth = _P.cellsize - 2 * _P.guardringwidth,
            holeheight = _P.cellsize - 2 * _P.guardringwidth,
            ringwidth = _P.guardringwidth,
            fit = true
        }))
    end

    -- mesh metals
    for i = 1, #_P.meshmetals - 1 do
        if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
            local mwidth = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
            geometry.via(baseref, _P.meshmetals[i], _P.meshmetals[i] + 1,
                mwidth, _P.cellsize,
                -_P.cellsize / 2 + mwidth / 2, 0,
                1, 1, 0, 0,
                { equal_pitch = true }
            )
            geometry.via(baseref, _P.meshmetals[i], _P.meshmetals[i] + 1,
                mwidth, _P.cellsize,
                _P.cellsize / 2 - mwidth / 2, 0,
                1, 1, 0, 0,
                { equal_pitch = true }
            )
            geometry.via(baseref, _P.meshmetals[i], _P.meshmetals[i] + 1,
                _P.cellsize, mwidth,
                0, -_P.cellsize / 2 + mwidth / 2,
                1, 1, 0, 0,
                { equal_pitch = true }
            )
            geometry.via(baseref, _P.meshmetals[i], _P.meshmetals[i] + 1,
                _P.cellsize, mwidth,
                0,  _P.cellsize / 2 - mwidth / 2,
                1, 1, 0, 0,
                { equal_pitch = true }
            )
        end
    end

    -- grid metals
    for i = 1, #_P.gridmetals do
        local metal = _P.gridmetals[i]
        local width = _P.metalwidths[i + #_P.meshmetals]
        if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
            local mwidth = math.min(_P.metalwidths[i + #_P.meshmetals], _P.metalwidths[i + 1 + #_P.meshmetals])
            geometry.via(baseref, _P.gridmetals[i], _P.gridmetals[i] + 1, mwidth, mwidth)
        end
        -- fill exclude
        geometry.rectangle(baseref, generics.metalexclude(_P.gridmetals[i]), _P.cellsize, _P.cellsize)
    end

    -- connect to top metal
    if _P.connecttopmetal then
        geometry.via(baseref, _P.gridmetals[#_P.gridmetals], _P.gridmetals[#_P.gridmetals] + 1, _P.metalwidths[#_P.metalwidths], _P.metalwidths[#_P.metalwidths])
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
            baseref:merge_into(topcap)
            baseref:merge_into(botcap)
            -- inner rail via
            if i < #_P.meshmetals then
                if _P.meshmetals[i + 1] - _P.meshmetals[i] == 1 then
                    local nfingersnext = 2 * math.floor((_P.cellsize - 2 * _P.metalwidths[i + 1]) / (2 * (fwidth + fspace))) - 10
                    local viawidth = (math.min(nfingers, nfingersnext) + 1) * (fwidth + fspace)
                    local viaheight = math.min(_P.metalwidths[i], _P.metalwidths[i + 1])
                    geometry.via(baseref, _P.meshmetals[i], _P.meshmetals[i] + 1, viawidth, viaheight)
                end
            end
        end
        -- connect cap to grid
        geometry.via(baseref, _P.interconnectmetal, _P.interconnectmetal + 1, _P.metalwidths[#_P.meshmetals + 2], _P.metalwidths[#_P.meshmetals + 2])
    else -- flavour == "ground"
        for i = 1, #_P.meshmetals do
            if _P.meshmetals[i] ~= _P.interconnectmetal then
                if _P.needmultiplepatterning[i] then
                    local density = 0.5
                    local numlines = math.floor(density * (_P.cellsize - 2 * _P.metalwidths[i]) / _P.metalwidths[i])
                    if numlines % 2 == 0 then
                        numlines = numlines - 1
                    end
                    for j = 1, numlines do
                        geometry.rectangle(baseref, generics.metal(_P.meshmetals[i]),
                            _P.cellsize - 4 * _P.metalwidths[i], _P.metalwidths[i],
                            0, (j - (numlines + 1) / 2) * _P.cellsize / (numlines + 1)
                        )
                    end
                else
                    geometry.rectangle(baseref, generics.metal(_P.meshmetals[i]), _P.metalwidths[i], _P.cellsize)
                    geometry.rectangle(baseref, generics.metal(_P.meshmetals[i]), _P.cellsize, _P.metalwidths[i])
                end
            else
                geometry.ring(baseref, generics.metal(_P.interconnectmetal), _P.cellsize, _P.cellsize, _P.cellsize / 4)
            end
        end

        -- connect mesh to grid
        for column = 1, _P.columns do
            for row = 1, _P.rows do
                if _P.drawleft or column > 1 then
                    geometry.via(cell,
                        _P.interconnectmetal, _P.interconnectmetal + 1,
                        _P.cellsize / 4, _P.metalwidths[#_P.meshmetals + 2],
                        -_P.cellsize / 2 + _P.cellsize / 8 + (column - 1) * _P.cellsize, (row - 1) * _P.cellsize
                    )
                end
                if _P.drawright or column < _P.columns then
                    geometry.via(cell,
                        _P.interconnectmetal, _P.interconnectmetal + 1,
                        _P.cellsize / 4, _P.metalwidths[#_P.meshmetals + 2],
                        _P.cellsize / 2 - _P.cellsize / 8 + (column - 1) * _P.cellsize, (row - 1) * _P.cellsize
                    )
                end
            end
        end
    end

    -- place base array
    local base = cell:add_child_array(baseref, "base", _P.columns, _P.rows, _P.cellsize, _P.cellsize)

    -- draw grid metal lines
    for column = 1, _P.columns do
        geometry.rectanglebltr(
            cell, generics.metal(10),
            point.create(-2500 + (column - 1) * _P.cellsize, -2500),
            point.create( 2500 + (column - 1) * _P.cellsize,  2500 + (_P.rows - 1) * _P.cellsize)
        )
    end
    for row = 1, _P.rows do
        geometry.rectanglebltr(
            cell, generics.metal(9),
            point.create(-2500, -2500 + (row - 1) * _P.cellsize),
            point.create( 2500 + (_P.columns - 1) * _P.cellsize, 2500 + (row - 1) * _P.cellsize)
        )
    end

    -- metal fill exclude
    for i = 1, technology.resolve_metal(-1) do
        geometry.rectangle(baseref, generics.metalexclude(i), _P.cellsize, _P.cellsize)
    end
end
