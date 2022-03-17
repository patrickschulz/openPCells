local arrayzation_strategies = {
    fit = function(size, cutsize, space, encl)
        local xrep = math.floor((size + space - 2 * encl) / (cutsize + space))
        return xrep, space
    end,
    continuous = function(size, cutsize, minspace, enclosure)
        local Nres
        for N = 1, math.huge do
            if size % N == 0 then
                local S = size / N - cutsize
                if S < minspace then
                    break
                end
                if S % 2 == 0 then
                    Nres = N
                end
            end
        end
        if Nres then
            return Nres, size / Nres - cutsize
        end
    end,
    continuous_half = function(size, cutsize, minspace)
        local Nres
        for N = 1, math.huge do
            if size % (N + 1) == 0 then
                local S = size / (N + 1) - cutsize
                if S < minspace then
                    break
                end
                if S % 2 == 0 then
                    Nres = N
                end
            end
        end
        if Nres then
            return Nres, size / (Nres + 1) - cutsize
        end
    end
}

function geometry.get_rectangular_arrayzation(regionwidth, regionheight, definitions, options)
    local xstrat = arrayzation_strategies[options.xcontinuous and "continuous" or "fit"]
    local ystrat = arrayzation_strategies[options.ycontinuous and "continuous" or "fit"]

    local idx
    local lastarea
    local xrep, yrep
    local xspace, yspace
    for i, entry in ipairs(definitions.entries) do
        local _xrep, _xspace = xstrat(regionwidth, entry.width, entry.xspace, entry.xenclosure)
        local _yrep, _yspace = ystrat(regionheight, entry.height, entry.yspace, entry.yenclosure)
        if (_xrep and _xrep > 0) and (_yrep and _yrep > 0) then
            local area = (_xrep + _yrep) * entry.width * entry.height
            if not idx or area > lastarea then
                idx = i
                lastarea = area
                xrep = _xrep
                yrep = _yrep
                xspace = _xspace
                yspace = _yspace
            end
        end
        --if entry.noneedtofit then
        --    xrep = math.max(1, xrep)
        --    yrep = math.max(1, yrep)
        --end
    end
    if not idx then
        if definitions.fallback then
            return {
                width = definitions.fallback.width,
                height = definitions.fallback.height,
                xpitch = 0,
                ypitch = 0,
                xrep = 1,
                yrep = 1,
            }
        else
            print("could not fit via, the shape will be ignored. The layout will most likely not be correct.")
            return nil
        end
    end
    return {
        width = definitions.entries[idx].width,
        height = definitions.entries[idx].height,
        xpitch = definitions.entries[idx].width + xspace,
        ypitch = definitions.entries[idx].height + yspace,
        xrep = xrep,
        yrep = yrep,
    }
end

function geometry.via(cell, metal1, metal2, width, height, options)
    geometry.viabltr(cell, metal1, metal2, point.create(-width / 2, -height / 2), point.create(width / 2, height / 2), options)
end

function geometry.viabltr(cell, metal1, metal2, bl, tr, options)
    metal1 = technology.resolve_metal(metal1)
    metal2 = technology.resolve_metal(metal2)
    if metal1 > metal2 then
        metal1, metal2 = metal2, metal1
    end
    local blx, bly = bl:unwrap()
    local trx, try = tr:unwrap()
    local width = trx - blx
    local height = try - bly
    for i = metal1, metal2 - 1 do
        local viadefs = technology.get_via_definitions(i, i + 1)
        local entry = geometry.get_rectangular_arrayzation(width, height, viadefs, options or {})
        if not entry then
            return
        end
        geometry.multiple_xy(
            function(x, y)
                geometry.rectanglebltr(cell, generics.viacut(i, i + 1), 
                    point.create((blx + trx) / 2 - entry.width / 2 + x, (bly + try) / 2 - entry.height / 2 + y), 
                    point.create((blx + trx) / 2 + entry.width / 2 + x, (bly + try) / 2 + entry.height / 2 + y)
                )
            end,
            entry.xrep, entry.yrep, entry.xpitch, entry.ypitch
        )
        geometry.rectanglebltr(cell, generics.metal(i), bl, tr)
        geometry.rectanglebltr(cell, generics.metal(i + 1), bl, tr)
    end
