local M = {}

function M.rectangle(layer, width, height)
    assert(width % 2 == 0, "rectangle: width must be a multiple of 2. Use rectanglebltr if you need odd coordinates")
    assert(height % 2 == 0, "rectangle: height must be a multiple of 2. Use rectanglebltr if you need odd coordinates")
    local S = shape.create_rectangle(layer, width, height)
    return object.make_from_shape(S)
end

function M.rectanglebltr(layer, bl, tr)
    local S = shape.create_rectangle_bltr(layer, bl, tr)
    return object.make_from_shape(S)
end

function M.cross(layer, width, height, crosssize)
    assert(width % 2 == 0, "cross: width must be a multiple of 2")
    assert(height % 2 == 0, "cross: height must be a multiple of 2")
    assert(crosssize % 2 == 0, "cross: crosssize must be a multiple of 2")
    local S = shape.create_polygon(layer)
    local append = util.make_insert_xy(S.points)
    append(    -width / 2, -crosssize / 2)
    append(    -width / 2,  crosssize / 2)
    append(-crosssize / 2,  crosssize / 2)
    append(-crosssize / 2,     height / 2)
    append( crosssize / 2,     height / 2)
    append( crosssize / 2,  crosssize / 2)
    append(     width / 2,  crosssize / 2)
    append(     width / 2, -crosssize / 2)
    append( crosssize / 2, -crosssize / 2)
    append( crosssize / 2,    -height / 2)
    append(-crosssize / 2,    -height / 2)
    append(-crosssize / 2, -crosssize / 2)
    append(    -width / 2, -crosssize / 2) -- close polygon
    return object.make_from_shape(S)
end

function M.ring(layer, width, height, ringwidth)
    assert((width + ringwidth) % 2 == 0, "ring: width +- ringwidth must be a multiple of 2")
    assert((height + ringwidth) % 2 == 0, "ring: height +- ringwidth must be a multiple of 2")
    local S = shape.create_polygon(layer)
    local append = util.make_insert_xy(S.points)
    append(-(width + ringwidth) / 2, -(height + ringwidth) / 2)
    append( (width + ringwidth) / 2, -(height + ringwidth) / 2)
    append( (width + ringwidth) / 2,  (height + ringwidth) / 2)
    append(-(width + ringwidth) / 2,  (height + ringwidth) / 2)
    append(-(width + ringwidth) / 2, -(height - ringwidth) / 2)
    append(-(width - ringwidth) / 2, -(height - ringwidth) / 2)
    append(-(width - ringwidth) / 2,  (height - ringwidth) / 2)
    append( (width - ringwidth) / 2,  (height - ringwidth) / 2)
    append( (width - ringwidth) / 2, -(height - ringwidth) / 2)
    append(-(width + ringwidth) / 2, -(height - ringwidth) / 2)
    append(-(width + ringwidth) / 2, -(height + ringwidth) / 2) -- close polygon
    return object.make_from_shape(S)
end

