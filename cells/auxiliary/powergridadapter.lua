function parameters()
    pcell.add_parameters(
        { "cellsize", 10000 },
        { "lmwidth", 500 },
        { "lmspace", 500 },
        { "gridmetals", { 9, 10 } },
        { "interconnectmetal", 8 },
        { "interconnectwidth", 2500 },
        { "interconnectnumlines", 3 },
        { "drawvddlines", true },
        { "drawlowermetalgrid", true },
        { "drawleft", true },
        { "drawright", true },
        { "drawtop", true },
        { "drawbottom", true },
        { "adaptleft", false },
        { "adaptright", false },
        { "adapttop", false },
        { "adaptbottom", false },
        { "leftoffsetvalue", 3 },
        { "rightoffsetvalue", 3 },
        { "topoffsetvalue", 3 },
        { "bottomoffsetvalue", 3 },
        { "extendleft", false },
        { "extendright", false },
        { "extendtop", false },
        { "extendbottom", false },
        { "restrictvss", false },
        { "drawtopmetal", false },
        { "topmetaldensity", 50 },
        { "connecttopmetal", false, follow = "drawtopmetal" },
        { "gridmetalwidths", { { vss = 2400, vdd = 3600 }, { vss = 2400, vdd = 3600 } } },
        { "drawfillexcludes", true }
    )
end

function check(_P)
    -- FIXME: if this is enforced anyway, why keep the 'interconnectmetal' parameter?
    if _P.interconnectmetal + 1 ~= _P.gridmetals[1] then
        return false, string.format("there must be no metal between the interconnectmetal and the first grid metal (%d and %d)", _P.interconnectmetal, _P.gridmetals[1])
    end
    return true
end

