local M = {}

function M.connect_area_anchor(cell, layer, width, anchor1, anchor2, grid, matchtolerance)
    check.set_next_function_name("layouthelpers.connect_area_anchor")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg(2, "width", "number", width)
    check.arg(3, "anchor1", "table", anchor1)
    check.arg(4, "anchor2", "table", anchor2)
    check.arg_optional(5, "grid", "number", grid)
    check.arg_optional(6, "matchtolerance", "number", matchtolerance)
    local x1l, y1b = anchor1.bl:unwrap()
    local x1r, y1t = anchor1.tr:unwrap()
    local x2l, y2b = anchor2.bl:unwrap()
    local x2r, y2t = anchor2.tr:unwrap()
    grid = grid or 1 -- FIXME: use grid
    -- FIXME: after using grid, update documentation
    -- anchor 1 is x-bound by anchor 2
    if x1l >= x2l and x1r <= x2r then
        if y1b > y2t then
            geometry.path(cell, layer, {
                    point.create(0.5 * (x1l + x1r), y1b),
                    point.create(0.5 * (x1l + x1r), y2t),
                }, width
            )
        else
            geometry.path(cell, layer, {
                    point.create(0.5 * (x1l + x1r), y2b),
                    point.create(0.5 * (x1l + x1r), y1t),
                }, width
            )
        end
    -- anchor 2 is x-bound by anchor 1
    elseif x2l >= x1l and x2r <= x1r then
        if y1b > y2t then
            geometry.path(cell, layer, {
                    point.create(0.5 * (x2l + x2r), y1b),
                    point.create(0.5 * (x2l + x2r), y2t),
                }, width
            )
        else
            geometry.path(cell, layer, {
                    point.create(0.5 * (x2l + x2r), y2b),
                    point.create(0.5 * (x2l + x2r), y1t),
                }, width
            )
        end
    -- anchor 1 is y-bound by anchor 2
    elseif y1b >= y2b and y1t <= y2t then
        if x1l > x2r then
            geometry.path(cell, layer, {
                    point.create(x1l, 0.5 * (y1b + y1t)),
                    point.create(x2r, 0.5 * (y1b + y1t)),
                }, width
            )
        else
            geometry.path(cell, layer, {
                    point.create(x2l, 0.5 * (y1b + y1t)),
                    point.create(x1r, 0.5 * (y1b + y1t)),
                }, width
            )
        end
    -- anchor 2 is y-bound by anchor 1
    elseif y2b >= y1b and y2t <= y1t then
        if x1l > x2r then
            geometry.path(cell, layer, {
                    point.create(x1l, 0.5 * (y2b + y2t)),
                    point.create(x2r, 0.5 * (y2b + y2t)),
                }, width
            )
        else
            geometry.path(cell, layer, {
                    point.create(x2l, 0.5 * (y2b + y2t)),
                    point.create(x1r, 0.5 * (y2b + y2t)),
                }, width
            )
        end
    else -- FIXME: add more conditions
        -- find target edges:
        local width1  = x1r - x1l
        local height1 = y1t - y1b
        local width2  = x2r - x2l
        local height2 = y2t - y2b
        local matchtolerance = matchtolerance or 1
        local xmatch1 = math.abs(width1 - width)  <= matchtolerance * width
        local ymatch1 = math.abs(height1 - width) <= matchtolerance * width
        local xmatch2 = math.abs(width2 - width)  <= matchtolerance * width
        local ymatch2 = math.abs(height2 - width) <= matchtolerance * width
        if xmatch1 and ymatch2 then
            local x2 = x1l > x2r and x2r or x2l
            local y1 = y1t < y2b and y1t or y1b
            geometry.path_2y(cell, layer,
                point.create(0.5 * (x1l + x1r), y1),
                point.create(x2, 0.5 * (y2b + y2t)),
                width
            )
        elseif xmatch2 and ymatch1 then
            local x1 = x2l > x1r and x1r or x1l
            local y2 = y2t < y1b and y2t or y2b
            geometry.path_2y(cell, layer,
                point.create(0.5 * (x2l + x2r), y2),
                point.create(x1, 0.5 * (y1b + y1t)),
                width
            )
        elseif y2b > y1t then
            geometry.path_3y(cell, layer,
                point.create(0.5 * (x1l + x1r), y1t),
                point.create(0.5 * (x2l + x2r), y2b),
                width, 0.5
            )
        elseif y1b > y2t then
            geometry.path_3y(cell, layer,
                point.create(0.5 * (x2l + x2r), y2t),
                point.create(0.5 * (x1l + x1r), y1b),
                width, 0.5
            )
        end
    end
end