local function _intersection(pt1, pt2, pt3, pt4)
    local x1, y1 = pt1:unwrap()
    local x2, y2 = pt2:unwrap()
    local x3, y3 = pt3:unwrap()
    local x4, y4 = pt4:unwrap()
    local num = (x1 - x3) * (y3 - y4) - (x3 - x4) * (y1 - y3)
    local den = (x1 - x2) * (y3 - y4) - (x3 - x4) * (y1 - y2)

    if den == 0 then
        return nil
    end

    local pt = point.create(x1 + num * (x2 - x1) // den, y1 + num * (y2 - y1) // den)
    -- FIXME: can num and den have different signs?
    if
        (num < 0 and den > 0) or
        (num > 0 and den < 0) or
        math.abs(num) > math.abs(den)
    then -- line segments don't truly intersect
        return nil, pt
    end
    return pt
end

local function _shift_line(pt1, pt2, width)
    local x1, y1 = pt1:unwrap()
    local x2, y2 = pt2:unwrap()
    -- cos(atan(x)) == 1 / sqrt(1 + x^2)
    -- sin(atan(x)) == x / sqrt(1 + x^2)
    local angle = math.atan(y2 - y1, x2 - x1) - math.pi / 2
    local xshift = math.floor(width * math.cos(angle) + 0.5)
    local yshift = math.floor(width * math.sin(angle) + 0.5)
    local spt1 = point.create(x1 + xshift, y1 + yshift)
    local spt2 = point.create(x2 + xshift, y2 + yshift)
    return spt1, spt2
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

local function _get_edge_segments(pts, width)
    local edges = {}
    -- start to end
    for i = 1, #pts - 1 do
        local spt1, spt2 = _shift_line(pts[i], pts[i + 1], width / 2)
        table.insert(edges, spt1)
        table.insert(edges, spt2)
    end
    -- end to start (shift in other direction)
    for i = #pts, 2, -1 do
        local spt1, spt2 = _shift_line(pts[i], pts[i - 1], width / 2)
        table.insert(edges, spt1)
        table.insert(edges, spt2)
    end
    return edges
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

-- calculate the outline points of a path with a width
-- this works as follows:
-- shift the middle path to the left and to the right
-- if adjacent lines intersect, that point is part of the outline
-- if adjacent lines don't intersect, either:
--      * insert both endpoints (well, the endpoint of the first segment and the startpoint of the second segment).
--        This is a bevel join
--      * insert the point where the extended line segments meet
--        This is a miter join
-- the endpoints of the path need extra care
local function _get_path_pts(edges, miterjoin)
    local midpointfunc = function(i)
        local inner, outer = _intersection(edges[i - 1], edges[i], edges[i + 1], edges[i + 2])
        if inner then
            return inner
        else
            if miterjoin then
                return outer
            else
                return edges[i], edges[i + 1]
            end
        end
    end
    local poly = {}
    -- first start point
    table.insert(poly, edges[1])
    -- first middle points
    local segs = #edges / 4
    for seg = 1, segs - 1 do
        local i = 2 * seg
        local new = { midpointfunc(i) }
        for _, pt in ipairs(new) do table.insert(poly, pt) end
    end
    -- end points
    table.insert(poly, edges[2 * segs])
    table.insert(poly, edges[2 * segs + 1])
    -- second middle points
    for seg = 1, segs - 1 do
        local i = 2 * (segs + seg)
        local new = { midpointfunc(i) }
        for _, pt in ipairs(new) do table.insert(poly, pt) end
    end
    -- second start point
    table.insert(poly, edges[#edges])
    return poly
end

local function _get_any_angle_path_pts(pts, width, grid, miterjoin)
    local edges = _get_gridded_edge_segments(pts, width, grid)
    local pathpts = _get_path_pts(edges, miterjoin)
    table.insert(pathpts, edges[1]:copy()) -- close path
    local poly = {}
    for i = 1, #pathpts - 1 do
        local linepts = graphics.line(pathpts[i], pathpts[i + 1], grid)
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

function M.path(layer, pts, width, miterjoin)
    _make_unique_points(pts)
    local S = shape.create_polygon(layer)
    local edges = _get_edge_segments(pts, width)
    S.points = _get_path_pts(edges, width, miterjoin)
    return object.make_from_shape(S)
end

function M.any_angle_path(layer, pts, width, grid, miterjoin)
    _make_unique_points(pts)
    local S = shape.create_polygon(layer)
    S.points = _get_any_angle_path_pts(pts, width, grid, miterjoin)
    return object.make_from_shape(S)
end

-- FIXME: rectangular-separated does not work in y direction
-- This could be fixed by using a more general (and cleaner) approach by tweaking the mirroring, not the points
local function _crossing(layer1, layer2, width, dxy, ext, direction, mode, separation)
    local obj = object.create()
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
    obj:merge_into(geometry.path(layer1, pts, width, true))
    obj:merge_into(geometry.path(layer2, util.xmirror(pts), width, true))
    return obj
end

function M.crossing(layer1, layer2, width, tl, br, mode)
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
    local obj = _crossing(layer1, layer2, width, dxy, ext, direction, mode)
    obj:translate(0, tly - dxy / 2)
    return obj
end

function M.path_midpoint(layer, pts, width, method, miterjoin)
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
        error(string.format("unknown midpoint path method: %s", method))
    end
    return M.path(layer, newpts, width, miterjoin)
end

--[[
function M.corner(layer, startpt, endpt, width, radius, grid)
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

function M.multiple(obj, xrep, yrep, xpitch, ypitch)
    assert(xpitch % 2 == 0)
    assert(ypitch % 2 == 0)
    local final = object.create()
    for x = 1, xrep do
        for y = 1, yrep do
            local center = point.create(
                (x - 1) * xpitch - (xrep - 1) * xpitch / 2,
                (y - 1) * ypitch - (yrep - 1) * ypitch / 2
            )
            final:merge_into(obj:copy():translate(center:unwrap()))
        end
    end
    return final
end

return M
