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

function M.merge_shapes(cell)
    -- merge rectangles
    for _, lpp in cell:layers() do
        local rectangles = {}
        for i, S in cell:iter(function(S) return S.lpp:str() == lpp:str() end) do
            if S:is_type("rectangle") then
                table.insert(rectangles, S:get_points())
                cell:remove_shape(i)
            end
        end
        union.rectangle_all(rectangles)
        for i = 1, #rectangles do
            local result = rectangles[i]
            local S = shape.create_rectangle_bltr(lpp, result.bl, result.tr)
            cell:add_shape(S)
        end
    end
end

return M