function M.via_area_anchor_multiple(cell, startmetal, endmetal, fmt, startindex, endindex, increment)
    local f = string.gsub(fmt, "%%", "%%d")
    startindex = startindex or 1
    endindex = endindex or 1
    increment = increment or 1
    for i = startindex, endindex, increment do
        geometry.viabltr(cell, startmetal, endmetal,
            cell:get_area_anchor_fmt(f, i).bl,
            cell:get_area_anchor_fmt(f, i).tr
        )
    end
end

function M.place_bus(cell, layer, pathpoints, numbits, width, space)
    for i = 1, numbits do
        local offset = (i - 1 - (numbits - 1) / 2) * (width + space)
        local pts = geometry.get_side_path_points(pathpoints, offset)
        geometry.path(cell, layer, pts, width)
    end
end

function M.place_powervlines(cell, bl, tr, layer, width, space, powershapes)
    local width, height, space, offset, numlines = geometry.rectanglevlines_width_space_settings(
        bl, tr,
        width, space
    )
    for i = 1, numlines do
        local plbl = point.create(
            bl:getx() + offset + (i - 1) * (width + space),
            bl:gety()
        )
        local pltr = point.create(
            bl:getx() + offset + (i - 1) * (width + space) + width,
            bl:gety() + height
        )
        geometry.rectanglebltr(cell, generics.metal(layer), plbl, pltr)
        for _, target in ipairs(powershapes) do
            local r = util.rectangle_intersection(plbl, pltr, target.bl, target.tr)
            if r then
                geometry.viabltr(cell, layer - 1, layer,
                    point.create(plbl:getx(), target.bl:gety()),
                    point.create(pltr:getx(), target.tr:gety())
                )
            end
        end
    end
end

function M.place_powerhlines(cell, bl, tr, layer, height, space, powershapes)
    local width, height, space, offset, numlines = geometry.rectanglehlines_height_space_settings(
        bl, tr,
        height, space
    )
    for i = 1, numlines do
        local plbl = point.create(
            bl:getx(),
            bl:gety() + offset + (i - 1) * (height + space)
        )
        local pltr = point.create(
            bl:getx() + width,
            bl:gety() + offset + (i - 1) * (height + space) + height
        )
        geometry.rectanglebltr(cell, generics.metal(layer), plbl, pltr)
        for _, target in ipairs(powershapes) do
            local r = util.rectangle_intersection(plbl, pltr, target.bl, target.tr)
            if r then
                geometry.viabltr(cell, layer - 1, layer,
                    point.create(plbl:getx(), target.bl:gety()),
                    point.create(pltr:getx(), target.tr:gety())
                )
            end
        end
    end
end

function M.place_powergrid(cell, bl, tr, vlayer, hlayer, vwidth, vspace, hwidth, hspace, plusshapes, minusshapes)
    check.set_next_function_name("layouthelpers.place_powergrid")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", bl, point.is_point)
    check.arg_optional(4, "vlayer", "number", vlayer)
    check.arg_optional(5, "hlayer", "number", hlayer)
    check.arg(6, "vwidth", "number", vwidth)
    check.arg(7, "vspace", "number", vspace)
    check.arg(8, "hwidth", "number", hwidth)
    check.arg(9, "hspace", "number", hspace)
    check.arg_optional(10, "plusshapes", "table", plusshapes)
    check.arg_optional(11, "minusshapes", "table", minusshapes)
    if not vlayer and not hlayer then
        error("layouthelpers.place_powergrid: at least one metal layer must not be nil")
    end
    local hpluslines = {}
    local hminuslines = {}
    local vpluslines = {}
    local vminuslines = {}
    if vlayer then
        local width, height, space, offset, numlines = geometry.rectanglevlines_width_space_settings(
            bl, tr,
            vwidth, vspace
        )
        for i = 1, numlines do
            local plbl = point.create(
                bl:getx() + offset + (i - 1) * (width + space),
                bl:gety()
            )
            local pltr = point.create(
                bl:getx() + offset + (i - 1) * (width + space) + width,
                bl:gety() + height
            )
            geometry.rectanglebltr(cell, generics.metal(vlayer), plbl, pltr)
            local inserttarget = i % 2 == 1 and vpluslines or vminuslines
            table.insert(inserttarget, { bl = plbl, tr = pltr })
        end
    end
    if hlayer then
        local width, height, space, offset, numlines = geometry.rectanglehlines_height_space_settings(
            bl, tr,
            hwidth, hspace
        )
        for i = 1, numlines do
            local plbl = point.create(
                bl:getx(),
                bl:gety() + offset + (i - 1) * (height + space)
            )
            local pltr = point.create(
                bl:getx() + width,
                bl:gety() + offset + (i - 1) * (height + space) + height
            )
            geometry.rectanglebltr(cell, generics.metal(hlayer), plbl, pltr)
            local inserttarget = i % 2 == 1 and hpluslines or hminuslines
            table.insert(inserttarget, { bl = plbl, tr = pltr })
        end
    end
    -- place vias between powerlines
    if vlayer and hlayer then
        for _, hline in ipairs(hpluslines) do
            for _, vline in ipairs(vpluslines) do
                local r = util.rectangle_intersection(hline.bl, hline.tr, vline.bl, vline.tr)
                if r then
                    geometry.viabltr(cell, vlayer - 1, vlayer,
                        point.create(vline.bl:getx(), hline.bl:gety()),
                        point.create(vline.tr:getx(), hline.tr:gety())
                    )
                end
            end
        end
        for _, hline in ipairs(hminuslines) do
            for _, vline in ipairs(vminuslines) do
            end
        end
    end
    -- place vias to plus/minus shapes
    local pluslines
    local minuslines
    local layer
    if hlayer and not vlayer then
        pluslines = hpluslines
        minuslines = hminuslines
        layer = hlayer
    elseif vlayer and not hlayer then
        pluslines = vpluslines
        minuslines = vminuslines
        layer = vlayer
    elseif hlayer < vlayer then
        pluslines = hpluslines
        minuslines = hminuslines
        layer = hlayer
    else
        pluslines = vpluslines
        minuslines = vminuslines
        layer = vlayer
    end
    for _, line in ipairs(pluslines) do
        for _, target in ipairs(plusshapes) do
            local r = util.rectangle_intersection(line.bl, line.tr, target.bl, target.tr)
            if r then
                if geometry.check_viabltr(layer - 1, layer, r.bl, r.tr) then
                    geometry.viabltr(cell, layer - 1, layer, r.bl, r.tr)
                end
            end
        end
    end
    for _, line in ipairs(minuslines) do
        for _, target in ipairs(minusshapes) do
            local r = util.rectangle_intersection(line.bl, line.tr, target.bl, target.tr)
            if r then
                if geometry.check_viabltr(layer - 1, layer, r.bl, r.tr) then
                    geometry.viabltr(cell, layer - 1, layer, r.bl, r.tr)
                end
            end
        end
    end