end

function geometry.contact(cell, region, width, height, options)
    geometry.contactbltr(cell, region, point.create(-width / 2, -height / 2), point.create(width / 2, height / 2), options)
end

function geometry.contactbltr(cell, region, bl, tr, options)
    local blx, bly = bl:unwrap()
    local trx, try = tr:unwrap()
    local width = trx - blx
    local height = try - bly
    local contactdefs = technology.get_contact_definitions(region)
    local entry = geometry.get_rectangular_arrayzation(width, height, contactdefs, options or {})
    if not entry then
        return
    end
    geometry.multiple_xy(
        function(x, y)
            geometry.rectanglebltr(cell, generics.contact(region), 
                point.create((blx + trx) / 2 - entry.width / 2 + x, (bly + try) / 2 - entry.height / 2 + y), 
                point.create((blx + trx) / 2 + entry.width / 2 + x, (bly + try) / 2 + entry.height / 2 + y)
            )
        end,
        entry.xrep, entry.yrep, entry.xpitch, entry.ypitch
    )
    geometry.rectanglebltr(cell, generics.metal(1), bl, tr)
end

function geometry.cross(cell, layer, width, height, crosssize)
    modassert(width % 2 == 0, "geometry.cross: width must be a multiple of 2")
    modassert(height % 2 == 0, "geometry.cross: height must be a multiple of 2")
    modassert(crosssize % 2 == 0, "geometry.cross: crosssize must be a multiple of 2")
    local S = shape.create_polygon(layer)
    S:append_xy(    -width / 2, -crosssize / 2)
    S:append_xy(    -width / 2,  crosssize / 2)
    S:append_xy(-crosssize / 2,  crosssize / 2)
    S:append_xy(-crosssize / 2,     height / 2)
    S:append_xy( crosssize / 2,     height / 2)
    S:append_xy( crosssize / 2,  crosssize / 2)
    S:append_xy(     width / 2,  crosssize / 2)
    S:append_xy(     width / 2, -crosssize / 2)
    S:append_xy( crosssize / 2, -crosssize / 2)
    S:append_xy( crosssize / 2,    -height / 2)
    S:append_xy(-crosssize / 2,    -height / 2)
    S:append_xy(-crosssize / 2, -crosssize / 2)
    S:append_xy(    -width / 2, -crosssize / 2) -- close polygon
    cell:add_shape(S)
end

function geometry.ring(cell, layer, width, height, ringwidth)
    modassert((width + ringwidth) % 2 == 0, "geometry.ring: width +- ringwidth must be a multiple of 2")
    modassert((height + ringwidth) % 2 == 0, "geometry.ring: height +- ringwidth must be a multiple of 2")
    local S = shape.create_polygon(layer)
    S:append_xy(-(width + ringwidth) / 2, -(height + ringwidth) / 2)
    S:append_xy( (width + ringwidth) / 2, -(height + ringwidth) / 2)
    S:append_xy( (width + ringwidth) / 2,  (height + ringwidth) / 2)
    S:append_xy(-(width + ringwidth) / 2,  (height + ringwidth) / 2)
    S:append_xy(-(width + ringwidth) / 2, -(height - ringwidth) / 2)
    S:append_xy(-(width - ringwidth) / 2, -(height - ringwidth) / 2)
    S:append_xy(-(width - ringwidth) / 2,  (height - ringwidth) / 2)
    S:append_xy( (width - ringwidth) / 2,  (height - ringwidth) / 2)
    S:append_xy( (width - ringwidth) / 2, -(height - ringwidth) / 2)
    S:append_xy(-(width + ringwidth) / 2, -(height - ringwidth) / 2)
    S:append_xy(-(width + ringwidth) / 2, -(height + ringwidth) / 2) -- close polygon
    cell:add_shape(S)
end

