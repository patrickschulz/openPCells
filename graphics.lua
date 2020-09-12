-- http://members.chello.at/~easyfilter/bresenham.html

local M = {}

function M.bresenham_arc(radius, grid)
    local r = radius / grid
    local x = -r
    local y = 0
    local err = 2 - 2 * r -- II. Quadrant
    local pts = {}
    repeat
        table.insert(pts, point.create(-grid * x, grid * y))
        r = err
        if r <= y then
            y = y + 1
            err = err + y * 2 + 1 -- e_xy + e_y < 0 
        end
        if r > x or err > y then
            x = x + 1
            err = err + x * 2 + 1 -- e_xy + e_x > 0 or no 2nd y-step
        end
    until x >= 0
    return pts
end

function M.quartercircle(quadrant, xm, ym, radius, grid)
    local pts = {}
    local ptsi = M.bresenham_arc(radius, grid)
    local xi = (quadrant > 1 and quadrant < 4) and -1 or 1
    local yi = quadrant < 3 and 1 or -1
    for i = 1, #ptsi do
        local pt = ptsi[i]
        table.insert(pts, point.create(xm + xi * pt.x, ym + yi * pt.y))
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

function M.circle(xm, ym, radius, grid, startslope, endslope)
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
            table.insert(pts_pre, { x = xi * pt.x, y = yi * pt.y })
        end
    end
    local insert = false
    local pts = {}
    for _, pt in ipairs(pts_pre) do
        local slope = pt.y / pt.x
        if slope > startslope then insert = true end
        if slope > endslope then insert = false end
        if insert then
            table.insert(pts, { x = xm + pt.x, y = ym + pt.y })
        end
    end
    return pts
end

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

function M.line(x0, y0, x1, y1, grid)
    local x0 = aux.fix_to_grid(x0, grid)
    local y0 = aux.fix_to_grid(y0, grid)
    local x1 = aux.fix_to_grid(x1, grid)
    local y1 = aux.fix_to_grid(y1, grid)
    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and grid or -grid
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and grid or -grid
    local err = dx + dy, e2; -- error value e_xy

    local pts = {}
    while true do
        table.insert(pts, point.create(x0, y0))
        --if x0 == x1 and y0 == y1 then break end
        if aux.equal(x0, x1, 0.5 * grid) and aux.equal(y0, y1, 0.5 * grid) then break end
        e2 = 2 * err;
        if e2 >= dy then 
            err = err + dy
            x0 = x0 + sx -- e_xy+e_x > 0
        end
        if e2 <= dx then 
            err = err + dx
            y0 = y0 + sy -- e_xy+e_y < 0 */
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