end

function M.place_vlines_numsets(cell, bl, tr, layer, width, netnames, numsets)
    local numnets = #netnames
    local width, height, space, offset, numlines = geometry.rectanglevlines_numlines_width_settings(
        bl, tr,
        numnets * numsets, width
    )
    if space < 0 then
        error("layouthelpers.place_vlines_numsets: the given lines constraints yield a negative line spacing. Increase the area size, or decrease the number of lines and/or the line width")
    end
    local netshapes = {}
    for i = 1, numlines do
        local plbl = point.create(
            bl:getx() + offset + (i - 1) * (width + space),
            bl:gety()
        )
        local pltr = point.create(
            bl:getx() + offset + (i - 1) * (width + space) + width,
            bl:gety() + height
        )
        geometry.rectanglebltr(cell, layer, plbl, pltr)
        local netname = netnames[((i - 1) % numnets) + 1]
        table.insert(netshapes, { net = netname, bl = plbl, tr = pltr, layer = layer })
    end
    return netshapes
end

local function _calculate_line_breaks(xy, size, cstart, cstop, blockages)
    local pts = {}
    -- collect all breaks
    local breaks = {}
    for _, b in ipairs(blockages) do
        if 
            xy + size > b.c1 and xy < b.c2
        then
            table.insert(breaks, { start = b.start, stop = b.stop })
        end
    end
    -- process overlaps and insert line points
    table.sort(breaks, function(lhs, rhs) return lhs.start < rhs.start end)
    local i = 1
    local lastc = cstart
    while i <= #breaks do
        local start = breaks[i].start
        local stop = breaks[i].stop
        for j = i + 1, #breaks do
            if breaks[j].start < stop then
                if breaks[j].stop > stop then
                    stop = breaks[j].stop
                end
                i = i + 1
            else
                break
            end
        end
        i = i + 1
        table.insert(pts, {
            c1 = lastc,
            c2 = start
        })
        lastc = stop
    end
    -- add last point, also solves the case when there are no blockages
    table.insert(pts, {
        c1 = lastc,
        c2 = cstop
    })
    return pts
end

