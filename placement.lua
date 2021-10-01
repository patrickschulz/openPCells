local M = {}

function M.digital(parent, cellnames, noflipeven, startanchor, startpt, growdirection)
    local last = object.create_omni()
    local lastleft
    growdirection = growdirection or "upright"
    startpt = startpt or point.create(0, 0)
    local cells = {}
    for row, entries in ipairs(cellnames) do
        cells[row] = {}
        for column, entry in ipairs(entries) do
            local cellname
            if type(entry) == "string" then
                cellname = entry
            else
                cellname = entry.cell
            end

            -- add child to parent
            local cell = parent:add_child(cellname)

            -- process extra arguments
            if type(entry) == "table" then
                for _, extra in ipairs(entry) do
                    if extra == "flipx" then
                        cell:flipx()
                    end
                end
            end

            -- if necessary, flip every second row
            if not noflipeven and (row % 2 == 0) then
                cell:flipy()
            end

            -- place cell relative the previous cells
            if column == 1 then
                if row == 1 then
                    if startanchor then
                        cell:move_anchor(startanchor, startpt)
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

            -- store cells for later use
            last = cell
            cells[row][column] = cell
        end
    end
    return cells
end

return M
