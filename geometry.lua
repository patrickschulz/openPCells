local M = {}

function M.rectangle(layer, width, height)
    local S = shape.create_rectangle(layer, width, height)
    return object.make_from_shape(S)
end

function M.cross(layer, width, height, crosssize)
    local S = shape.create_polygon(layer)
    local append = util.make_insert_xy(S.points)
    append(-0.5 * width,     -0.5 * crosssize)
    append(-0.5 * width,      0.5 * crosssize)
    append(-0.5 * crosssize,  0.5 * crosssize)
    append(-0.5 * crosssize,  0.5 * height)
    append( 0.5 * crosssize,  0.5 * height)
    append( 0.5 * crosssize,  0.5 * crosssize)
    append( 0.5 * width,      0.5 * crosssize)
    append( 0.5 * width,     -0.5 * crosssize)
    append( 0.5 * crosssize, -0.5 * crosssize)
    append( 0.5 * crosssize, -0.5 * height)
    append(-0.5 * crosssize, -0.5 * height)
    append(-0.5 * crosssize, -0.5 * crosssize)
    append(-0.5 * width,     -0.5 * crosssize) -- close polygon
    return object.make_from_shape(S)
end

function M.ring(layer, width, height, ringwidth)
    local S = shape.create_polygon(layer)
    local append = util.make_insert_xy(S.points)
    append(-0.5 * (width + ringwidth), -0.5 * (height + ringwidth))
    append( 0.5 * (width + ringwidth), -0.5 * (height + ringwidth))
    append( 0.5 * (width + ringwidth),  0.5 * (height + ringwidth))
    append(-0.5 * (width + ringwidth),  0.5 * (height + ringwidth))
    append(-0.5 * (width + ringwidth), -0.5 * (height - ringwidth))
    append(-0.5 * (width - ringwidth), -0.5 * (height - ringwidth))
    append(-0.5 * (width - ringwidth),  0.5 * (height - ringwidth))
    append( 0.5 * (width - ringwidth),  0.5 * (height - ringwidth))
    append( 0.5 * (width - ringwidth), -0.5 * (height - ringwidth))
    append(-0.5 * (width + ringwidth), -0.5 * (height - ringwidth))
    append(-0.5 * (width + ringwidth), -0.5 * (height + ringwidth)) -- close polygon
    return object.make_from_shape(S)
end

local function _intersection(pt1, pt2, pt3, pt4)
    local num = (pt1.x - pt3.x) * (pt3.y - pt4.y) - (pt1.y - pt3.y) * (pt3.x - pt4.x)
    local den = (pt1.x - pt2.x) * (pt3.y - pt4.y) - (pt1.y - pt2.y) * (pt3.x - pt4.x)

    if den == 0 then
        return nil
    end

    local t = num / den
    local pt = point.create(pt1.x + t * (pt2.x - pt1.x), pt1.y + t * (pt2.y - pt1.y))
    if t < 0 or t > 1 then -- line segments don't truly intersect
        return nil, pt
    end
    return pt
end

local function _shift_line(pt1, pt2, width)
    --local angle = compat.atan2(pt2.y - pt1.y, pt2.x - pt1.x) - math.pi / 2
    --local angle = math.atan(pt2.y - pt1.y, pt2.x - pt1.x) - math.pi / 2
    local angle = math.atan2(pt2.y - pt1.y, pt2.x - pt1.x) - math.pi / 2
    local spt1 = point.create(pt1.x + width * math.cos(angle), pt1.y + width * math.sin(angle))
    local spt2 = point.create(pt2.x + width * math.cos(angle), pt2.y + width * math.sin(angle))
    return spt1, spt2
end

local function _get_path_pts(pts, width, miterjoin)
    local tmp = {}
    local poly = {}
    local segs = #pts - 1
    local i = 1
    -- start to end
    for i = 1, #pts - 1 do
        local spt1, spt2 = _shift_line(pts[i], pts[i + 1], 0.5 * width)
        table.insert(tmp, spt1)
        table.insert(tmp, spt2)
    end
    -- end to start (shift in other direction)
    for i = #pts, 2, -1 do
        local spt1, spt2 = _shift_line(pts[i], pts[i - 1], 0.5 * width)
        table.insert(tmp, spt1)
        table.insert(tmp, spt2)
    end
    local midpointfunc = function(i)
        local inner, outer = _intersection(tmp[i - 1], tmp[i], tmp[i + 1], tmp[i + 2])
        if not inner then
            if miterjoin then
                table.insert(poly, outer)
            else
                table.insert(poly, tmp[i])
                table.insert(poly, tmp[i + 1])
            end
        else
            table.insert(poly, inner)
        end
    end
    -- first start point
    table.insert(poly, tmp[1])
    -- first middle points
    for seg = 1, segs - 1 do
        local i = 1 + 2 * (seg - 1) + 1
        midpointfunc(i)
    end
    -- end points
    table.insert(poly, tmp[1 + (segs - 1) * 2 + 1])
    table.insert(poly, tmp[1 + (segs - 1) * 2 + 2])
    -- second middle points
    for seg = 1, segs - 1 do
        local i = 1 + (segs - 1) * 2 + 2 + 2 * (seg - 1) + 1
        midpointfunc(i)
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
        local pstart = pathpts[i]
        local pend = pathpts[i + 1]
        local linepts = graphics.line(pstart.x, pstart.y, pend.x, pend.y, grid)
        for _, pt in ipairs(linepts) do
            table.insert(poly, pt)
        end
    end
    return poly
end

function M.path(layer, pts, width, miterjoin)
    local S = shape.create_polygon(layer)
    S.points = _get_path_pts(pts, width, miterjoin)
    return object.make_from_shape(S)
end

function M.any_angle_path(layer, pts, width, grid, miterjoin)
    local S = shape.create_polygon(layer)
    S.points = _get_any_angle_path_pts(pts, width, grid, miterjoin)
    return object.make_from_shape(S)
end

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

function M.multiple(obj, xrep, yrep, xpitch, ypitch)
    local final = object.create()
    for x = 1, xrep do
        for y = 1, yrep do
            local center = point.create(
                (x - 1) * xpitch - 0.5 * (xrep - 1) * xpitch, 
                (y - 1) * ypitch - 0.5 * (yrep - 1) * ypitch
            )
            final:merge_into(obj:copy():translate(center.x, center.y))
        end
    end
    return final
end

return M