function M.place_vlines(cell, bl, tr, layer, width, space, minheight, netnames, excludes)
    check.set_next_function_name("layouthelpers.place_hlines_excludes")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", bl, point.is_point)
    check.arg_optional(4, "layer", "userdata", layer)
    check.arg(5, "width", "number", width)
    check.arg(6, "space", "number", space)
    check.arg(7, "minheight", "number", minheight)
    check.arg_optional(8, "netnames", "table", netnames)
    check.arg_optional(9, "excludes", "table", excludes)
    local netshapes = {}
    local stop = tr:getx()
    local totalwidth = point.xdistance_abs(tr, bl);
    local offset = (totalwidth - totalwidth // (width + space) * (width + space) + space) / 2;
    local netcounter = 1
    -- find line blockages
    local blockages = {}
    if excludes then
        for _, exclude in ipairs(excludes) do
            if util.is_rectilinear_polygon(exclude) then
                local excluderects = util.split_rectilinear_polygon(exclude)
                for _, rect in ipairs(excluderects) do
                    table.insert(blockages, {
                        c1      = math.min(rect.pt1:getx(), rect.pt2:getx()),
                        c2      = math.max(rect.pt1:getx(), rect.pt2:getx()),
                        start   = math.min(rect.pt1:gety(), rect.pt2:gety()),
                        stop    = math.max(rect.pt1:gety(), rect.pt2:gety()),
                    })
                end
            else
                table.insert(blockages, {
                    c1      = util.polygon_xmin(exclude),
                    c2      = util.polygon_xmax(exclude),
                    start   = util.polygon_ymin(exclude),
                    stop    = util.polygon_ymax(exclude)
                })
            end
        end
    end
    local x = bl:getx() + offset
    while x < stop do
        local ypts = _calculate_line_breaks(x, width, bl:gety(), tr:gety(), blockages)
        for _, pt in ipairs(ypts) do
            -- clip to boundary
            pt.c1 = math.max(pt.c1, bl:gety())
            pt.c2 = math.min(pt.c2, tr:gety())
            -- check for illegal (out-of-range) points
            if
                pt.c1 < pt.c2 and
                (pt.c2 - pt.c1) > minheight then
                local plbl = point.create(
                    x,
                    pt.c1
                )
                local pltr = point.create(
                    x + width,
                    pt.c2
                )
                geometry.rectanglebltr(cell, layer, plbl, pltr)
                if netnames then
                    local numnets = #netnames
                    local netname = netnames[((netcounter - 1) % numnets) + 1]
                    table.insert(netshapes, { net = netname, bl = plbl, tr = pltr, layer = layer })
                end
            end
        end
        x = x + width + space
        netcounter = netcounter + 1
    end
    return netshapes
end


function M.place_hlines_numsets(cell, bl, tr, layer, height, netnames, numsets)
    local numnets = #netnames
    local width, height, space, offset, numlines = geometry.rectanglehlines_numlines_height_settings(
        bl, tr,
        numnets * numsets, height
    )
    if space < 0 then
        error("layouthelpers.place_hlines_numsets: the given lines constraints yield a negative line spacing. Increase the area size, or decrease the number of lines and/or the line height")
    end
    local netshapes = {}
    for i = 1, numlines do
        local plbl = point.create(
            bl:getx(),
            bl:gety() + offset + (i - 1) * (height + space)
        )
        local pltr = point.create(
            bl:getx() + width,
            bl:gety() + offset + (i - 1) * (height + space) + height
        )
        geometry.rectanglebltr(cell, layer, plbl, pltr)
        local netname = netnames[((i - 1) % numnets) + 1]
        table.insert(netshapes, { net = netname, bl = plbl, tr = pltr, layer = layer })
    end
    return netshapes
end

function M.place_hlines(cell, bl, tr, layer, height, space, minwidth, netnames, excludes)
    check.set_next_function_name("layouthelpers.place_hlines_excludes")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", bl, point.is_point)
    check.arg_optional(4, "layer", "userdata", layer)
    check.arg(5, "height", "number", height)
    check.arg(6, "space", "number", space)
    check.arg(7, "minwidth", "number", minwidth)
    check.arg_optional(8, "netnames", "table", netnames)
    check.arg_optional(9, "excludes", "table", excludes)
    local netshapes = {}
    local stop = tr:gety()
    local totalheight = point.ydistance_abs(tr, bl);
    local offset = (totalheight - totalheight // (height + space) * (height + space) + space) / 2;
    local netcounter = 1
    -- find line blockages
    local blockages = {}
    if excludes then
        for _, exclude in ipairs(excludes) do
            table.insert(blockages, {
                start   = util.polygon_xmin(exclude),
                stop    = util.polygon_xmax(exclude),
                c1      = util.polygon_ymin(exclude),
                c2      = util.polygon_ymax(exclude)
            })
        end
    end
    local y = bl:gety() + offset
    while y < stop do
        local xpts = _calculate_line_breaks(y, height, bl:getx(), tr:getx(), blockages)
        for _, pt in ipairs(xpts) do
            -- clip to boundary
            pt.c1 = math.max(pt.c1, bl:getx())
            pt.c2 = math.min(pt.c2, tr:getx())
            -- check for illegal (out-of-range) points
            if 
                pt.c1 < pt.c2 and
                pt.c2 - pt.c1 >= minwidth then
                local plbl = point.create(
                    pt.c1,
                    y
                )
                local pltr = point.create(
                    pt.c2,
                    y + height
                )
                geometry.rectanglebltr(cell, layer, plbl, pltr)
                if netnames then
                    local numnets = #netnames
                    local netname = netnames[((netcounter - 1) % numnets) + 1]
                    table.insert(netshapes, { net = netname, bl = plbl, tr = pltr, layer = layer })
                end
            end
        end
        y = y + height + space
        netcounter = netcounter + 1
    end
    return netshapes
end

function M.place_vias(cell, netshapes1, netshapes2, excludes, netfilter, onlyfull, nocheck)
    check.set_next_function_name("layouthelpers.place_vias")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg(2, "netshapes1", "table", netshapes1)
    check.arg(3, "netshapes2", "table", netshapes2)
    check.arg_optional(4, "excludes", "table", excludes)
    check.arg_optional(5, "netfilter", "table", netfilter)
    check.arg_optional(6, "onlyfull", "boolean", onlyfull)
    check.arg_optional(7, "nocheck", "boolean", nocheck)
    excludes = excludes or {}
    for i1 = 1, #netshapes1 do
        local connect = true
        if netfilter then
            if not util.any_of(netshapes1[i1].net, netfilter) then
                connect = false
            end
        end
        if connect then
            for i2 = 1, #netshapes2 do
                if netshapes1[i1].net == netshapes2[i2].net then
                    local r = util.rectangle_intersection(
                        netshapes1[i1].bl, netshapes1[i1].tr,
                        netshapes2[i2].bl, netshapes2[i2].tr,
                        onlyfull
                    )
                    if r then
                        local metal1 = technology.metal_layer_to_index(netshapes1[i1].layer)
                        local metal2 = technology.metal_layer_to_index(netshapes2[i2].layer)
                        local create = nocheck or geometry.check_viabltr(metal1, metal2, r.bl, r.tr)
                        for _, exclude in ipairs(excludes) do
                            if util.rectangle_intersects_polygon(r, exclude) then
                                create = false
                                break
                            end
                        end
                        if create then
                            geometry.viabltr(cell, metal1, metal2, r.bl, r.tr)
                            -- FIXME: don't put every via in the excludes table, this slows down this function
                            --        calculate a bit more intelligently which excludes are required (look at overlaps).
                            table.insert(excludes, util.rectangle_to_polygon(r.bl, r.tr))
                        end
                    end
                end
            end
        end
    end
end

function M.place_unequal_net_vias(cell, netshapes1, netshapes2, onlyfull, nocheck)
    check.set_next_function_name("layouthelpers.place_unequal_vias")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg(2, "netshapes1", "table", netshapes1)
    check.arg(3, "netshapes2", "table", netshapes2)
    check.arg_optional(4, "onlyfull", "boolean", onlyfull)
    check.arg_optional(5, "nocheck", "boolean", nocheck)
    for i1 = 1, #netshapes1 do
        for i2 = 1, #netshapes2 do
            local r = util.rectangle_intersection(
                netshapes1[i1].bl, netshapes1[i1].tr,
                netshapes2[i2].bl, netshapes2[i2].tr,
                onlyfull
            )
            if r then
                local metal1 = technology.metal_layer_to_index(netshapes1[i1].layer)
                local metal2 = technology.metal_layer_to_index(netshapes2[i2].layer)
                local create = nocheck or geometry.check_viabltr(metal1, metal2, r.bl, r.tr)
                if create then
                    geometry.viabltr(cell, metal1, metal2, r.bl, r.tr)
                end
            end
        end
    end
end

function M.place_guardring(cell, bl, tr, xspace, yspace, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_guardring")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg(4, "xspace", "number", xspace)
    check.arg(5, "yspace", "number", yspace)
    check.arg_optional(6, "anchorprefix", "string", anchorprefix)
    check.arg_optional(7, "options", "table", options)
    check.reset_function_name()
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
            holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
        })
    )
    guardring:move_point(guardring:get_area_anchor("innerboundary").bl, bl)
    guardring:translate(-xspace, -yspace)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    if anchorprefix then
        cell:inherit_all_anchors_with_prefix(guardring, anchorprefix)
    end
