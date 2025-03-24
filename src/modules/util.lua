--[[
This file is part of the openPCells project.

This module provides a collection of geometry-related helper functions such as:
    - manipulation of point arrays
    - easier insertion of points in arrays
--]]

function util.min(t)
    local idx = 1
    local min = math.huge
    for i = 1, #t do
        if t[i] < min then
            idx = i
            min = t[i]
        end
    end
    return min, idx
end

function util.max(t)
    local idx = 1
    local max = -math.huge
    for i = 1, #t do
        if t[i] > max then
            idx = i
            max = t[i]
        end
    end
    return max, idx
end

function util.make_counter(start)
    local i = start or 1
    return function()
        i = i + 1
        return i - 1
    end
end

function util.sum(t)
    local sum = 0
    for _, e in ipairs(t) do
        sum = sum + e
    end
    return sum
end

function util.polygon_xmin(pts)
    local min = math.huge
    for i, pt in ipairs(pts) do
        local x = pt:getx()
        if x < min then
            min = x
        end
    end
    return min
end

function util.polygon_ymin(pts)
    local min = math.huge
    for i, pt in ipairs(pts) do
        local y = pt:gety()
        if y < min then
            min = y
        end
    end
    return min
end

function util.polygon_xmax(pts)
    local max = -math.huge
    for i, pt in ipairs(pts) do
        local x = pt:getx()
        if x > max then
            max = x
        end
    end
    return max
end

function util.polygon_ymax(pts)
    local max = -math.huge
    for i, pt in ipairs(pts) do
        local y = pt:gety()
        if y > max then
            max = y
        end
    end
    return max
end

function util.make_rectangle(center, width, height)
    local bl = point.create(center:getx() - width / 2, center:gety() - height / 2)
    local tr = point.create(center:getx() + width / 2, center:gety() + height / 2)
    return bl, tr
end

function util.rectangle_to_polygon(bl, tr, leftext, rightext, bottomext, topext)
    return {
        point.create(bl:getx() - (leftext  or 0), bl:gety() - (bottomext or 0)),
        point.create(tr:getx() + (rightext or 0), bl:gety() - (bottomext or 0)),
        point.create(tr:getx() + (rightext or 0), tr:gety() + (topext    or 0)),
        point.create(bl:getx() - (leftext  or 0), tr:gety() + (topext    or 0)),
    }
end

function util.fit_rectangular_polygon(bl, tr, xgrid, ygrid, minxext, minyext, xmultiple, ymultiple)
    local dx = point.xdistance_abs(bl, tr)
    local dy = point.ydistance_abs(bl, tr)
    local xcorr = util.fix_to_grid_abs_higher(dx, xgrid) - dx
    local ycorr = util.fix_to_grid_abs_higher(dy, ygrid) - dy
    if minxext then
        while xcorr < minxext do
            xcorr = xcorr + xgrid
        end
    end
    if minyext then
        while ycorr < minyext do
            ycorr = ycorr + ygrid
        end
    end
    if xmultiple and xmultiple == "even" then
        if ((dx + xcorr) / xgrid) % 2 ~= 0 then
            xcorr = xcorr + xgrid
        end
    end
    if xmultiple and xmultiple == "odd" then
        if ((dx + xcorr) / xgrid) % 2 ~= 1 then
            xcorr = xcorr + xgrid
        end
    end
    if ymultiple and ymultiple == "even" then
        if ((dy + ycorr) / ygrid) % 2 ~= 0 then
            ycorr = ycorr + ygrid
        end
    end
    if ymultiple and ymultiple == "odd" then
        if ((dy + ycorr) / ygrid) % 2 ~= 1 then
            ycorr = ycorr + ygrid
        end
    end
    return {
        point.create(bl:getx() - xcorr / 2, bl:gety() - ycorr / 2),
        point.create(tr:getx() + xcorr / 2, bl:gety() - ycorr / 2),
        point.create(tr:getx() + xcorr / 2, tr:gety() + ycorr / 2),
        point.create(bl:getx() - xcorr / 2, tr:gety() + ycorr / 2),
    }
end

function util.rectangle_intersection(bl1, tr1, bl2, tr2)
    local bl1x = bl1:getx()
    local bl1y = bl1:gety()
    local tr1x = tr1:getx()
    local tr1y = tr1:gety()
    local bl2x = bl2:getx()
    local bl2y = bl2:gety()
    local tr2x = tr2:getx()
    local tr2y = tr2:gety()
    local blx = math.max(bl1x, bl2x)
    local bly = math.max(bl1y, bl2y)
    local trx = math.min(tr1x, tr2x)
    local try = math.min(tr1y, tr2y)
    if trx > blx and try > bly then
        return {
            bl = point.create(blx, bly),
            tr = point.create(trx, try),
        }
    end
    return nil
end

function util.xmirror(pts, xcenter)
    local mirrored = {}
    xcenter = xcenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(2 * xcenter - x, y)
    end
    return mirrored
