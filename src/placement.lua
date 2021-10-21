local M = {}

local function _fix_to_grid(num, grid)
    return grid * math.floor(num / grid)
end

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
            local cell = parent:add_child(cellname, string.format("I_%d_%d", row, column))

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

local warningissued = false
local function _add_fillers(parent, fillers, numfill, anchor)
    local inserted = {}
    if fillers then
        local search = 0
        while numfill > 0 do
            if fillers[numfill - search] then
                local fill = parent:add_child(fillers[numfill - search], "fill")
                fill:move_anchor("left", anchor)
                table.insert(inserted, fill)
                anchor = fill:get_anchor("right")
                numfill = search
                search = 0
            else
                search = search + 1
            end
            if search >= numfill then
                if not warningissued then
                    print("Can't find solution to insert fillers.")
                    print("This happens, when the fill cells can not be combined to form any arbitrary integer")
                    print("The easiest fix is to add a filler cell with a width of one pitch")
                    warningissued = true
                end
                break
            end
        end
    end
    return inserted
end

function M.digital_auto(parent, pitch, width, cellnames, fillers, utilization, noflipeven, startanchor, startpt, growdirection)
    check_number_range(utilization, { lower = 0, lowerinclusive = false, upper = 1, upperinclusive = true })
    local last = object.create_omni()
    local lastleft
    startanchor = startanchor or "left"
    growdirection = growdirection or "upright"
    startpt = startpt or point.create(0, 0)
    local cells = { {} } -- at least one row
    local rowwidths = { 0 }
    local row = 1
    local column = 0
    for _, cellname in ipairs(cellnames) do
        local cell = parent:add_child(cellname, string.format("I_%d_%d", row, column + 1))
        local w = cell:width_height_alignmentbox()
        if not lastleft then -- first cell
            cell:move_anchor(startanchor, startpt)
            lastleft = cell
        else
            if rowwidths[row] + w > width * utilization then -- new row
                cell:move_anchor("bottomleft", lastleft:get_anchor("topleft"))
                lastleft = cell
                row = row + 1
                column = 0
                cells[row] = {}
                rowwidths[row] = 0
            else -- current row
                cell:move_anchor("left", last:get_anchor("right"))
            end
        end

        last = cell
        rowwidths[row] = rowwidths[row] + w

        column = column + 1
        cells[row][column] = cell
    end

    -- equalize cells and insert fillers
    for row, cs in ipairs(cells) do
        local widthdiff = width
        for _, c in ipairs(cs) do widthdiff = widthdiff - c:width_height_alignmentbox() end
        local diff = widthdiff // pitch
        if #cs > 1 then
            -- calculate width of holes
            local delta = diff // (#cs - 1) -- distributed correction (equal for all holes)
            local tocorrect = diff - (#cs - 1) * delta -- unequal correction (only applied for the first N holes)
            local corrected = 0
            local inscorrection = 0
            local numcells = #cs
            for i = 2, numcells do
                local num = (i - 1) * delta + corrected

                -- correct for unequally distributed shifts
                -- this is needed when the required amount is indivisible by the number of holes
                local numfill = delta
                if tocorrect > 0 then
                    num = num + 1
                    numfill = numfill + 1
                    tocorrect = tocorrect - 1
                    corrected = corrected + 1
                end

                -- insert fillers into cells table (for later reference such as flipping rows)
                local inserted = _add_fillers(parent, fillers, numfill, cs[i + inscorrection - 1]:get_anchor("right"))
                for _, fill in ipairs(inserted) do
                    table.insert(cs, i + inscorrection, fill)
                    inscorrection = inscorrection + 1
                end

                cs[i + inscorrection]:translate(num * pitch, 0)
            end
        else
            local numfill = diff

            local inserted = _add_fillers(parent, fillers, numfill, cs[1]:get_anchor("right"))
            for i, fill in ipairs(inserted) do
                table.insert(cs, i + 1, fill)
            end
        end
    end

    -- flip every second row
    if not noflipeven then
        local flip = false
        for row = 1, #cells do
            if flip then
            for column = 1, #cells[row] do
                    cells[row][column]:flipy()
                end
            end
            flip = not flip
        end
    end

    return cells
end

function M.digital_regular(parent, cellname, rows, columns, noflipeven, startanchor, startpt, growdirection)
    local cellnames = {}
    for row = 1, rows do
        cellnames[row] = {}
        for column = 1, columns do
            cellnames[row][column] = cellname
        end
    end
    return M.digital(parent, cellnames, noflipeven, startanchor, startpt, growdirection)
end

return M