end

function M.place_guardring_quantized(cell, bl, tr, xspace, yspace, basexsize, baseysize, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_guardring")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg(4, "xspace", "number", xspace)
    check.arg(5, "yspace", "number", yspace)
    check.arg(6, "basexsize", "number", basexsize)
    check.arg(7, "baseysize", "number", baseysize)
    check.arg_optional(8, "anchorprefix", "string", anchorprefix)
    check.arg_optional(9, "options", "table", options)
    check.reset_function_name()
    local targetwidth = point.xdistance_abs(bl, tr)
    local targetheight = point.ydistance_abs(bl, tr)
    local holewidth = util.fix_to_grid_abs_higher(targetwidth + 2 * xspace, basexsize)
    local holeheight = util.fix_to_grid_abs_higher(targetheight + 2 * yspace, baseysize)
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = holewidth,
            holeheight = holeheight,
        })
    )
    guardring:move_point(guardring:get_area_anchor("innerboundary").bl, bl)
    guardring:translate_x(-(holewidth - targetwidth) / 2)
    guardring:translate_y(-(holeheight - targetheight) / 2)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    if anchorprefix then
        cell:inherit_all_anchors_with_prefix(guardring, anchorprefix)
    end
end

function M.place_guardring_with_hole(cell, bl, tr, holebl, holetr, xspace, yspace, wellxoffset, wellyoffset, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_guardring_with_hole")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg_func(4, "holebl", "point", holebl, point.is_point)
    check.arg_func(5, "holetr", "point", holetr, point.is_point)
    check.arg(6, "xspace", "number", xspace)
    check.arg(7, "yspace", "number", yspace)
    check.arg(8, "wellxoffset", "number", wellxoffset)
    check.arg(9, "wellyoffset", "number", wellyoffset)
    check.arg_optional(10, "anchorprefix", "string", anchorprefix)
    check.arg_optional(11, "options", "table", options)
    check.reset_function_name()
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
            holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
            fillwell = true,
            fillwelldrawhole = true,
            fillwellholeoffsettop = yspace - point.ydistance(holetr, tr) - wellyoffset,
            fillwellholeoffsetbottom = yspace - point.ydistance(bl, holebl) - wellyoffset,
            fillwellholeoffsetleft = xspace - point.xdistance(bl, holebl) - wellxoffset,
            fillwellholeoffsetright = xspace - point.xdistance(holetr, tr) - wellxoffset,
        })
    )
    guardring:move_point(guardring:get_area_anchor("innerboundary").bl, bl)
    guardring:translate(-xspace, -yspace)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    if anchorprefix then
        cell:inherit_all_anchors_with_prefix(guardring, anchorprefix)
    end