function geometry.unequal_xy_ring(cell, layer, width, height, ringwidth, ringheight)
    modassert((width + ringwidth) % 2 == 0, "geometry.ring: width +- ringwidth must be a multiple of 2")
    modassert((height + ringheight) % 2 == 0, "geometry.ring: height +- ringwidth must be a multiple of 2")
    local S = shape.create_polygon(layer)
    S:append_xy(-(width + ringwidth) / 2, -(height + ringheight) / 2)
    S:append_xy( (width + ringwidth) / 2, -(height + ringheight) / 2)
    S:append_xy( (width + ringwidth) / 2,  (height + ringheight) / 2)
    S:append_xy(-(width + ringwidth) / 2,  (height + ringheight) / 2)
    S:append_xy(-(width + ringwidth) / 2, -(height - ringheight) / 2)
    S:append_xy(-(width - ringwidth) / 2, -(height - ringheight) / 2)
    S:append_xy(-(width - ringwidth) / 2,  (height - ringheight) / 2)
    S:append_xy( (width - ringwidth) / 2,  (height - ringheight) / 2)
    S:append_xy( (width - ringwidth) / 2, -(height - ringheight) / 2)
    S:append_xy(-(width + ringwidth) / 2, -(height - ringheight) / 2)
    S:append_xy(-(width + ringwidth) / 2, -(height + ringheight) / 2) -- close polygon
    cell:add_shape(S)
end

local function _shift_gridded_line(pt1, pt2, width, grid)
    local x1, y1 = pt1:unwrap()
    local x2, y2 = pt2:unwrap()
    local angle = math.atan(y2 - y1, x2 - x1) - math.pi / 2
    local xshift = grid * math.floor(math.floor(width * math.cos(angle) + 0.5) / grid)
    local yshift = grid * math.floor(math.floor(width * math.sin(angle) + 0.5) / grid)
    local spt1 = point.create(x1 + xshift, y1 + yshift)
    local spt2 = point.create(x2 + xshift, y2 + yshift)
    return spt1, spt2
end

local function _get_gridded_edge_segments(pts, width, grid)
    local edges = {}
    -- start to end
    for i = 1, #pts - 1 do
        local spt1, spt2 = _shift_gridded_line(pts[i], pts[i + 1], width / 2, grid)
        table.insert(edges, spt1)
        table.insert(edges, spt2)
    end
    -- end to start (shift in other direction)
    for i = #pts, 2, -1 do
        local spt1, spt2 = _shift_gridded_line(pts[i], pts[i - 1], width / 2, grid)
        table.insert(edges, spt1)
        table.insert(edges, spt2)
    end
    return edges
end

local function _get_any_angle_path_pts(pts, width, grid, miterjoin, allow45)
    local edges = _get_gridded_edge_segments(pts, width, grid)
    local pathpts = _get_path_pts(edges, miterjoin)
    table.insert(pathpts, edges[1]:copy()) -- close path
    local poly = {}
    for i = 1, #pathpts - 1 do
        local linepts = graphics.line(pathpts[i], pathpts[i + 1], grid, allow45)
        for _, pt in ipairs(linepts) do
            table.insert(poly, pt)
        end
    end
    return poly
end

local function _make_unique_points(pts)
    for i = #pts, 2, -1 do -- iterate from the end for in-situ deletion
        if pts[i] == pts[i - 1] then
            table.remove(pts, i)
        end
    end
end

function geometry.path3x(layer, startpt, endpt, width, extension)
    return geometry.path(layer, geometry.path_points_xy(startpt, { endpt }), width, extension)
end

function geometry.path3y(layer, startpt, endpt, width, extension)
    return geometry.path(layer, geometry.path_points_yx(startpt, { endpt }), width, extension)
end

function geometry.path_c_shape(cell, layer, ptstart, ptmiddle, ptend, width, extension)
    geometry.path(cell, layer,
        geometry.path_points_xy(ptstart,
        {
            ptmiddle,
            0,
            ptend,
        }), width
    )
end

function geometry.path_points_xy(startpt, movements)
    local pts = {}
    table.insert(pts, startpt)
    local xnoty = true
    local lastx, lasty = startpt:unwrap()
    for _, mov in ipairs(movements) do
        if is_point(mov) then
            local x, y = mov:unwrap()
            if xnoty then
                table.insert(pts, point.create(x, lasty))
            else
                table.insert(pts, point.create(lastx, y))
            end
            lastx = x
            lasty = y
            xnoty = not xnoty
        else
            if xnoty then
                lastx = lastx + mov
            else
                lasty = lasty + mov
            end
        end
        table.insert(pts, point.create(lastx, lasty))
        xnoty = not xnoty
    end
    return pts