end

function util.ymirror(pts, ycenter)
    local mirrored = {}
    ycenter = ycenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(x, 2 * ycenter - y)
    end
    return mirrored
end

function util.xymirror(pts, xcenter, ycenter)
    local mirrored = {}
    xcenter = xcenter or 0
    ycenter = ycenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(2 * xcenter - x, 2 * ycenter - y)
    end
    return mirrored
end

function util.transform_points(pts, func)
    local result = {}
    for _, pt in ipairs(pts) do
        local new = pt:copy()
        func(new)
        table.insert(result, new)
    end
    return result
end

function util.filter_forward(pts, fun)
    local filtered = {}
    for i = 1, #pts, 1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function util.filter_backward(pts, fun)
    local filtered = {}
    for i = #pts, 1, -1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function util.merge_forwards(pts, pts2)
    for i = 1, #pts2 do
        table.insert(pts, pts2[i])
    end
end

function util.merge_backwards(pts, pts2)
    for i = #pts2, 1, -1 do
        table.insert(pts, pts2[i])
    end
end

function util.reverse(pts)
    local new = {}
    for _, pt in ipairs(pts) do
        table.insert(new, 1, pt:copy())
    end
    return new
end

function util.make_insert_xy(pts, idx)
    if idx then
        return function(x, y) table.insert(pts, idx, point.create(x, y)) end
    else
        return function(x, y) table.insert(pts, point.create(x, y)) end
    end
end

function util.make_insert_pts(pts, idx)
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

function util.check_grid(grid, ...)
    for _, num in ipairs({ ... }) do
        assert(num % grid == 0, string.format("number is not on-grid: %d", num))
    end
end

function util.intersection(s1, s2, c1, c2)
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

