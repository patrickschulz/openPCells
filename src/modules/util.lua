--[[
This file is part of the openPCells project.

This module provides a collection of geometry-related helper functions such as:
    - manipulation of point arrays
    - easier insertion of points in arrays
--]]

-- implementation note:
-- the global symbol 'util' already exists at this point,
-- hence the functions are written directly into it.
-- This is because there is a c-part of this module, that
-- is loaded before the lua part is.
-- There, the global table 'util' is created.

function util.min(t)
    check.set_next_function_name("util.min")
    check.arg(1, "t", "table", t)
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
    check.set_next_function_name("util.max")
    check.arg(1, "t", "table", t)
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
    check.set_next_function_name("util.sum")
    check.arg(1, "t", "table", t)
    local sum = 0
    for _, e in ipairs(t) do
        sum = sum + e
    end
    return sum
end

function util.polygon_xmin(pts)
    check.set_next_function_name("util.polygon_xmin")
    check.arg(1, "pts", "table", pts)
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
    check.set_next_function_name("util.polygon_ymin")
    check.arg(1, "pts", "table", pts)
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
    check.set_next_function_name("util.polygon_xmax")
    check.arg(1, "pts", "table", pts)
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
    check.set_next_function_name("util.polygon_ymax")
    check.arg(1, "pts", "table", pts)
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
    check.set_next_function_name("util.make_rectangle")
    check.arg(1, "width", "number", width)
    check.arg(2, "height", "number", height)
    local bl = point.create(center:getx() - width / 2, center:gety() - height / 2)
    local tr = point.create(center:getx() + width / 2, center:gety() + height / 2)
    return bl, tr
end

function util.polygon_rectangular_boundary(polygon)
    check.set_next_function_name("util.polygon_rectangular_boundary")
    check.arg(1, "polygon", "table", polygon)
    local xmin = util.polygon_xmin(polygon)
    local ymin = util.polygon_ymin(polygon)
    local xmax = util.polygon_xmax(polygon)
    local ymax = util.polygon_ymax(polygon)
    local bl = point.create(xmin, ymin)
    local tr = point.create(xmax, ymax)
    return bl, tr
end

function util.rectangle_to_polygon(bl, tr, leftext, rightext, bottomext, topext)
    check.set_next_function_name("util.rectangle_to_polygon")
    check.arg_func(1, "bl", "point", bl, point.is_point)
    check.arg_func(2, "tr", "point", tr, point.is_point)
    check.arg_optional(3, "leftext", "number", leftext)
    check.arg_optional(4, "rightext", "number", rightext)
    check.arg_optional(5, "bottomext", "number", bottomext)
    check.arg_optional(6, "topext", "number", topext)
    return {
        point.create(bl:getx() - (leftext  or 0), bl:gety() - (bottomext or 0)),
        point.create(tr:getx() + (rightext or 0), bl:gety() - (bottomext or 0)),
        point.create(tr:getx() + (rightext or 0), tr:gety() + (topext    or 0)),
        point.create(bl:getx() - (leftext  or 0), tr:gety() + (topext    or 0)),
    }
end

function util.fit_rectangular_polygon(bl, tr, xgrid, ygrid, minxext, minyext, xmultiple, ymultiple)
    check.set_next_function_name("util.fit_rectangular_polygon")
    check.arg_func(1, "bl", "point", bl, point.is_point)
    check.arg_func(2, "tr", "point", tr, point.is_point)
    check.arg(3, "xgrid", "number", xgrid)
    check.arg(4, "ygrid", "number", ygrid)
    check.arg_optional(5, "minxext", "number", minxext)
    check.arg_optional(6, "minyext", "number", minyext)
    check.arg_optional(7, "xmultiple", "string", xmultiple)
    check.arg_optional(8, "ymultiple", "string", ymultiple)
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

function util.offset_polygon(polygon, offset)
    check.set_next_function_name("util.offset_polygon")
    check.arg(1, "polygon", "table", polygon)
    check.arg(2, "offset", "number", offset)
    return geometry.offset_polygon_points(polygon, offset)
end

function util.rectangle_intersection(bl1, tr1, bl2, tr2, onlyfull)
    check.set_next_function_name("util.rectangle_intersection")
    check.arg_func(1, "bl1", "point", bl1, point.is_point)
    check.arg_func(2, "tr1", "point", tr1, point.is_point)
    check.arg_func(3, "bl2", "point", bl2, point.is_point)
    check.arg_func(4, "tr2", "point", tr2, point.is_point)
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
        if not onlyfull then
            success = true
        else -- full intersection
            if
                (bl1x <= bl2x and tr1x >= tr2x and bl2y <= bl1y and tr2y >= tr1y) or
                (bl2x <= bl1x and tr2x >= tr1x and bl1y <= bl2y and tr1y >= tr2y) then
                success = true
            end
        end
        if success then
            return {
                bl = point.create(blx, bly),
                tr = point.create(trx, try),
            }
        end
    end
    return nil
