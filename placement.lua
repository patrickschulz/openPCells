local M = {}

function M.digital(parent, cellnames, startanchor, growdirection)
    local last = object.create_omni()
    local lastleft
    growdirection = growdirection or "upright"
    local cells = {}
    for r, row in ipairs(cellnames) do
        cells[r] = {}
        for c, cellname in ipairs(row) do
            local cell = parent:add_child(cellname)
            if r % 2 == 0 then
                cell:flipy()
            end
            if c == 1 then
                if r == 1 then
                    if startanchor then
                        cell:move_anchor(startanchor)
                    end
                else
                    if string.match(growdirection, "up") then
                        cell:move_anchor("bottom", lastleft:get_anchor("top"))
                    else
                        cell:move_anchor("top", lastleft:get_anchor("bottom"))
                    end
                end
                lastleft = cell
            else
                if string.match(growdirection, "left") then
                    cell:move_anchor("right", last:get_anchor("left"))
                else
                    cell:move_anchor("left", last:get_anchor("right"))
                end
            end
            last = cell
            cells[r][c] = cell
        end
    end
    return cells
end

return M
