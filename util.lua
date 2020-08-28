local M = {}

function M.xmirror(pts, xcenter)
    local mirrored = {}
    local xcenter = xcenter or 0
    for i, pt in ipairs(pts) do
        mirrored[i] = point.create(2 * xcenter - pt.x, pt.y)
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

function M.make_append_xy(pts) 
    return function(x, y) table.insert(pts, point.create(x, y)) end
end

function M.make_append_pts(pts) 
    return function(...) 
        for _, pt in ipairs({ ... }) do 
            table.insert(pts, pt)
        end
    end
end


function M.is_point_in_polygon(pt, pts)
    local j = #pts
    local c = nil 
    for i = 1, #pts do
        local pti = pts[i]
        local ptj = pts[j]
        if ((pti.y > pt.y) ~= (ptj.y > pt.y)) and (pt.x < pti.x + (ptj.x - pti.x) * (pt.y - pti.y) / (ptj.y - pti.y)) 
            then
            c = not(c)
        end
        j = i
    end
    return c
end

return M

--[[
procedure(MSCUtilSanitizePoints(pts grid)
	let(
		(x y dx dy pt prevpt res)
		prevpt = MSCUtilSnapToGrid(car(pts) grid)
		res = tconc(nil prevpt)
		for(i 2 length(pts)
			pt = nthelem(i pts)
			x = grid * fix(xCoord(pt) / grid)
			y = grid * fix(yCoord(pt) / grid)
			dx = x - xCoord(prevpt)
			dy = y - yCoord(prevpt)
			
			when(abs(dx) <= grid dx = 0.0)
			when(abs(dy) <= grid dy = 0.0)
			
			when(abs(dx) > 0 && abs(dy) > 0 
				if(abs(dx) > abs(dy)
					dy = dy / abs(dy) * abs(dx)
					dx = dx / abs(dx) * abs(dy)
				)
			)
			
			x = xCoord(prevpt) + dx
			y = yCoord(prevpt) + dy
			
			res = tconc(res x:y)
			prevpt = x:y
		)
		car(res)
	)
)
--]]
