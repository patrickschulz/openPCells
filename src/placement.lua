local M = {}

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
            elseif search < numfill then
                search = search + 1
            else
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

function M.digital(parent, pitch, width, cellnames, fillers, utilization, noflipeven, startanchor, startpt, growdirection)
    check_number_range(utilization, { lower = 0, lowerinclusive = false, upper = 1, upperinclusive = true })
    local last
    local lastleft
    startanchor = startanchor or "left"
    growdirection = growdirection or "upright"
    startpt = startpt or point.create(0, 0)
    local cells = {}
    local rowwidths = {}

    for row, entries in ipairs(cellnames) do
        cells[row] = {}
        rowwidths[row] = 0
        for column, cellname in ipairs(entries) do
            local cell = parent:add_child(cellname, string.format("I_%d_%d", row, column + 1))
            local w = cell:width_height_alignmentbox()
            if column == 1 then
                if row == 1 then -- first cell
                    cell:move_anchor(startanchor, startpt)
                    lastleft = cell
                else
                    cell:move_anchor("bottomleft", lastleft:get_anchor("topleft"))
                end
                lastleft = cell
            else
                cell:move_anchor("left", last:get_anchor("right"))
            end

            last = cell
            rowwidths[row] = rowwidths[row] + w

            cells[row][column] = cell
        end
    end

    -- equalize cells and insert fillers
    for row, cs in ipairs(cells) do
        local diff = (width - rowwidths[row]) // pitch
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

return M
