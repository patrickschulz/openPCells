graphics = {}

local function _rasterize(x1, y1, x2, y2, grid, calc_error, allow45)
    local x, y = x1, y1
    local sx = (x1 < x2) and grid or -grid
    local sy = (y1 < y2) and grid or -grid
    local pts = {}
    while true do
        table.insert(pts, point.create(x, y))
        if x == x2 and y == y2 then
            break
        end
        local exy = calc_error(x + sx, y + sy)
        local ex  = calc_error(x,      y + sy)
        local ey  = calc_error(x + sx, y     )
        if allow45 then
            if math.abs(exy) < math.abs(ex) then
                x = x + sx
            end
            if math.abs(exy) < math.abs(ey) then
                y = y + sy
            end
        else
            if math.abs(ex) < math.abs(ey) then
                y = y + sy
            else
                x = x + sx
            end
        end
    end
    return pts
end

local function _map_xy_to_quadrant(x, y)
    if x >= 0 then
        if y >= 0 then
            return 1
        else
            return 4
        end
    else
        if y >= 0 then
            return 2
        else
            return 3
        end
    end
end

local function _get_quadrant_list(startquadrant, endquadrant)
    local quadrants = {}
    local i = startquadrant
    local stop = false
    while true do
        table.insert(quadrants, i)
        if stop then break end
        i = (i % 4) + 1
        if i == endquadrant then
            stop = true
        end
    end
    return quadrants
end

local function _xsign(quadrant)
    if quadrant == 1 then
        return 1
    elseif quadrant == 2 then
        return -1
    elseif quadrant == 3 then
        return -1
    elseif quadrant == 4 then
        return 1
    else
        error("wrong quadrant")
    end
end

local function _ysign(quadrant)
    if quadrant == 1 then
        return 1
    elseif quadrant == 2 then
        return 1
    elseif quadrant == 3 then
        return -1
    elseif quadrant == 4 then
        return -1
    else
        error("wrong quadrant")
    end
end

local function _check_startquadrant(quadrant, x, y, xstart, ystart)
    if quadrant == 1 then
        if x <= xstart and y >= ystart then
            return true
        end
        return false
    elseif quadrant == 2 then
        if x <= xstart and y <= ystart then
            return true
        end
        return false
    elseif quadrant == 3 then
        if x >= xstart and y <= ystart then
            return true
        end
        return false
    elseif quadrant == 4 then
        if x >= xstart and y >= ystart then
            return true
        end
        return false
    else
        error("wrong quadrant")
    end
end

local function _check_endquadrant(quadrant, x, y, xend, yend)
    if quadrant == 1 then
        if x >= xend and y <= yend then
            return true
        end
        return false
    elseif quadrant == 2 then
        if x >= xend and y >= yend then
            return true
        end
        return false
    elseif quadrant == 3 then
        if x <= xend and y >= yend then
            return true
        end
        return false
    elseif quadrant == 4 then
        if x <= xend and y <= yend then
            return true
        end
        return false
    else
        error("wrong quadrant")
    end
end

local function _assemble_circle_points(quarterpoints, quadrants, xstart, ystart, xend, yend, xc, yc)
    local pts = {}
    local append = util.make_insert_xy(pts)
    for i, q in ipairs(quadrants) do
        local startj = (i == 1) and 1 or 2
        for j = startj, #quarterpoints do
            local idx = (q % 2 == 0) and (#quarterpoints - j + 1) or j
            local x, y = quarterpoints[idx]:unwrap()
            x = x * _xsign(q)
            y = y * _ysign(q)
            local insert = false
            if i == 1 then -- start quadrant
                insert = _check_startquadrant(q, x, y, xstart, ystart)
            elseif i == #quadrants then -- end quadrant
                insert = _check_endquadrant(q, x, y, xend, yend)
            else -- insert every point of an intermediate quadrant
                insert = true
            end
            if insert then
                append(xc + x, yc + y)
            end
        end
    end
    return pts
end

function graphics.ellipse(origin, xradius, yradius, startangle, endangle, grid, allow45)
    local xc, yc = origin:unwrap()
    local x1, y1 = xradius, 0
    local x2, y2 = 0, yradius

    util.check_grid(grid, xc, yc, xradius, yradius)

    local xstart = math.floor(xradius * math.cos(startangle * math.pi / 180))
    local xend = math.floor(xradius * math.cos(endangle * math.pi / 180))
    local ystart = math.floor(yradius * math.sin(startangle * math.pi / 180))
    local yend = math.floor(yradius * math.sin(endangle * math.pi / 180))

    local startquadrant = _map_xy_to_quadrant(xstart, ystart)
    local endquadrant = _map_xy_to_quadrant(xend, yend)

    local function calc_error(x, y)
        return x * x * xradius * xradius + y * y * yradius * yradius - xradius * xradius * yradius * yradius
    end

    local quarterpoints = _rasterize(x1, y1, x2, y2, grid, calc_error, allow45)

    local quadrants = _get_quadrant_list(startquadrant, endquadrant)

    return _assemble_circle_points(quarterpoints, quadrants, xstart, ystart, xend, yend, xc, yc)
end

function graphics.quarterellipse(quadrant, origin, xradius, yradius, grid, allow45)
    local xc, yc = origin:unwrap()
    local x1, y1 = xc + xradius, yc
    local x2, y2 = xc, yc + yradius

    util.check_grid(grid, xc, yc, xradius, yradius)

    local function calc_error(x, y)
        return (x - xc) * (x - xc) * xradius * xradius + (y - yc) * (y - yc) * yradius * yradius - xradius * xradius * yradius * yradius
    end

    local quarter = _rasterize(x1, y1, x2, y2, grid, calc_error, allow45)
    if quadrant == 1 then
        return quarter
    end
    if quadrant == 2 then
        return util.reverse(util.xmirror(quarter, xc))
    end
    if quadrant == 3 then
        return util.xmirror(util.ymirror(quarter, yc))
    end
    if quadrant == 4 then
        return util.reverse(util.ymirror(quarter, yc))
    end
    assert(nil, string.format("wrong quadrant: %d", quadrant))
end

function graphics.quartercircle(quadrant, origin, radius, grid, allow45)
    return graphics.quarterellipse(quadrant, origin, radius, radius, grid, allow45)
end

function graphics.circle(origin, radius, startangle, endangle, grid, allow45)
    return graphics.ellipse(origin, radius, radius, startangle, endangle, grid, allow45)
end