end

function M.place_guardring_with_hole_quantized(cell, bl, tr, holebl, holetr, xspace, yspace, basexsize, baseysize, wellxoffset, wellyoffset, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_guardring_with_hole")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg_func(4, "holebl", "point", holebl, point.is_point)
    check.arg_func(5, "holetr", "point", holetr, point.is_point)
    check.arg(6, "xspace", "number", xspace)
    check.arg(7, "yspace", "number", yspace)
    check.arg(8, "basexsize", "number", basexsize)
    check.arg(9, "baseysize", "number", baseysize)
    check.arg(10, "wellxoffset", "number", wellxoffset)
    check.arg(11, "wellyoffset", "number", wellyoffset)
    check.arg_optional(12, "anchorprefix", "string", anchorprefix)
    check.arg_optional(13, "options", "table", options)
    check.reset_function_name()
    local targetwidth = point.xdistance_abs(bl, tr)
    local targetheight = point.ydistance_abs(bl, tr)
    local holewidth = util.fix_to_grid_abs_higher(targetwidth + 2 * xspace, basexsize)
    local holeheight = util.fix_to_grid_abs_higher(targetheight + 2 * yspace, baseysize)
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = holewidth,
            holeheight = holeheight,
            fillwell = true,
            fillwelldrawhole = true,
            fillwellholeoffsettop = (holeheight - targetheight) / 2 - point.ydistance(holetr, tr) - wellyoffset,
            fillwellholeoffsetbottom = (holeheight - targetheight) / 2 - point.ydistance(bl, holebl) - wellyoffset,
            fillwellholeoffsetleft = (holewidth - targetwidth) / 2 - point.xdistance(bl, holebl) - wellxoffset,
            fillwellholeoffsetright = (holewidth - targetwidth) / 2 - point.xdistance(holetr, tr) - wellxoffset,
        })
    )
    guardring:move_point(guardring:get_area_anchor("innerboundary").bl, bl)
    guardring:translate(-(holewidth - targetwidth) / 2, -(holeheight - targetheight) / 2)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    if anchorprefix then
        cell:inherit_all_anchors_with_prefix(guardring, anchorprefix)
    end
end

