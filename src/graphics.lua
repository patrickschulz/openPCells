local M = {}

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

function M.line(pt1, pt2, grid, allow45)
    local x1, y1 = pt1:unwrap()
    local x2, y2 = pt2:unwrap()

    -- handle vertical, horizontal or 45-degrees diagonal lines specially
    if x1 == x2 or y1 == y2 or math.abs(x2 - x1) == math.abs(y2 - y1) then
        return {
            pt1:copy(),
            pt2:copy()
        }
    end

    util.check_grid(grid, x1 - x2, y1 - y2)

    local function calc_error(x, y)
        return (y - y1) * (x2 - x1) - (x - x1) * (y2 - y1)
    end

    return _rasterize(x1, y1, x2, y2, grid, calc_error, allow45)
end

function M.ellipse(origin, xradius, yradius, grid, allow45)
    local xc, yc = origin:unwrap()
    local x1, y1 = xc + xradius, yc
    local x2, y2 = xc, yc + yradius

    util.check_grid(grid, xc, yc, xradius, yradius)

    local function calc_error(x, y)
        return (x - xc) * (x - xc) * xradius * xradius + (y - yc) * (y - yc) * yradius * yradius - xradius * xradius * yradius * yradius
    end

    local quarter = _rasterize(x1, y1, x2, y2, grid, calc_error, allow45)
    local pts = {}
    local append = util.make_insert_xy(pts)
    for i = 1, #quarter do
        local x, y = quarter[i]:unwrap()
        append(x, y)
    end
    for i = 2, #quarter do
        local x, y = quarter[#quarter - i + 1]:unwrap()
        append(-x, y)
    end
    for i = 2, #quarter do
        local x, y = quarter[i]:unwrap()
        append(-x, -y)
    end
    for i = 2, #quarter do
        local x, y = quarter[#quarter - i + 1]:unwrap()
        append(x, -y)
    end
    return pts
end

function M.quarterellipse(quadrant, origin, xradius, yradius, grid, allow45)
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
        return util.reverse(util.xmirror(quarter))
    end
    if quadrant == 3 then
        return util.xmirror(util.ymirror(quarter))
    end
    if quadrant == 4 then
        return util.reverse(util.ymirror(quarter))
    end
    assert(nil, string.format("wrong quadrant: %d", quadrant))
end

function M.quartercircle(quadrant, origin, radius, grid, allow45)
    return M.quarterellipse(quadrant, origin, radius, radius, grid, allow45)
end

function M.circle(origin, radius, grid, allow45)
    return M.ellipse(origin, radius, radius, grid, allow45)
end

return M
