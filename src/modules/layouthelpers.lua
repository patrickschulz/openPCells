local M = {}

function M.connect_area_anchor(cell, layer, width, anchor1, anchor2)
    local x1l, y1b = anchor1.bl:unwrap()
    local x1r, y1t = anchor1.tr:unwrap()
    local x2l, y2b = anchor2.bl:unwrap()
    local x2r, y2t = anchor2.tr:unwrap()
    if y2b > y1t then
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

function M.place_vlines(cell, bl, tr, layer, width, space, netnames)
    check.set_next_function_name("layouthelpers.place_vlines")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", bl, point.is_point)
    check.arg_optional(4, "layer", "userdata", layer)
    check.arg(5, "width", "number", width)
    check.arg(6, "space", "number", space)
    check.arg_optional(7, "netnames", "table", netnames)
    local width, height, space, offset, numlines = geometry.rectanglevlines_width_space_settings(
        bl, tr,
        width, space
    )
    if space < 0 then
        error("layouthelpers.place_vlines: the given lines constraints yield a negative line spacing. Increase the area size, or decrease the the line width/space")
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
        if netnames then
            local numnets = #netnames
            local netname = netnames[((i - 1) % numnets) + 1]
            table.insert(netshapes, { net = netname, bl = plbl, tr = pltr, layer = layer })
        end
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

function M.place_hlines(cell, bl, tr, layer, height, space, netnames)
    check.set_next_function_name("layouthelpers.place_hlines")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", bl, point.is_point)
    check.arg_optional(4, "layer", "userdata", layer)
    check.arg(5, "height", "number", height)
    check.arg(6, "space", "number", space)
    check.arg_optional(7, "netnames", "table", netnames)
    local width, height, space, offset, numlines = geometry.rectanglehlines_height_space_settings(
        bl, tr,
        height, space
    )
    if numlines < 1 then
        error("layouthelpers.place_hlines: the given lines constraints yield no placeable lines. Increase the area size, or decrease the line height/space")
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
        if netnames then
            local numnets = #netnames
            local netname = netnames[((i - 1) % numnets) + 1]
            table.insert(netshapes, { net = netname, bl = plbl, tr = pltr, layer = layer })
        end
    end
    return netshapes
end

function M.place_vias(cell, metal1, metal2, netshapes1, netshapes2, netfilter, allowfail)
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
                        netshapes2[i2].bl, netshapes2[i2].tr
                    )
                    if r then
                        if allowfail then
                            if geometry.check_viabltr(metal1, metal2, r.bl, r.tr) then
                                geometry.viabltr(cell, metal1, metal2, r.bl, r.tr)
                            end
                        else
                            geometry.viabltr(cell, metal1, metal2, r.bl, r.tr)
                        end
                    end
                end
            end
        end
    end
end

function M.place_unequal_net_vias(cell, metal1, metal2, netshapes1, netshapes2, allowfail)
    for i1 = 1, #netshapes1 do
        for i2 = 1, #netshapes2 do
            local r = util.rectangle_intersection(
                netshapes1[i1].bl, netshapes1[i1].tr,
                netshapes2[i2].bl, netshapes2[i2].tr
            )
            if r then
                if allowfail then
                    if geometry.check_viabltr(metal1, metal2, r.bl, r.tr) then
                        geometry.viabltr(cell, metal1, metal2, r.bl, r.tr)
                    end
                else
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
        cell:inherit_area_anchor_as(guardring, "outerboundary", string.format("%souterboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerboundary", string.format("%sinnerboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerwell", string.format("%souterwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerwell", string.format("%sinnerwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerimplant", string.format("%souterimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerimplant", string.format("%sinnerimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outersoiopen", string.format("%soutersoiopen", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innersoiopen", string.format("%sinnersoiopen", anchorprefix))
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
        cell:inherit_area_anchor_as(guardring, "outerboundary", string.format("%souterboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerboundary", string.format("%sinnerboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerwell", string.format("%souterwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerwell", string.format("%sinnerwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerimplant", string.format("%souterimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerimplant", string.format("%sinnerimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outersoiopen", string.format("%soutersoiopen", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innersoiopen", string.format("%sinnersoiopen", anchorprefix))
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
        cell:inherit_area_anchor_as(guardring, "outerboundary", string.format("%souterboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerboundary", string.format("%sinnerboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerwell", string.format("%souterwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerwell", string.format("%sinnerwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerimplant", string.format("%souterimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerimplant", string.format("%sinnerimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outersoiopen", string.format("%soutersoiopen", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innersoiopen", string.format("%sinnersoiopen", anchorprefix))
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
        cell:inherit_area_anchor_as(guardring, "outerboundary", string.format("%souterboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerboundary", string.format("%sinnerboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerwell", string.format("%souterwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerwell", string.format("%sinnerwell", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outerimplant", string.format("%souterimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerimplant", string.format("%sinnerimplant", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "outersoiopen", string.format("%soutersoiopen", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innersoiopen", string.format("%sinnersoiopen", anchorprefix))
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
        cell:inherit_area_anchor_as(guardring1, "outerboundary", string.format("%souterboundary", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "innerboundary", string.format("%sinnerboundary", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "outerwell", string.format("%souterwell", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "innerwell", string.format("%sinnerwell", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "outerimplant", string.format("%souterimplant", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "innerimplant", string.format("%sinnerimplant", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "outersoiopen", string.format("%soutersoiopen", anchorprefix1))
        cell:inherit_area_anchor_as(guardring1, "innersoiopen", string.format("%sinnersoiopen", anchorprefix1))
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
        cell:inherit_area_anchor_as(guardring2, "outerboundary", string.format("%souterboundary", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "innerboundary", string.format("%sinnerboundary", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "outerwell", string.format("%souterwell", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "innerwell", string.format("%sinnerwell", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "outerimplant", string.format("%souterimplant", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "innerimplant", string.format("%sinnerimplant", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "outersoiopen", string.format("%soutersoiopen", anchorprefix2))
        cell:inherit_area_anchor_as(guardring2, "innersoiopen", string.format("%sinnersoiopen", anchorprefix2))
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
        cell:inherit_area_anchor_as(welltap, "boundary", string.format("%sboundary", anchorprefix))
        cell:inherit_area_anchor_as(welltap, "well", string.format("%swell", anchorprefix))
        cell:inherit_area_anchor_as(welltap, "implant", string.format("%simplant", anchorprefix))
        cell:inherit_area_anchor_as(welltap, "soiopen", string.format("%ssoiopen", anchorprefix))
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

return M