function layout(adapter, _P)
    -- lower metal grid
    local lmgrid = object.create_pseudo()
    local lmnumlines = util.fit_lines_lower(_P.cellsize + _P.gridmetalwidths[1].vss, _P.lmwidth, _P.lmspace)
    if lmnumlines % 2 == 0 then
        lmnumlines = lmnumlines + 1
    end
    local xpitch = _P.lmwidth + _P.lmspace
    local ypitch = _P.lmwidth + _P.lmspace
    local leftoffset = _P.adaptleft and _P.leftoffsetvalue or 0
    local rightoffset = _P.adaptright and _P.rightoffsetvalue or 0
    local topoffset = _P.adapttop and _P.topoffsetvalue or 0
    local bottomoffset = _P.adaptbottom and _P.bottomoffsetvalue or 0
    -- metal lines
    if _P.drawlowermetalgrid then
        for m = 1, technology.resolve_metal(_P.interconnectmetal) - 1, 2 do
            for i = 1 + bottomoffset, lmnumlines - topoffset do
                local xoffset = -lmnumlines * xpitch / 2
                local yoffset = -lmnumlines * ypitch / 2 + _P.lmspace / 2
                local xl, xr
                if i % 2 == 1 then
                    xl = xoffset
                    xr = xoffset + lmnumlines * xpitch
                else
                    xl = xoffset + leftoffset * xpitch
                    xr = xoffset + (lmnumlines - rightoffset) * xpitch
                end
                if i % 2 == 1 then -- vss lines
                    geometry.rectanglebltr(
                        adapter, generics.metal(m),
                        point.create(xl, (i - 1) * ypitch + yoffset),
                        point.create(xr, (i - 1) * ypitch + yoffset + _P.lmwidth)
                    )
                else -- vdd lines
                    if _P.drawvddlines then
                        geometry.rectanglebltr(
                            adapter, generics.metal(m),
                            point.create(xl, (i - 1) * ypitch + yoffset),
                            point.create(xr, (i - 1) * ypitch + yoffset + _P.lmwidth)
                        )
                    end
                end
            end
        end
        for m = 2, technology.resolve_metal(_P.interconnectmetal) - 2, 2 do
            for i = 1 + leftoffset, lmnumlines - rightoffset do
                local xoffset = -lmnumlines * xpitch / 2 + _P.lmspace / 2
                local yoffset = -lmnumlines * ypitch / 2
                local yb, yt
                if i % 2 == 1 then
                    yb = yoffset
                    yt = yoffset + lmnumlines * ypitch
                else
                    yb = yoffset + bottomoffset * ypitch
                    yt = yoffset + (lmnumlines - topoffset) * ypitch
                end
                if i % 2 == 1 then -- vss lines
                    geometry.rectanglebltr(
                        adapter, generics.metal(m),
                        point.create((i - 1) * xpitch + xoffset,              yb),
                        point.create((i - 1) * xpitch + xoffset + _P.lmwidth, yt)
                    )
                else -- vdd lines
                    if _P.drawvddlines then
                        geometry.rectanglebltr(
                            adapter, generics.metal(m),
                            point.create((i - 1) * xpitch + xoffset,              yb),
                            point.create((i - 1) * xpitch + xoffset + _P.lmwidth, yt)
                        )
                    end
                end
            end
        end
        -- vias
        for i = 1 + bottomoffset, lmnumlines - topoffset do
            for j = 1 + leftoffset, lmnumlines - rightoffset do
                local xoffset = -lmnumlines * xpitch / 2 + _P.lmspace / 2
                local yoffset = -lmnumlines * ypitch / 2 + _P.lmspace / 2
                local x = (j - 1) * xpitch + xoffset
                local y = (i - 1) * ypitch + yoffset
                if (i % 2 == 0) == (j % 2 == 0) then
                    geometry.viabarebltr(adapter, 1, technology.resolve_metal(_P.interconnectmetal) - 1,
                        point.create(x + 0,          y + 0),
                        point.create(x + _P.lmwidth, y + _P.lmwidth)
                    )
                end
            end
        end
    end

    -- calculate adapt sizes
    local adaptsizes = {}
    for i = 1, #_P.gridmetals do
        local entry = {}
        local vsswidth = _P.gridmetalwidths[i].vss
        local vddwidth = _P.gridmetalwidths[i].vdd
        entry.vddleft = -_P.cellsize / 2 - vsswidth / 2
        entry.vddright = _P.cellsize / 2 + vsswidth / 2
        if _P.adaptleft then
            entry.vddleft = -vddwidth / 2
        end
        if _P.adaptright then
            entry.vddright = vddwidth / 2
        end
        entry.vssleft = -_P.cellsize / 2 - vsswidth / 2
        entry.vssright = _P.cellsize / 2 + vsswidth / 2
        entry.vddbottom = -_P.cellsize / 2 - vsswidth / 2
        entry.vddtop = _P.cellsize / 2 + vsswidth / 2
        if _P.adaptbottom then
            entry.vddbottom = -vddwidth / 2
        end
        if _P.adapttop then
            entry.vddtop = vddwidth / 2
        end
        entry.vssbottom = -_P.cellsize / 2 - vsswidth / 2
        entry.vsstop = _P.cellsize / 2 + vsswidth / 2
        adaptsizes[i] = entry
    end

    -- calculate drawing sizes
    local drawingsizes = {}
    for i = 1, #_P.gridmetals do
        local entry = {}
        local vsswidth = _P.gridmetalwidths[i].vss
        local vddwidth = _P.gridmetalwidths[i].vdd
        entry.vddleft = -_P.cellsize / 2 - vsswidth / 2
        entry.vddright = _P.cellsize / 2 + vsswidth / 2
        if _P.extendleft then
            entry.vddleft = -_P.cellsize + vddwidth / 2
        end
        if not _P.drawleft then
            entry.vddleft = -vddwidth / 2
        end
        if _P.extendright then
            entry.vddright = _P.cellsize - vddwidth / 2
        end
        if not _P.drawright then
            entry.vddright = vddwidth / 2
        end
        entry.vssleft = -_P.cellsize / 2 - vsswidth / 2
        entry.vssright = _P.cellsize / 2 + vsswidth / 2
        if _P.restrictvss then
            if not _P.drawleft then
                entry.vssleft = -vsswidth / 2
            end
            if not _P.drawright then
                entry.vssright = vsswidth / 2
            end
        end
        entry.vddbottom = -_P.cellsize / 2 - vsswidth / 2
        entry.vddtop = _P.cellsize / 2 + vsswidth / 2
        if _P.extendbottom then
            entry.vddbottom = -_P.cellsize + vddwidth / 2
        end
        if not _P.drawbottom then
            entry.vddbottom = -vddwidth / 2
        end
        if _P.extendtop then
            entry.vddbottom = _P.cellsize - vddwidth / 2
        end
        if not _P.drawtop then
            entry.vddtop = vddwidth / 2
        end
        entry.vssbottom = -_P.cellsize / 2 - vsswidth / 2
        entry.vsstop = _P.cellsize / 2 + vsswidth / 2
        if _P.restrictvss then
            if not _P.drawbottom then
                entry.vssbottom = -vsswidth / 2
            end
            if not _P.drawtop then
                entry.vsstop = vsswidth / 2
            end
        end
        drawingsizes[i] = entry
    end

    -- connect lower-metal grid to higher-metal grid
    local vss1width = _P.gridmetalwidths[1].vss
    local vdd1width = _P.gridmetalwidths[1].vdd
    local ystart = -(lmnumlines - 1) / 2 * (_P.lmwidth + _P.lmspace)
    for i = 1 + bottomoffset, lmnumlines - topoffset do
        if i % 2 == 1 then
            local yshift = (i - 1) * (_P.lmwidth + _P.lmspace)
            if not _P.adaptleft and (not _P.restrictvss or _P.drawleft) then
                geometry.viabltr(adapter, _P.interconnectmetal - 1, _P.interconnectmetal,
                    point.create(-_P.cellsize / 2 - _P.interconnectwidth / 2, ystart + yshift - _P.lmwidth / 2),
                    point.create(-_P.cellsize / 2 + _P.interconnectwidth / 2, ystart + yshift + _P.lmwidth / 2)
                )
            end
            if not _P.adaptright and (not _P.restrictvss or _P.drawright) then
                geometry.viabltr(adapter, _P.interconnectmetal - 1, _P.interconnectmetal,
                    point.create(_P.cellsize / 2 - _P.interconnectwidth / 2, ystart + yshift - _P.lmwidth / 2),
                    point.create(_P.cellsize / 2 + _P.interconnectwidth / 2, ystart + yshift + _P.lmwidth / 2)
                )
            end
        else
            local yshift = (i - 1) * (_P.lmwidth + _P.lmspace)
            if ystart + yshift >= adaptsizes[1].vddbottom and
               ystart + yshift <= adaptsizes[1].vddtop then
                geometry.viabltr(adapter, _P.interconnectmetal - 1, _P.interconnectmetal,
                    point.create(-_P.interconnectwidth / 2, ystart + yshift - _P.lmwidth / 2),
                    point.create( _P.interconnectwidth / 2, ystart + yshift + _P.lmwidth / 2)
                )
            end
        end
    end
    -- left vss interconnectmetal line 
    if not _P.restrictvss or _P.drawleft then
        geometry.rectanglebltr(adapter, generics.metal(_P.interconnectmetal),
            point.create(-_P.cellsize / 2 - _P.interconnectwidth / 2, drawingsizes[1].vddbottom),
            point.create(-_P.cellsize / 2 + _P.interconnectwidth / 2, drawingsizes[1].vddtop)
        )
    end
    -- right vss interconnectmetal line 
    if not _P.restrictvss or _P.drawright then
        geometry.rectanglebltr(adapter, generics.metal(_P.interconnectmetal),
            point.create(_P.cellsize / 2 - _P.interconnectwidth / 2, drawingsizes[1].vddbottom),
            point.create(_P.cellsize / 2 + _P.interconnectwidth / 2, drawingsizes[1].vddtop)
        )
    end
    -- vdd interconnect line
    geometry.rectanglebltr(adapter, generics.metal(_P.interconnectmetal),
        point.create(-_P.interconnectwidth / 2, drawingsizes[1].vddbottom),
        point.create( _P.interconnectwidth / 2, drawingsizes[1].vddtop)
    )
    -- vss vias
    if not _P.restrictvss or (_P.drawleft and _P.drawbottom) then
        geometry.viabarebltr(adapter, _P.interconnectmetal, _P.gridmetals[1],
            point.create(
                -_P.cellsize / 2 - vss1width / 2,
                -_P.cellsize / 2 - vss1width / 2
            ),
            point.create(
                -_P.cellsize / 2 + vss1width / 2,
                -_P.cellsize / 2 + vss1width / 2
            )
        )
    end
    if not _P.restrictvss or (_P.drawleft and _P.drawtop) then
        geometry.viabarebltr(adapter, _P.interconnectmetal, _P.gridmetals[1],
            point.create(
                -_P.cellsize / 2 - vss1width / 2,
                _P.cellsize / 2 - vss1width / 2
            ),
            point.create(
                -_P.cellsize / 2 + vss1width / 2,
                _P.cellsize / 2 + vss1width / 2
            )
        )
    end
    if not _P.restrictvss or (_P.drawright and _P.drawbottom) then
        geometry.viabarebltr(adapter, _P.interconnectmetal, _P.gridmetals[1],
            point.create(
                _P.cellsize / 2 - vss1width / 2,
                -_P.cellsize / 2 - vss1width / 2
            ),
            point.create(
                _P.cellsize / 2 + vss1width / 2,
                -_P.cellsize / 2 + vss1width / 2
            )
        )
    end
    if not _P.restrictvss or (_P.drawright and _P.drawtop) then
        geometry.viabarebltr(adapter, _P.interconnectmetal, _P.gridmetals[1],
            point.create(
                _P.cellsize / 2 - vss1width / 2,
                _P.cellsize / 2 - vss1width / 2
            ),
            point.create(
                _P.cellsize / 2 + vss1width / 2,
                _P.cellsize / 2 + vss1width / 2
            )
        )
    end
    -- vdd via
    geometry.viabarebltr(adapter, _P.interconnectmetal, _P.gridmetals[1],
        point.create(
            -_P.interconnectwidth / 2,
            -vdd1width / 2
        ),
        point.create(
            _P.interconnectwidth / 2,
            vdd1width / 2
        )
    )

    -- grid metals
    local leftright = true
    for i = 1, #_P.gridmetals do
        local size = drawingsizes[i]
        local metal = _P.gridmetals[i]
        local vsswidth = _P.gridmetalwidths[i].vss
        local vddwidth = _P.gridmetalwidths[i].vdd
        if leftright then
            if not _P.restrictvss or _P.drawbottom then
                geometry.rectanglebltr(adapter, generics.metal(metal),
                    point.create(size.vssleft,  -_P.cellsize / 2 - vsswidth / 2 ),
                    point.create(size.vssright, -_P.cellsize / 2 + vsswidth / 2 )
                )
            end
            geometry.rectanglebltr(adapter, generics.metal(metal),
                point.create(size.vddleft, -vddwidth / 2),
                point.create(size.vddright, vddwidth / 2)
            )
            if not _P.restrictvss or _P.drawtop then
                geometry.rectanglebltr(adapter, generics.metal(metal),
                    point.create(size.vssleft,  _P.cellsize / 2 - vsswidth / 2),
                    point.create(size.vssright, _P.cellsize / 2 + vsswidth / 2)
                )
            end
        else
            if not _P.restrictvss or _P.drawleft then
                geometry.rectanglebltr(adapter, generics.metal(metal),
                    point.create(-_P.cellsize / 2 - vsswidth / 2, size.vssbottom),
                    point.create(-_P.cellsize / 2 + vsswidth / 2, size.vsstop)
                )
            end
            geometry.rectanglebltr(adapter, generics.metal(metal),
                point.create(-vddwidth / 2, size.vddbottom),
                point.create( vddwidth / 2, size.vddtop)
            )
            if not _P.restrictvss or _P.drawright then
                geometry.rectanglebltr(adapter, generics.metal(metal),
                    point.create(_P.cellsize / 2 - vsswidth / 2, size.vssbottom),
                    point.create(_P.cellsize / 2 + vsswidth / 2, size.vsstop)
                )
            end
        end
        if (i < #_P.gridmetals) and (_P.gridmetals[i + 1] - _P.gridmetals[i] == 1) then
            local mwidth = math.min(_P.gridmetalwidths[i].vss, _P.gridmetalwidths[i + 1].vss)
            geometry.viabarebltr(adapter, _P.gridmetals[i], _P.gridmetals[i] + 1,
                point.create(-mwidth / 2, -mwidth / 2),
                point.create( mwidth / 2,  mwidth / 2)
            )
            if not _P.restrictvss or (_P.drawleft and _P.drawbottom) then
                geometry.viabarebltr(adapter, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create(-_P.cellsize / 2 - mwidth / 2, -_P.cellsize / 2 - mwidth / 2),
                    point.create(-_P.cellsize / 2 + mwidth / 2, -_P.cellsize / 2 + mwidth / 2)
                )
            end
            if not _P.restrictvss or (_P.drawright and _P.drawtop) then
                geometry.viabarebltr(adapter, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create( _P.cellsize / 2 - mwidth / 2,  _P.cellsize / 2 - mwidth / 2),
                    point.create( _P.cellsize / 2 + mwidth / 2,  _P.cellsize / 2 + mwidth / 2)
                )
            end
            if not _P.restrictvss or (_P.drawleft and _P.drawtop) then
                geometry.viabarebltr(adapter, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create(-_P.cellsize / 2 - mwidth / 2,  _P.cellsize / 2 - mwidth / 2),
                    point.create(-_P.cellsize / 2 + mwidth / 2,  _P.cellsize / 2 + mwidth / 2)
                )
            end
            if not _P.restrictvss or (_P.drawright and _P.drawbottom) then
                geometry.viabarebltr(adapter, _P.gridmetals[i], _P.gridmetals[i] + 1,
                    point.create( _P.cellsize / 2 - mwidth / 2, -_P.cellsize / 2 - mwidth / 2),
                    point.create( _P.cellsize / 2 + mwidth / 2, -_P.cellsize / 2 + mwidth / 2)
                )
            end
        end
        -- fill exclude
        if _P.drawfillexcludes then
            geometry.rectanglebltr(adapter, generics.metalexclude(_P.gridmetals[i]),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
        end
        leftright = not leftright
    end
    --[[
    -- connect to top metal
    if _P.connecttopmetal then
        geometry.viabarebltr(adapter, _P.gridmetals[#_P.gridmetals], _P.gridmetals[#_P.gridmetals] + 1,
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
            geometry.rectanglebltr(adapter, generics.metal(-1),
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
            geometry.polygon(adapter, generics.metal(-1), pts)
        end
        if _P.drawfillexcludes then
            geometry.rectanglebltr(adapter, generics.metalexclude(-1),
                point.create(-_P.cellsize / 2, -_P.cellsize / 2),
                point.create( _P.cellsize / 2,  _P.cellsize / 2)
            )
        end
    end
    --]]

    adapter:add_area_anchor_bltr("outerboundary",
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )

    adapter:set_alignment_box(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )

    adapter:set_boundary_rectangular(
        point.create(-_P.cellsize / 2, -_P.cellsize / 2),
        point.create( _P.cellsize / 2,  _P.cellsize / 2)
    )
end
