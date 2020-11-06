--[[
This file is part of the openPCells project.

This module provides a collection of geometry-related helper functions such as:
    - manipulation of point arrays
    - easier insertion of points in arrays
--]]

local M = {}

function M.xmirror(pts, xcenter)
    local mirrored = {}
    xcenter = xcenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(2 * xcenter - x, y)
    end
    return mirrored
end

function M.ymirror(pts, ycenter)
    local mirrored = {}
    ycenter = ycenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(x, 2 * ycenter - y)
    end
    return mirrored
end

function M.filter_forward(pts, fun)
    local filtered = {}
    for i = 1, #pts, 1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function M.filter_backward(pts, fun)
    local filtered = {}
    for i = #pts, 1, -1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function M.merge(pts, pts2)
    for _, pt in ipairs(pts2) do
        table.insert(pts, pt)
    end
end

function M.reverse(pts)
    local new = {}
    for _, pt in ipairs(pts) do
        table.insert(new, 1, pt:copy())
    end
    return new
end

function M.make_insert_xy(pts, idx)
    if idx then
        return function(x, y) table.insert(pts, idx, point.create(x, y)) end
    else
        return function(x, y) table.insert(pts, point.create(x, y)) end
    end
end

function M.make_insert_pts(pts, idx)
    if idx then
        return function(...)
            for _, pt in ipairs({ ... }) do
                table.insert(pts, idx, pt)
            end
        end
    else
        return function(...)
            for _, pt in ipairs({ ... }) do
                table.insert(pts, pt)
            end
        end
    end
end

function M.check_grid(grid, ...)
    for _, num in ipairs({ ... }) do
        assert(num % grid == 0, string.format("number is not on-grid: %d", num))
    end
end

function M.is_point_in_polygon(pt, pts)
    local j = #pts
    local c = nil
    local x, y = pt:unwrap()
    for i = 1, #pts do
        local xi, yi = pts[i]:unwrap()
        local xj, yj = pts[j]:unwrap()
        if ((yi > y) ~= (yj > y)) and (x < xi + (xj - xi) * (y - yi) / (yj - yi))
            then
            c = not(c)
        end
        j = i
    end
    return c
end

function M.intersection(s1, s2, c1, c2)
    local s1x, s1y = s1:unwrap()
    local s2x, s2y = s2:unwrap()
    local c1x, c1y = c1:unwrap()
    local c2x, c2y = c2:unwrap()
    local snum = (c2x - c1x) * (s1y - c1y) - (s1x - c1x) * (c2y - c1y)
    local cnum = (s2x - s1x) * (s1y - c1y) - (s1x - c1x) * (s2y - s1y)
    local den = (s2x - s1x) * (c2y - c1y) - (c2x - c1x) * (s2y - s1y)
    if den == 0 then
        return nil
    end

    -- you can use cnum with c-edge or snum with s-edge
    local pt = point.create(s1x + snum * (s2x - s1x) // den, s1y + snum * (s2y - s1y) // den)
    --local pt = point.create(c1x + cnum * (c2x - c1x) // den, c1y + cnum * (c2y - c1y) // den)
    -- the comparison is complex to avoid division
    if (snum == 0 or (snum < 0 and den < 0 and snum >= den) or (snum > 0 and den > 0 and snum <= den)) and
       (cnum == 0 or (cnum < 0 and den < 0 and cnum >= den) or (cnum > 0 and den > 0 and cnum <= den)) then
       return pt
    end
    -- if the edges don't truly overlap, we return the imaginary intersection after nil:
    return nil, pt
end

return M
