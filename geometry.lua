local M = {}

function M.rectangle(layer, width, height)
    assert(width % 2 == 0)
    assert(height % 2 == 0)
    local S = shape.create_rectangle(layer, width, height)
    return object.make_from_shape(S)
end

function M.cross(layer, width, height, crosssize)
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
    local spt1 = point.create(x1 + math.floor(width * math.cos(angle) + 0.5), y1 + math.floor(width * math.sin(angle) + 0.5))
    local spt2 = point.create(x2 + math.floor(width * math.cos(angle) + 0.5), y2 + math.floor(width * math.sin(angle) + 0.5))
    return spt1, spt2
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
local function _get_path_pts(pts, width, miterjoin)
    local tmp = {}
    local poly = {}
    local segs = #pts - 1
    local i = 1
    -- start to end
    for i = 1, #pts - 1 do
        local spt1, spt2 = _shift_line(pts[i], pts[i + 1], width / 2)
        table.insert(tmp, spt1)
        table.insert(tmp, spt2)
    end
    -- end to start (shift in other direction)
    for i = #pts, 2, -1 do
        local spt1, spt2 = _shift_line(pts[i], pts[i - 1], width / 2)
        table.insert(tmp, spt1)
        table.insert(tmp, spt2)
    end
    local midpointfunc = function(i)
        local inner, outer = _intersection(tmp[i - 1], tmp[i], tmp[i + 1], tmp[i + 2])
        if inner then
            return inner
        else
            if miterjoin then
                return outer
            else
                return tmp[i], tmp[i + 1]
            end
        end
    end
    -- first start point
    table.insert(poly, tmp[1])
    -- first middle points
    for seg = 1, segs - 1 do
        local i = 2 * seg
        local new = { midpointfunc(i) }
        for _, pt in ipairs(new) do table.insert(poly, pt) end
    end
    -- end points
    table.insert(poly, tmp[2 * segs])
    table.insert(poly, tmp[2 * segs + 1])
    -- second middle points
    for seg = 1, segs - 1 do
        local i = 2 * (segs + seg)
        local new = { midpointfunc(i) }
        for _, pt in ipairs(new) do table.insert(poly, pt) end
    end
    -- second start point
    table.insert(poly, tmp[#tmp])
    return poly
end

local function _get_any_angle_path_pts(pts, width, grid, miterjoin)
    local pathpts = _get_path_pts(pts, width, miterjoin)
    table.insert(pathpts, pts[1]:copy()) -- close path
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
    S.points = _get_path_pts(pts, width, miterjoin)
    return object.make_from_shape(S)
end

function M.any_angle_path(layer, pts, width, grid, miterjoin)
    local S = shape.create_polygon(layer)
    S.points = _get_any_angle_path_pts(pts, width, grid, miterjoin)
    return object.make_from_shape(S)
end

--[[
function M.path_midpoint(layer, pts, width, method, miterjoin)
    local newpts = {}
    table.insert(newpts, pts[1])
    for i = 2, #pts - 1 do
        local preangle = math.atan(pts[i].y - pts[i - 1].y, pts[i].x - pts[i - 1].x)
        local postangle = math.atan(pts[i + 1].y - pts[i].y, pts[i + 1].x - pts[i].x)
        local pt = pts[i]
        local factor = 0.6 * math.min(
            math.sqrt((pts[i].x - pts[i - 1].x)^2 + (pts[i].y - pts[i - 1].y)^2),
            math.sqrt((pts[i + 1].x - pts[i].x)^2 + (pts[i + 1].y - pts[i].y)^2)
            ) * math.tan(math.pi / 8)
        table.insert(newpts, point.create(pts[i].x - factor * math.cos(preangle), pts[i].y - factor * math.sin(preangle)))
        table.insert(newpts, point.create(pts[i].x + factor * math.cos(postangle), pts[i].y + factor * math.sin(postangle)))
    end
    table.insert(newpts, pts[#pts])
    return M.path(layer, newpts, width, miterjoin)
end
--]]

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
