local M = {}

function M.place_bus(cell, layer, pathpoints, numbits, width, space)
    for i = 1, numbits do
        local pts = util.transform_points(pathpoints, function(pt) pt:translate_x((i - 1 - (numbits - 1) / 2) * (width + space)) end)
        geometry.path(cell, layer, pts, width)
    end
end

function M.place_guardring(cell, bl, tr, xspace, yspace, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_guardring")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg(4, "xspace", "number", xspace)
    check.arg(5, "yspace", "number", yspace)
    check.arg(6, "anchorprefix", "string", anchorprefix)
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
    end
end

function M.place_guardring_with_hole(cell, bl, tr, holebl, holetr, xspace, yspace, welloffset, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_guardring_with_hole")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg_func(4, "holebl", "point", holebl, point.is_point)
    check.arg_func(5, "holetr", "point", holetr, point.is_point)
    check.arg(6, "xspace", "number", xspace)
    check.arg(7, "yspace", "number", yspace)
    check.arg(8, "anchorprefix", "string", anchorprefix)
    check.arg_optional(9, "options", "table", options)
    check.reset_function_name()
    local guardring = pcell.create_layout(
        "auxiliary/guardring",
        "_guardring",
        util.add_options(options or {}, {
            holewidth = point.xdistance_abs(bl, tr) + 2 * xspace,
            holeheight = point.ydistance_abs(bl, tr) + 2 * yspace,
            fillwell = true,
            fillwelldrawhole = true,
            fillwellholeoffsettop = yspace - point.ydistance(holetr, tr) - welloffset,
            fillwellholeoffsetbottom = yspace - point.ydistance(bl, holebl) - welloffset,
            fillwellholeoffsetleft = xspace - point.xdistance(bl, holebl) - welloffset,
            fillwellholeoffsetright = xspace - point.xdistance(holetr, tr) - welloffset,
        })
    )
    guardring:move_point(guardring:get_area_anchor("innerboundary").bl, bl)
    guardring:translate(-xspace, -yspace)
    cell:merge_into(guardring)
    cell:inherit_alignment_box(guardring)
    if anchorprefix then
        cell:inherit_area_anchor_as(guardring, "outerboundary", string.format("%souterboundary", anchorprefix))
        cell:inherit_area_anchor_as(guardring, "innerboundary", string.format("%sinnerboundary", anchorprefix))
    end
end

function M.place_welltap(cell, bl, tr, anchorprefix, options)
    check.set_next_function_name("layouthelpers.place_welltap")
    check.arg_func(1, "cell", "object", cell, object.is_object)
    check.arg_func(2, "bl", "point", bl, point.is_point)
    check.arg_func(3, "tr", "point", tr, point.is_point)
    check.arg(4, "anchorprefix", "string", anchorprefix)
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
    cell:inherit_area_anchor_as(welltap, "boundary", string.format("%sboundary", anchorprefix))
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

return M