function util.intersection_ab(P, Q)
    local P1x, P1y = P[1]:unwrap()
    local P2x, P2y = P[2]:unwrap()
    local Q1x, Q1y = Q[1]:unwrap()
    local Q2x, Q2y = Q[2]:unwrap()

    local A = function(P, Q, R)
        local Px, Py = P:unwrap()
        local Qx, Qy = Q:unwrap()
        local Rx, Ry = R:unwrap()
        return (Qx - Px) * (Ry - Py) - (Qy - Py) * (Rx - Px)
    end

    -- edges are parallel
    if (A(P[1], Q[1], Q[2]) - A(P[2], Q[1], Q[2])) == 0 and (A(Q[1], P[1], P[2]) - A(Q[2], P[1], P[2])) == 0 then
        local function dot(P, Q)
            local Px, Py = P:unwrap()
            local Qx, Qy = Q:unwrap()
            return Px * Qx + Py * Qy
        end
        local anum = dot(Q[1] - P[1], P[2] - P[1])
        local aden = dot(P[2] - P[1], P[2] - P[1])
        local bnum = dot(P[1] - Q[1], Q[2] - Q[1])
        local bden = dot(Q[2] - Q[1], Q[2] - Q[1])

        -- T-Overlap (a < 0 or a >= 1 and 0 < b < 1 OR b = 0 and 0 < a < 1)
        if (anum > 0 and anum > aden or anum < 0 and aden > 0)      and
           (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0)       and
           (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
           return P[1]
        end
        if (bnum > 0 and bnum > bden or bnum < 0 and bden > 0)      and
           (anum > 0 and aden > 0) or (anum < 0 and aden < 0)       and
           (anum < 0 and anum > aden) or (anum > 0 and anum < aden) then
           return Q[1]
        end

        -- V-Overlap (a == b == 0)
        if anum == 0 and bnum == 0 then
            return P[1] -- or Q[1]
        end

        -- X-Overlap (0 < a, b < 1)
        if (anum > 0 and aden > 0) or (anum < 0 and aden < 0)       and
           (anum < 0 and anum > aden) or (anum > 0 and anum < aden) and
           (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0)       and
           (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
        end
        local a = anum / aden
        return point.create((1 - a) * P1x + a * P2x, (1 - a) * P1y + a * P2y)
    else
        local anum = A(P[1], Q[1], Q[2])
        local aden = A(P[1], Q[1], Q[2]) - A(P[2], Q[1], Q[2])
        local bnum = A(Q[1], P[1], P[2])
        local bden = A(Q[1], P[1], P[2]) - A(Q[2], P[1], P[2])

        -- T-Intersection (a = 0 and 0 < b < 1 OR b = 0 and 0 < a < 1)
        if anum == 0 and bnum ~= 0 then
            if (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0) and
               (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
                return P[1]
            end
        end
        if bnum == 0 and anum ~= 0 then
            if (anum > 0 and aden > 0) or (anum < 0 and aden < 0) and
               (anum < 0 and anum > aden) or (anum > 0 and anum < aden) then
                return Q[1]
            end
        end

        -- V-Intersection (a == b == 0)
        if anum == 0 and bnum == 0 then
            return P[1] -- or Q[1]
        end

        -- X-Intersection (0 < a, b < 1)
        if (anum > 0 and aden > 0) or (anum < 0 and aden < 0)       and
           (anum < 0 and anum > aden) or (anum > 0 and anum < aden) and
           (bnum > 0 and bden > 0) or (bnum < 0 and bden < 0)       and
           (bnum < 0 and bnum > bden) or (bnum > 0 and bnum < bden) then
        end
        local a = anum / aden
        return point.create((1 - a) * P1x + a * P2x, (1 - a) * P1y + a * P2y)
    end
end

function util.range(lower, upper, incr)
    local t = {}
    for i = lower, upper, incr or 1 do
        table.insert(t, i)
    end
    return t
end

function util.remove(t, comp)
    local result = {}
    for _, e in ipairs(t) do
        if type(comp) == "function" then
            if not comp(e) then
                table.insert(result, e)
            end
        else
            if e ~= comp then
                table.insert(result, e)
            end
        end
    end
    return result
end

function util.remove_index(t, index)
    local result = {}
    for i, e in ipairs(t) do
        if type(index) == "table" then
            if not util.any_of(i, index) then
                table.insert(result, e)
            end
        else
            if i ~= index then
                table.insert(result, e)
            end
        end
    end
    return result
end

function util.remove_inplace(t, comp)
    for i, e in ipairs(t) do
        if type(comp) == "function" then
            if comp(e) then
                table.remove(result, i)
            end
        else
            if e == comp then
                table.remove(result, i)
            end
        end
    end
end

function util.remove_index_inplace(t, index)
    table.remove(t, index)
end

function util.clone_shallow(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function util.clone_shallow_predicate(t, predicate)
    local new = {}
    for k, v in pairs(t) do
        if predicate(k, v) then
            new[k] = v
        end
    end
    return new
end

function util.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i, v
        end
    end
end

function util.find_predicate(t, predicate)
    for i, v in ipairs(t) do
        if predicate(v) then
            return i, v
        end
    end
end

function util.fill_all_with(num, filler)
    local t = {}
    for i = 1, num do
        t[i] = filler
    end
    return t
end

function util.fill_predicate_with(num, filler, predicate, other)
    local t = {}
    for i = 1, num do
        if predicate(i) then
            t[i] = filler
        else
            t[i] = other
        end
    end
    return t
end

function util.fill_even_with(num, filler, other)
    return util.fill_predicate_with(num, filler, function(i) return i % 2 == 0 end, other)
end

function util.fill_odd_with(num, filler, other)
    return util.fill_predicate_with(num, filler, function(i) return i % 2 == 1 end, other)
end

function util.sum(t)
    local total = 0
    for _, e in ipairs(t) do
        total = total + e
    end
    return total
end

function util.add_options(base, t)
    local new = util.clone_shallow(base)
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function util.ratio_split_even(value, ratio)
    local second = value // (ratio + 1)
    if second % 2 == 1 then
        second = second - 1
    end
    local first = value - second
    return first, second
end

function util.ratio_split_multiple_of(value, ratio, multiple)
    if value % multiple ~= 0 then
        error(string.format("util.ratio_split_multiple_of: value must be divisible by the multiple, got: %d and %d", value, multiple))
    end
    local second = value // (ratio + 1)
    while second % multiple ~= 0 do
        second = second - 1
    end
    local first = value - second
    return first, second
end

function util.round_to_grid(c, grid)
    return grid * math.floor(c / grid + 0.5)
end

function util.fix_to_grid_higher(c, grid)
    return grid * math.ceil(c / grid)
end

function util.fix_to_grid_lower(c, grid)
    return grid * math.floor(c / grid)
end

function util.fix_to_grid_abs_higher(c, grid)
    if c < 0 then
        return -grid * math.ceil(-c / grid)
    else
        return grid * math.ceil(c / grid)
    end
end

function util.fix_to_grid_abs_lower(c, grid)
    if c < 0 then
        return -grid * math.floor(-c / grid)
    else
        return grid * math.floor(c / grid)
    end
end

function util.any_of(comp, t, ...)
    if type(comp) == "function" then
        for _, v in ipairs(t) do
            if comp(v, ...) then
                return true
            end
        end
        return false
    else
        for _, v in ipairs(t) do
            if comp == v then
                return true
            end
        end
        return false
    end
end

function util.all_of(comp, t, ...)
    if type(comp) == "function" then
        for _, v in ipairs(t) do
            if not comp(v, ...) then
                return false
            end
        end
        return true
    else
        for _, v in ipairs(t) do
            if comp ~= v then
                return false
            end
        end
        return true
    end
end

function util.foreach(t, f, ...)
    local new = {}
    for _, e in ipairs(t) do
        table.insert(new, f(e, ...))
    end
    return new
end

function util.fit_lines_upper(total, size, space)
    return math.ceil((total + space) / (size + space))
end

function util.fit_lines_lower(total, size, space)
    return math.floor((total + space) / (size + space))
end