end

function util.xmirror(pts, xcenter)
    check.set_next_function_name("util.xmirror")
    check.arg(1, "pts", "table", pts)
    check.arg_optional(2, "xcenter", "number", xcenter)
    local mirrored = {}
    xcenter = xcenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(2 * xcenter - x, y)
    end
    return mirrored
end

function util.ymirror(pts, ycenter)
    check.set_next_function_name("util.ymirror")
    check.arg(1, "pts", "table", pts)
    check.arg_optional(2, "ycenter", "number", ycenter)
    local mirrored = {}
    ycenter = ycenter or 0
    for i, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        mirrored[i] = point.create(x, 2 * ycenter - y)
    end
    return mirrored
end

function util.xymirror(pts, xcenter, ycenter)
    check.set_next_function_name("util.xymirror")
    check.arg(1, "pts", "table", pts)
    check.arg_optional(2, "xcenter", "number", xcenter)
    check.arg_optional(3, "ycenter", "number", ycenter)
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
    check.set_next_function_name("util.transform_points")
    check.arg(1, "pts", "table", pts)
    check.arg(2, "func", "function", func)
    local result = {}
    for _, pt in ipairs(pts) do
        local new = pt:copy()
        func(new)
        table.insert(result, new)
    end
    return result
end

function util.filter_forward(pts, fun)
    check.set_next_function_name("util.filter_forward")
    check.arg(1, "pts", "table", pts)
    check.arg(2, "func", "function", func)
    local filtered = {}
    for i = 1, #pts, 1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function util.filter_backward(pts, fun)
    check.set_next_function_name("util.filter_backward")
    check.arg(1, "pts", "table", pts)
    check.arg(2, "func", "function", func)
    local filtered = {}
    for i = #pts, 1, -1 do
        if fun(pts[i]) then
            table.insert(filtered, pts[i]:copy())
        end
    end
    return filtered
end

function util.merge_forwards(pts, pts2)
    check.set_next_function_name("util.merge_forwards")
    check.arg(1, "pts", "table", pts)
    check.arg(2, "pts2", "table", pts2)
    for i = 1, #pts2 do
        table.insert(pts, pts2[i])
    end
end

function util.merge_backwards(pts, pts2)
    check.set_next_function_name("util.merge_backwards")
    check.arg(1, "pts", "table", pts)
    check.arg(2, "pts2", "table", pts2)
    for i = #pts2, 1, -1 do
        table.insert(pts, pts2[i])
    end
end

function util.merge_tables(t1, t2)
    check.set_next_function_name("util.merge_tables")
    check.arg(1, "t1", "table", t1)
    check.arg(2, "t2", "table", t2)
    local new = {}
    for i = 1, #t1 do
        table.insert(new, t1[i])
    end
    for i = 1, #t2 do
        table.insert(new, t2[i])
    end
    return new
end

function util.reverse(pts)
    check.set_next_function_name("util.reverse")
    check.arg(1, "pts", "table", pts)
    local new = {}
    for _, pt in ipairs(pts) do
        table.insert(new, 1, pt:copy())
    end
    return new
end

function util.make_insert_xy(pts, idx)
    check.set_next_function_name("util.make_insert_xy")
    check.arg(1, "pts", "table", pts)
    check.arg_optional(2, "idx", "number", idx)
    if idx then
        return function(x, y) table.insert(pts, idx, point.create(x, y)) end
    else
        return function(x, y) table.insert(pts, point.create(x, y)) end
    end
end

function util.make_insert_pts(pts, idx)
    check.set_next_function_name("util.make_insert_pts")
    check.arg(1, "pts", "table", pts)
    check.arg_optional(2, "idx", "number", idx)
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

function util.is_on_grid(num, grid)
    check.set_next_function_name("util.is_on_grid")
    check.arg(1, "num", "number", num)
    check.arg(2, "grid", "number", grid)
    return num % grid == 0
end

function util.check_grid(grid, ...)
    check.set_next_function_name("util.check_grid")
    check.arg(1, "grid", "number", grid)
    local args = { ... }
    for i = 2, select("#") do
        check.arg(i, string.format("c_%d", i - 1), "number", args[i])
    end
    for _, num in ipairs(args) do
        assert(num % grid == 0, string.format("number is not on-grid: %d", num))
    end
