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

--[[
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
    cell:merge_into(obj)
end
--]]

function geometry.metalcrossing(cell, metal1, metal2, startpt1, endpt1, startpt2, endpt2, width)
    geometry.path4xy(cell, generics.metal(metal1), startpt1, endpt1, width)
    geometry.path4xy(cell, generics.metal(metal2), startpt2, endpt2, width)
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