end

function geometry.path_points_yx(startpt, movements)
    local pts = {}
    table.insert(pts, startpt)
    local xnoty = false
    local lastx, lasty = startpt:unwrap()
    for _, mov in ipairs(movements) do
        if is_point(mov) then
            local x, y = mov:unwrap()
            if xnoty then
                table.insert(pts, point.create(x, lasty))
            else
                table.insert(pts, point.create(lastx, y))
            end
            lastx = x
            lasty = y
            xnoty = not xnoty
        else
            if xnoty then
                lastx = lastx + mov
            else
                lasty = lasty + mov
            end
        end
        table.insert(pts, point.create(lastx, lasty))
        xnoty = not xnoty
    end
    return pts
end

function geometry.any_angle_path(cell, layer, pts, width, grid, miterjoin, allow45)
    _make_unique_points(pts)
    local points = _get_any_angle_path_pts(pts, width, grid, miterjoin, allow45)
    local S = shape.create_polygon(layer, points)
    cell:add_shape(S)
end

-- FIXME: rectangular-separated does not work in y direction
-- This could be fixed by using a more general (and cleaner) approach by tweaking the mirroring, not the points
local function _crossing(obj, layer1, layer2, width, dxy, ext, direction, mode, separation)
    local pts = {}
    local append = util.make_insert_xy(pts)
    separation = separation or 0
    if mode == "rectangular" then
        if direction == "x" then
            append(-dxy / 2 - ext, -dxy / 2)
            append(0, -dxy / 2)
            append(0, dxy / 2)
            append( dxy / 2 + ext, dxy / 2)
        elseif direction == "y" then
            append(-dxy / 2, -dxy / 2 - ext)
            append(-dxy / 2, 0)
            append( dxy / 2, 0)
            append( dxy / 2,  dxy / 2 + ext)
        end
    elseif mode == "rectangular-separated" then
        if direction == "x" then
            append(-dxy / 2 - ext,   -dxy / 2)
            append(-separation / 2 - width / 2, -dxy / 2)
            append(-separation / 2 - width / 2,  dxy / 2)
            append( dxy / 2 + ext,   dxy / 2)
        elseif direction == "y" then
            append(-dxy / 2, -dxy / 2 - ext)
            append(-dxy / 2, -separation / 2 - width / 2)
            append( dxy / 2, -separation / 2 - width / 2)
            append( dxy / 2,  dxy / 2 + ext)
        end
    elseif mode == "diagonal" then
        local w2tan8 = math.floor(width * 5741 / 27720) -- rational approximation of tan(pi / 8) == 5741 / 13860
        if direction == "x" then
            if ext > width / 2 * math.tan(math.pi / 8) then
                append(-dxy / 2 - ext, -dxy / 2)
            else
                append(-dxy / 2 - w2tan8, -dxy / 2)
            end
            append(-dxy / 2, -dxy / 2)
            append( dxy / 2,  dxy / 2)
            if ext > width / 2 * math.tan(math.pi / 8) then
                append( dxy / 2 + ext, dxy / 2)
            else
                append( dxy / 2 + w2tan8, dxy / 2)
            end
        elseif direction == "y" then
            if ext > width / 2 * math.tan(math.pi / 8) then
                append(-dxy / 2, -dxy / 2 - ext)
            else
                append(-dxy / 2, -dxy / 2 - w2tan8)
            end
            append(-dxy / 2, -dxy / 2)
            append( dxy / 2,  dxy / 2)
            if ext > width / 2 * math.tan(math.pi / 8) then
                append( dxy / 2,  dxy / 2 + ext)
            else
                append( dxy / 2, dxy / 2 + w2tan8)
            end
        end
    end
    geometry.path(obj, layer1, pts, width, true)
    geometry.path(obj, layer2, util.xmirror(pts), width, true)
    return obj
end