end

function util.intersection(s1, s2, c1, c2)
    check.set_next_function_name("util.intersection")
    check.arg_func(1, "s1", "point", s1, point.is_point)
    check.arg_func(2, "s2", "point", s2, point.is_point)
    check.arg_func(3, "c1", "point", c1, point.is_point)
    check.arg_func(4, "c2", "point", c2, point.is_point)
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

--[[
function util.intersection_ab(P, Q)
    check.set_next_function_name("util.intersection_ab")
    check.arg(1, "P", "table", P)
    check.arg(2, "Q", "table", Q)
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
--]]

function util.range(lower, upper, incr)
    check.set_next_function_name("util.range")
    check.arg(1, "lower", "number", lower)
    check.arg(2, "upper", "number", upper)
    check.arg_optional(3, "incr", "number", incr)
    local t = {}
    for i = lower, upper, incr or 1 do
        table.insert(t, i)
    end
    return t
end

function util.remove(t, comp)
    check.set_next_function_name("util.remove")
    check.arg(1, "t", "table", t)
    -- FIXME: check compt
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
    check.set_next_function_name("util.remove_index")
    check.arg(1, "t", "table", t)
    -- FIXME: check index
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
    check.set_next_function_name("util.remove_inplace")
    check.arg(1, "t", "table", t)
    -- FIXME: check index
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
    check.set_next_function_name("util.remove_index_inplace")
    check.arg(1, "t", "table", t)
    table.remove(t, index)
end