function M.place_double_guardring(cell, bl, tr, xspace, yspace, innercontype, anchorprefix1, anchorprefix2, options)
    check.set_next_function_name("layouthelpers.place_double_guardring")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg(4, "xspace", "number", xspace)
    check.arg(5, "yspace", "number", yspace)
    check.arg(6, "innercontype", "string", innercontype)
    check.arg_optional(7, "anchorprefix1", "string", anchorprefix1)
    check.arg_optional(8, "anchorprefix2", "string", anchorprefix2)
    check.arg(9, "options", "table", options)
    check.reset_function_name()
    if not options.ringwidth then
        error("layouthelpers.place_double_guardring: options table must contain 'ringwidth'")
    end
    local guardring1 = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            contype = innercontype,
            holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
            holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
            wellouterextension = xspace / 2,
            soiopenouterextension = xspace / 2,
            implantouterextension = xspace / 2,
            fillwell = true,
        })
    )
    guardring1:move_point(guardring1:get_area_anchor("innerboundary").bl, bl)
    guardring1:translate(-xspace, -yspace)
    cell:merge_into(guardring1)
    cell:inherit_alignment_box(guardring1)
    if anchorprefix1 then
        cell:inherit_all_anchors_with_prefix(guardring1, anchorprefix1)
    end
    local guardring2 = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            contype = innercontype == "n" and "p" or "n",
            holewidth = point.xdistance_abs(bl, tr) + 4 * xspace + 2 * options.ringwidth,
            holeheight = point.ydistance_abs(bl, tr) + 4 * yspace + 2 * options.ringwidth,
            wellinnerextension = xspace / 2,
            soiopeninnerextension = xspace / 2,
            implantinnerextension = xspace / 2,
            fillwell = false,
            drawdeepwell = true,
            deepwelloffset = options.deepwelloffset
        })
    )
    guardring2:move_point(guardring2:get_area_anchor("innerboundary").bl, bl)
    guardring2:translate(-2 * xspace - options.ringwidth, -2 * yspace - options.ringwidth)
    cell:merge_into(guardring2)
    cell:inherit_alignment_box(guardring2)
    if anchorprefix2 then
        cell:inherit_all_anchors_with_prefix(guardring2, anchorprefix2)
    end
end

function M.place_welltap(cell, bl, tr, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_welltap")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg_optional(4, "anchorprefix", "string", anchorprefix)
    check.arg_optional(5, "options", "table", options)
    check.reset_function_name()
    local welltap = pcell.create_layout(
        "auxiliary/welltap",
        "_welltap",
        util.add_options(options or {}, {
            width = point.xdistance_abs(bl, tr),
            height = point.ydistance_abs(bl, tr),
        })
    )
    welltap:move_point(welltap:get_area_anchor("boundary").bl, bl)
    cell:merge_into(welltap)
    cell:inherit_alignment_box(welltap)
    if anchorprefix then
        cell:inherit_all_anchors_with_prefix(welltap, anchorprefix)
    end
end

--[[
function M.place_maximum_width_via(cell, startmetal, endmetal, bl, tr)
    local regionwidth = point.xdistance_abs(bl, tr)
    local regionheight = point.ydistance_abs(bl, tr)
    if regionwidth > regionheight then
        for m = startmetal, endmetal - 1 do
            local lowerwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m), regionheight)
            local upperwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m + 1), regionheight)
            local numregions = 1
            while regionheight / (2 * (numregions - 1) + 1) > lowerwidth do
                numregions = numregions + 1
            end
            local width = regionheight // (2 * (numregions - 1) + 1)
            local space = numregions > 1 and ((regionheight - numregions * width) // (numregions - 1)) or 0
            for i = 1, numregions do
                geometry.viabltr(cell, m, m + 1,
                    bl:copy():translate_y((i - 1) * (width + space)),
                    point.combine_12(tr, bl):translate_y((i - 1) * (width + space) + width)
                )
            end
        end
    else
        for m = startmetal, endmetal - 1 do
            local lowerwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m), regionwidth)
            local upperwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m + 1), regionwidth)
            local numregions = 1
            while regionwidth / (2 * (numregions - 1) + 1) > lowerwidth do
                numregions = numregions + 1
            end
            local width = regionwidth // (2 * (numregions - 1) + 1)
            local space = numregions > 1 and ((regionwidth - numregions * width) // (numregions - 1)) or 0
            for i = 1, numregions do
                geometry.viabltr(cell, m, m + 1,
                    bl:copy():translate_x((i - 1) * (width + space)),
                    point.combine_12(bl, tr):translate_x((i - 1) * (width + space) + width)
                )
            end
        end
    end
end
--]]