function geometry.crossing(cell, layer1, layer2, width, tl, br, mode)
    aux.assert_one_of("geometry.crossing: mode", mode, "diagonal", "rectangular", "rectangular-separated")
    local tlx, tly = tl:unwrap()
    local brx, bry = br:unwrap()
    local direction
    local dxy
    local ext = (math.abs(brx - tlx) - math.abs(tly - bry)) / 2
    if ext > 0 then
        direction = "x"
        dxy = math.abs(tly - bry)
    else
        direction = "y"
        ext = -ext
        dxy = math.abs(brx - tlx)
    end
    local obj = object.create()
    _crossing(obj, layer1, layer2, width, dxy, ext, direction, mode)
    obj:translate(0, tly - dxy / 2)
    cell:merge_into_shallow(obj)
end

function geometry.path_midpoint(cell, layer, pts, width, method, miterjoin)
    local newpts = {}
    local append = util.make_insert_xy(newpts)
    if method == "halfangle" then
        table.insert(newpts, pts[1])
        for i = 2, #pts - 1 do
            local x0, y0 = pts[i - 1]:unwrap()
            local x1, y1 = pts[i]:unwrap()
            local x2, y2 = pts[i + 1]:unwrap()
            local preangle = math.atan(y1 - y0, x1 - x0)
            local postangle = math.atan(y2 - y1, x2 - x1)
            local factor = 0.6 * math.min(
                math.sqrt((x1 - x0)^2 + (y1 - y0)^2),
                math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
                ) * math.tan(math.pi / 8)
            table.insert(newpts, point.create(x1 - math.floor(factor * math.cos(preangle)), y1 - math.floor(factor * math.sin(preangle))))
            table.insert(newpts, point.create(x1 + math.floor(factor * math.cos(postangle)), y1 + math.floor(factor * math.sin(postangle))))
        end
        table.insert(newpts, pts[#pts])
    elseif method == "rectangularyx" then
        for i = 1, #pts - 1 do
            local x1, y1 = pts[i]:unwrap()
            local _, y2 = pts[i + 1]:unwrap()
            append(x1, y1)
            append(x1, y2)
        end
        append(pts[#pts]:unwrap())
    elseif method == "rectangularxy" then
        for i = 1, #pts - 1 do
            local x1, y1 = pts[i]:unwrap()
            local x2 = pts[i + 1]:unwrap()
            append(x1, y1)
            append(x2, y1)
        end
        append(pts[#pts]:unwrap())
    else
        moderror(string.format("unknown midpoint path method: %s", method))
    end
    return geometry.path(cell, layer, newpts, width, miterjoin)
end

--[[
function geometry.corner(layer, startpt, endpt, width, radius, grid)
    local S = shape.create(layer)
    local dy = endpt.y - startpt.y - radius
    local pathpts = _get_path_pts({ point.create(startpt.x, startpt.y), point.create(startpt.x, endpt.y - radius) }, width)
    S:add_polygon(pathpts)
    pathpts = _get_path_pts({ point.create(startpt.x + radius, endpt.y), point.create(endpt.x, endpt.y) }, width)
    S:add_polygon(pathpts)
    local pts = graphics.quadbezierseg(
        point.create(startpt.x - 0.5 * width, endpt.y - radius),
        point.create(startpt.x + radius, endpt.y + 0.5 * width),
        point.create(startpt.x - 0.5 * width, endpt.y + 0.5 * width),
        grid
    )
    local pts2 = graphics.quadbezierseg(
        point.create(startpt.x + 0.5 * width, endpt.y - radius),
        point.create(startpt.x + radius, endpt.y - 0.5 * width),
        point.create(startpt.x + 0.5 * width, endpt.y - 0.5 * width),
        grid
    )
    pts:merge_append(pts2:reverse())
    S:add_polygon(pts)
    return object.make_from_shape(S)
end
--]]

function geometry.multiple_x(func, xrep, xpitch)
    geometry.multiple_xy(func, xrep, 1, xpitch, 0)
end

function geometry.multiple_y(func, yrep, ypitch)
    geometry.multiple_xy(function(x, y) func(y) end, 1, yrep, 0, ypitch)
end

function geometry.multiple_xy(func, xrep, yrep, xpitch, ypitch)
    modassert(xpitch % 2 == 0, "geometry.multiple: xpitch must be even")
    modassert(ypitch % 2 == 0, "geometry.multiple: ypitch must be even")
    for x = 1, xrep do
        for y = 1, yrep do
            func(
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2
            )
        end
    end
end

