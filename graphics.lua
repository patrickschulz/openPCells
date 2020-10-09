-- http://members.chello.at/~easyfilter/bresenham.html

local M = {}

function M.bresenham_arc(radius, grid)
    -- x^2 + y^2 - r^2 = 0
    local x, y = -radius, 0 -- II. Quadrant
    local err = 2 * grid + 2 * x
    local pts = {}
    repeat
        table.insert(pts, point.create(-x, y))
        local e2 = err
        if y >= err then
            y = y + grid
            err = err + y * 2 + grid -- e_xy + e_y < 0 
        end
        if x < e2 or y < err  then
            x = x + grid
            err = err + x * 2 + grid -- e_xy + e_x > 0 or no 2nd y-step
        end
    until x >= 0
    -- insert last point
    table.insert(pts, point.create(0, radius))
    return pts
end

function M.circle(radius, grid)
    local arcpts = M.bresenham_arc(radius, grid)
    local pts = {}
    local append = util.make_insert_xy(pts)
    for i = 1, #arcpts do
        local x, y = arcpts[i]:unwrap()
        append(x, y)
    end
    for i = 2, #arcpts do
        local x, y = arcpts[#arcpts - i + 1]:unwrap()
        append(-x, y)
    end
    for i = 2, #arcpts do
        local x, y = arcpts[i]:unwrap()
        append(-x, -y)
    end
    for i = 2, #arcpts do
        local x, y = arcpts[#arcpts - i + 1]:unwrap()
        append(x, -y)
    end
    return pts
end

function M.quartercircle(quadrant, xm, ym, radius, grid)
    local pts = {}
    local ptsi = M.bresenham_arc(radius, grid)
    local xi = (quadrant > 1 and quadrant < 4) and -1 or 1
    local yi = quadrant < 3 and 1 or -1
    for i = 1, #ptsi do
        local pt = ptsi[i]
        table.insert(pts, point.create(xm + xi * pt:getx(), ym + yi * pt:gety()))
    end
    return pts
end

function M.halfcircle(xm, ym, radius, grid)
    local pts = {}
    local ptsi = M.bresenham_arc(radius, grid)
    for num, shift in ipairs({ { -1, 1 }, { -1, -1 } }) do
        local startidx, endidx, inc
        if num % 2 == 0 then
            startidx = 1
            endidx = #ptsi
            inc = 1
        else
            startidx = #ptsi
            endidx = 1
            inc = -1
        end
        local xi = shift[1]
        local yi = shift[2]
        for i = startidx, endidx, inc do
            local pt = ptsi[i]
            table.insert(pts, { x = xm + xi * pt.x, y = ym + yi * pt.y })
        end
    end
    return pts
end

--[[
function M.circle(origin, radius, grid, startslope, endslope)
    local xm, ym = origin:unwrap()
    local startslope = startslope or 0
    local endslope = endslope or 2 * math.pi
    local pts_pre = {}
    local ptsi = M.bresenham_arc(radius, grid)
    -- we have to reorder the points since this matters for polygons (as opposed to pixels, for what the bresenham algorithm was designed)
    for num, shift in ipairs({ { 1, 1 }, { -1, 1 }, { -1, -1 }, { 1, -1 } }) do
        local startidx, endidx, inc
        if num % 2 == 0 then
            startidx = #ptsi
            endidx = 1
            inc = -1
        else
            startidx = 1
            endidx = #ptsi
            inc = 1
        end
        local xi = shift[1]
        local yi = shift[2]
        for i = startidx, endidx, inc do
            local x, y = ptsi[i]:unwrap()
            table.insert(pts_pre, { x = xi * x, y = yi * y })
        end
    end
    local insert = false
    local pts = {}
    for _, pt in ipairs(pts_pre) do
        local slope = pt.y / pt.x
        if slope > startslope then insert = true end
        if slope > endslope then insert = false end
        if insert then
            table.insert(pts, point.create(xm + pt.x, ym + pt.y))
        end
    end
    return pts
end
--]]

function M.arc(center, radius, startangle, endangle, grid)
    local startslope = startslope or 0
    local endslope = endslope or 2 * math.pi
    local pts_pre = {}
    local ptsi = M.bresenham_arc(radius, grid)
    -- we have to reorder the points since this matters for polygons (as opposed to pixels, for what the bresenham algorithm was designed)
    for num, shift in ipairs({ { 1, 1 }, { -1, 1 }, { -1, -1 }, { 1, -1 } }) do
        local startidx, endidx, inc
        if num % 2 == 0 then
            startidx = #ptsi
            endidx = 1
            inc = -1
        else
            startidx = 1
            endidx = #ptsi
            inc = 1
        end
        local xi = shift[1]
        local yi = shift[2]
        for i = startidx, endidx, inc do
            local pt = ptsi[i]
            table.insert(pts_pre, point.create( xi * pt.x, yi * pt.y))
        end
    end
    local pts = {}
    for _, pt in ipairs(pts_pre) do
        table.insert(pts, point.create(xm + pt.x, ym + pt.y))
    end
    return pts
end

function M.xmirror(pts, xcenter)
    local res = {}
    for _, pt in ipairs(pts) do
        table.insert(res, { x = 2 * xcenter - pt.x, y = pt.y })
    end
    return res
end

function M.spiral_points(arc, separation, numpts, grid)
    --[[
    generate points on an Archimedes' spiral
    with `arc` giving the length of arc between two points
    and `separation` giving the distance between consecutive 
    turnings
    - approximate arc length with circle arc at given distance
    - use a spiral equation r = b * phi
    --]]
    local function p2c(r, phi, grid) 
        local x = r * math.cos(phi)
        local y = r * math.sin(phi)
        return { x = math.floor(x / grid) * grid, y = math.floor(y / grid) * grid }
    end

    local pts = {}
    -- yield a point at origin
    table.insert(pts, { x = 0, y = 0 })

    -- initialize the next point in the required distance
    local r = arc
    local b = separation / (2 * math.pi)
    -- find the first phi to satisfy distance of `arc` to the second point
    local phi = r / b
    local remaining = numpts
    while remaining > 0 do
        table.insert(pts, p2c(r, phi, grid))
        -- advance the variables
        -- calculate phi that will give desired arc length at current radius
        -- (approximating with circle)
        phi = phi + arc / r
        r = b * phi
        remaining = remaining - 1
    end
    return pts
end

function M.line(pt1, pt2, grid)
    local x1, y1 = pt1:unwrap()
    local x2, y2 = pt2:unwrap()
    local dx = math.abs(x2 - x1)
    local dy = -math.abs(y2 - y1)
    -- handle vertical, horizontal or diagonal lines specially
    if x1 == x2 or y1 == y2 or dx == -dy then
        return {
            pt1:copy(),
            pt2:copy()
        }
    end
    local sx = x1 < x2 and grid or -grid
    local sy = y1 < y2 and grid or -grid
    local err = dx + dy -- error value e_xy
    local e2

    local pts = {}
    while true do
        table.insert(pts, point.create(x1, y1))
        if x1 == x2 and y1 == y2 then break end
        e2 = 2 * err
        if e2 >= dy then 
            err = err + dy
            x1 = x1 + sx -- e_xy + e_x > 0
        end
        if e2 <= dx then 
            err = err + dx
            y1 = y1 + sy -- e_xy + e_y < 0
        end
    end
    return pts
end

function M.quadbezierseg(startpt, endpt, ctrlpt, grid)
    local x0, y0 = startpt:unwrap(1 / grid)
    local x1, y1 = ctrlpt:unwrap(1 / grid)
    local x2, y2 = endpt:unwrap(1 / grid)
    local sx = x2 -x1
    local sy = y2 -y1
    local xx = x0 - x1
    local yy = y0 - y1
    local xy = 0
    local dx = 0
    local dy = 0
    local err = 0 
    local cur = xx * sy - yy * sx -- curvature

    assert(xx * sx <= 0 and yy * sy <= 0) -- sign of gradient must not change

    local pts = {}

    if sx * sx + sy * sy > xx * xx +yy * yy then -- begin with longer part
        x2 = x0
        x0 = sx+x1
        y2 = y0
        y0 = sy+y1 
        cur = -cur  -- swap P0 P2
    end
    if cur ~= 0 then -- no straight line
        xx = xx + sx
        sx = x0 < x2 and 1 or -1
        xx = xx * sx

        yy = yy + sy
        sy = y0 < y2 and 1 or -1
        yy = yy * sy

        xy = 2 * xx * yy
        xx = xx * xx
        yy = yy * yy
        if (cur*sx*sy < 0) then
            xx = -xx
            yy = -yy
            xy = -xy
            cur = -cur
        end
        dx = 4.0 * sy * cur * (x1 - x0) + xx - xy
        dy = 4.0 * sx * cur * (y0 - y1) + yy - xy
        xx = xx + xx
        yy = yy + yy
        err = dx + dy + xy
        repeat
            table.insert(pts, point.create(grid * x0, grid * y0))
            if x0 == x2 and y0 == y2 then return pts end -- last pixel -> curve finished
            if 2 * err > dy then 
                x0 = x0 + sx
                dx = dx - xy
                dy = dy + yy
                err = err + dy
            end
            if 2 * err < dx then 
                y0 = y0 + sy
                dy = dy - xy
                dx = dx + xx
                err = err + dx
            end
        until dy >= dx
    end
    local linepts = M.line(x0, y0, x2, y2) -- plot remaining part to end
end

return M