function M.place_maximum_width_via(cell, firstmetal, lastmetal, pt1, pt2)
    geometry.rectanglepoints(cell, generics.special(), pt1, pt2)
    local regionwidth = point.xdistance_abs(pt1, pt2)
    local regionheight = point.ydistance_abs(pt1, pt2)
    local xsign = point.xdistance(pt1, pt2) > 0 and -1 or 1
    local ysign = point.ydistance(pt1, pt2) > 0 and -1 or 1
    if regionwidth > regionheight then
        for m = firstmetal, lastmetal - 1 do
            local lowerwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m), regionheight)
            local upperwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m + 1), regionheight)
            local numregions = 1
            while regionheight / (2 * (numregions - 1) + 1) > lowerwidth do
                numregions = numregions + 1
            end
            local width = regionheight // (2 * (numregions - 1) + 1)
            local space = numregions > 1 and ((regionheight - numregions * width) // (numregions - 1)) or 0
            for i = 1, 1 do
                if ysign < 0 then
                    if xsign < 0 then
                        geometry.viabltr(cell, m, m + 1,
                            point.combine_12(pt2, pt1):translate_y(-(i - 1) * (width + space) - width),
                            pt1:copy():translate_y(-(i - 1) * (width + space))
                        )
                    else
                        geometry.viabltr(cell, m, m + 1,
                            pt1:copy():translate_y(-(i - 1) * (width + space) - width),
                            point.combine_12(pt2, pt1):translate_y(-(i - 1) * (width + space))
                        )
                    end
                else
                    if xsign < 0 then
                        geometry.viabltr(cell, m, m + 1,
                            point.combine_12(pt2, pt1):translate_y((i - 1) * (width + space)),
                            pt1:copy():translate_y((i - 1) * (width + space) + width)
                        )
                    else
                        geometry.viabltr(cell, m, m + 1,
                            pt1:copy():translate_y((i - 1) * (width + space)),
                            point.combine_12(pt2, pt1):translate_y((i - 1) * (width + space) + width)
                        )
                    end
                end
            end
        end
    else
        for m = firstmetal, lastmetal - 1 do
            local lowerwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m), regionwidth)
            local upperwidth = technology.get_optional_dimension(string.format("Maximum M%d Width", m + 1), regionwidth)
            local numregions = 1
            while regionwidth / (2 * (numregions - 1) + 1) > lowerwidth do
                numregions = numregions + 1
            end
            local width = regionwidth // (2 * (numregions - 1) + 1)
            local space = numregions > 1 and ((regionwidth - numregions * width) // (numregions - 1)) or 0
            for i = 1, 1 do
                if xsign < 0 then
                    if ysign < 0 then
                        geometry.viabltr(cell, m, m + 1,
                            pt1:copy():translate_x(-1 * (i - 1) * (width + space) - width),
                            point.combine_12(pt1, pt2):translate_x(-1 * (i - 1) * (width + space))
                        )
                    else
                        geometry.viabltr(cell, m, m + 1,
                            pt1:copy():translate_x(-1 * (i - 1) * (width + space) - width),
                            point.combine_12(pt1, pt2):translate_x(-1 * (i - 1) * (width + space))
                        )
                    end
                else
                    if ysign < 0 then
                        geometry.viabltr(cell, m, m + 1,
                            pt1:copy():translate_x((i - 1) * (width + space)),
                            point.combine_12(pt1, pt2):translate_x((i - 1) * (width + space) + width)
                        )
                    else
                        geometry.viabltr(cell, m, m + 1,
                            pt1:copy():translate_x((i - 1) * (width + space)),
                            point.combine_12(pt1, pt2):translate_x((i - 1) * (width + space) + width)
                        )
                    end
                end
            end
        end
    end
end

function M.place_coplanar_waveguide(cell, layer, pts, swidth, gwidth, sep)
    local gnd1pts = geometry.get_side_path_points(pts, swidth / 2 + sep + gwidth / 2)
    local gnd2pts = geometry.get_side_path_points(pts, -swidth / 2 - sep - gwidth / 2)
    geometry.path_polygon(cell, layer, pts, swidth)
    geometry.path_polygon(cell, layer, gnd1pts, gwidth)
    geometry.path_polygon(cell, layer, gnd2pts, gwidth)
end

function M.place_stripline(cell, signalmetal, pts, swidth, gwidth)
    local m = technology.resolve_metal(signalmetal)
    if m == 1 then
        error(string.format("layouthelpers.place_stripline: the signal metal index must be higher than 1, got: %d"))
    end
    if m == technology.resolve_metal(-1) then
        error(string.format("layouthelpers.place_stripline: the signal metal index can't be the highest metal, got: %d"))
    end
    geometry.path_polygon(cell, generics.metal(signalmetal - 1), pts, gwidth)
    geometry.path_polygon(cell, generics.metal(signalmetal), pts, swidth)
    geometry.path_polygon(cell, generics.metal(signalmetal + 1), pts, gwidth)
end

function M.collect_gridlines(t, cells, anchorname)
    for _, cell in ipairs(cells) do
        local bl = cell:get_area_anchor(anchorname).bl
        local tr = cell:get_area_anchor(anchorname).tr
        local found = false
        for _, line in ipairs(t) do
            local union = util.rectangle_union(bl, tr, line.bl, line.tr)
            if union then
                found = true
                line.bl = union.bl
                line.tr = union.tr
            end
        end
        if not found then
            table.insert(t, { bl = bl:copy(), tr = tr:copy() })
        end
    end
end

function M.annotate_netshapes(cell, netshapes, sizehint)
    for _, netshape in ipairs(netshapes) do
        local blx = netshape.bl:getx()
        local bly = netshape.bl:gety()
        local trx = netshape.tr:getx()
        local try = netshape.tr:gety()
        cell:add_label(netshape.net, netshape.layer, point.create(blx, bly), sizehint)
        cell:add_label(netshape.net, netshape.layer, point.create(blx, try), sizehint)
        cell:add_label(netshape.net, netshape.layer, point.create(trx, bly), sizehint)
        cell:add_label(netshape.net, netshape.layer, point.create(trx, try), sizehint)
    end
end

return M