function util.clone_shallow(t)
    check.set_next_function_name("util.clone_shallow")
    check.arg(1, "t", "table", t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function util.clone_shallow_predicate(t, predicate)
    check.set_next_function_name("util.clone_shallow")
    check.arg(1, "t", "table", t)
    check.arg(2, "predicate", "function", predicate)
    local new = {}
    for k, v in pairs(t) do
        if predicate(k, v) then
            new[k] = v
        end
    end
    return new
end

function util.clone_array_predicate(t, predicate)
    check.set_next_function_name("util.clone_array_predicate")
    check.arg(1, "t", "table", t)
    check.arg(2, "predicate", "function", predicate)
    local new = {}
    for _, e in ipairs(t) do
        if predicate(e) then
            table.insert(new, e)
        end
    end
    return new
end

function util.find(t, value)
    check.set_next_function_name("util.find")
    check.arg(1, "t", "table", t)
    for i, v in ipairs(t) do
        if v == value then
            return i, v
        end
    end
end

function util.find_predicate(t, predicate, ...)
    check.set_next_function_name("util.find_predicate")
    check.arg(1, "t", "table", t)
    check.arg(2, "predicate", "function", predicate)
    for i, v in ipairs(t) do
        if predicate(v, ...) then
            return i, v
        end
    end
end

function util.fill_all_with(num, filler)
    check.set_next_function_name("util.fill_all_with")
    check.arg(1, "num", "number", num)
    local t = {}
    for i = 1, num do
        t[i] = filler
    end
    return t
end

function util.fill_predicate_with(num, filler, predicate, other)
    check.set_next_function_name("util.fill_predicate_with")
    check.arg(1, "num", "number", num)
    check.arg(3, "predicate", "function", predicate)
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
    check.set_next_function_name("util.fill_even_with")
    check.arg(1, "num", "number", num)
    return util.fill_predicate_with(num, filler, function(i) return i % 2 == 0 end, other)
end

function util.fill_odd_with(num, filler, other)
    check.set_next_function_name("util.fill_odd_with")
    check.arg(1, "num", "number", num)
    return util.fill_predicate_with(num, filler, function(i) return i % 2 == 1 end, other)
end

function util.sum(t)
    check.set_next_function_name("util.sum")
    check.arg(1, "t", "table", t)
    local total = 0
    for _, e in ipairs(t) do
        total = total + e
    end
    return total
end

function util.add_options(base, t)
    check.set_next_function_name("util.add_options")
    check.arg(1, "base", "table", base)
    check.arg_optional(2, "t", "table", t)
    local new = util.clone_shallow(base)
    if t then
        for k, v in pairs(t) do
            new[k] = v
        end
    end
    return new
end

function util.ratio_split_even(value, ratio)
    check.set_next_function_name("util.ratio_split_even")
    check.arg(1, "value", "number", value)
    check.arg(2, "ratio", "number", ratio)
    if value % 2 ~= 0 then
        moderror(string.format("util.ratio_split_even: value is not even (%d), can't be split into two even values", value))
    end
    local second = value // (ratio + 1)
    if second % 2 == 1 then
        second = second - 1
    end
    local first = value - second
    return first, second
end

function util.ratio_split_multiple_of(value, ratio, multiple)
    check.set_next_function_name("util.ratio_split_multiple_of")
    check.arg(1, "value", "number", value)
    check.arg(2, "ratio", "number", ratio)
    check.arg(3, "multiple", "number", multiple)
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
    check.set_next_function_name("util.round_to_grid")
    check.arg(1, "c", "number", c)
    check.arg(2, "grid", "number", grid)
    return grid * math.floor(c / grid + 0.5)
end

function util.fix_to_grid_higher(c, grid)
    check.set_next_function_name("util.fix_to_grid_higher")
    check.arg(1, "c", "number", c)
    check.arg(2, "grid", "number", grid)
    return grid * math.ceil(c / grid)
end

function util.fix_to_grid_lower(c, grid)
    check.set_next_function_name("util.fix_to_grid_lower")
    check.arg(1, "c", "number", c)
    check.arg(2, "grid", "number", grid)
    return grid * math.floor(c / grid)
end

function util.fix_to_grid_abs_higher(c, grid)
    check.set_next_function_name("util.fix_to_grid_abs_higher")
    check.arg(1, "c", "number", c)
    check.arg(2, "grid", "number", grid)
    if c < 0 then
        return -grid * math.ceil(-c / grid)
    else
        return grid * math.ceil(c / grid)
    end
end

function util.fix_to_grid_abs_lower(c, grid)
    check.set_next_function_name("util.fix_to_grid_abs_lower")
    check.arg(1, "c", "number", c)
    check.arg(2, "grid", "number", grid)
    if c < 0 then
        return -grid * math.floor(-c / grid)
    else
        return grid * math.floor(c / grid)
    end
end

function util.any_of(comp, t, ...)
    check.set_next_function_name("util.any_of")
    check.arg(1, "t", "table", t)
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
    check.set_next_function_name("util.all_of")
    check.arg(1, "t", "table", t)
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
    check.set_next_function_name("util.foreach")
    check.arg(1, "t", "table", t)
    check.arg(2, "f", "function", f)
    local new = {}
    for _, e in ipairs(t) do
        local res = table.pack(f(e, ...))
        for i = 1, res.n do
            table.insert(new, res[i])
        end
    end
    return new
end

function util.reduce(t, f, initial, ...)
    check.set_next_function_name("util.reduce")
    check.arg(1, "t", "table", t)
    check.arg(2, "f", "function", f)
    local value = initial
    for _, e in ipairs(t) do
        value = f(value, e, ...)
    end
    return value
end

function util.fit_lines_upper(total, size, space)
    check.set_next_function_name("util.fit_lines_upper")
    check.arg(1, "total", "number", total)
    check.arg(2, "size", "number", size)
    check.arg(3, "space", "number", space)
    return math.ceil((total + space) / (size + space))
end

function util.fit_lines_lower(total, size, space)
    check.set_next_function_name("util.fit_lines_lower")
    check.arg(1, "total", "number", total)
    check.arg(2, "size", "number", size)
    check.arg(3, "space", "number", space)
    return math.floor((total + space) / (size + space))
end

function util.fit_lines_fullwidth_grid(total, fullwidth, numlines, grid)
    check.set_next_function_name("util.fit_lines_fullwidth_grid")
    check.arg(1, "total", "number", total)
    check.arg(2, "fullwidth", "number", fullwidth)
    check.arg(3, "numlines", "number", numlines)
    check.arg_optional(4, "grid", "number", grid)
    if numlines < 2 then
        return 0
    end
    grid = grid or 1
    local space = math.floor((total - fullwidth) / (numlines - 1))
    while not util.is_on_grid(space, grid) do
        space = space - 1
    end
    return space
end

function util.fit_lines_width_grid(total, width, numlines, grid)
    check.set_next_function_name("util.fit_lines_width_grid")
    check.arg(1, "total", "number", total)
    check.arg(2, "width", "number", width)
    check.arg(3, "numlines", "number", numlines)
    check.arg_optional(4, "grid", "number", grid)
    return util.fit_lines_fullwidth_grid(total, numlines * width, numlines, grid)
end

function util.uniq(t)
    check.set_next_function_name("util.uniq")
    check.arg(1, "t", "table", t)
    local results = {}
    local set = {}
    for _, e in ipairs(t) do
        if not set[e] then
            set[e] = true
            table.insert(results, e)
        end
    end
    return results
end

function util.tconcatfmt(t, sep, fmt)
    local strt = {}
    for i = 1, #t do
        table.insert(strt, string.format(fmt, t[i]))
    end
    return table.concat(strt, sep);
end
