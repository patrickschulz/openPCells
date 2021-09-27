local M = {}

function M.digital(parent, cellnames, rows, columns)
    local last = object.create_omni()
    local lastleft = object.create_omni()
    local cells = {}
    for r, row in ipairs(cellnames) do
        cells[r] = {}
        for c, cellname in ipairs(row) do
            local cell = parent:add_child(cellname)
            if r % 2 == 0 then
                cell:flipy()
            end
            if c == 1 then
                cell:move_anchor("bottom", lastleft:get_anchor("top"))
                lastleft = cell
            else
                cell:move_anchor("left", last:get_anchor("right"))
            end
            last = cell
            cells[r][c] = cell
        end
    end
    return cells
end

return M
