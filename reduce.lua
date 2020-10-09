local M = {}
function M.remove_superfluous_points(pts)
    local new = {}
    table.insert(new, pts[1])
    for i = 2, #pts - 1 do
        local x0, y0 = pts[i - 1]:unwrap()
        local x1, y1 = pts[i    ]:unwrap()
        local x2, y2 = pts[i + 1]:unwrap()
        local dxl = x1 - x0
        local dyl = y1 - y0
        local dxr = x2 - x1
        local dyr = y2 - y1
        if not ((dxl == dxr) and (dyl == dyr)) then
            table.insert(new, pts[i])
        end
    end
    table.insert(new, pts[#pts])
    return new
end

return M
