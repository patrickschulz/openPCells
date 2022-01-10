local M = {}

local cellwidths = {
    not_gate = 1,
    nor_gate = 2,
    nand_gate = 2,
    or_gate = 4,
    xor_gate = 10,
    dff = 21,
}

function M.digital(parent, width, cellnames, startpt, startanchor, noflipeven, growdirection)
    -- calculate row widths
    local rowwidths = {}
    for row, entries in ipairs(cellnames) do
        rowwidths[row] = 0
        for column, cellname in ipairs(entries) do
            if type(cellname) == "table" then
                cellname = cellname.reference
            end
            rowwidths[row] = rowwidths[row] + cellwidths[cellname]
        end
        -- check for too wide rows
        if rowwidths[row] > width then
            moderror("row width is to small to fit all cells in a row")
        end
    end

    -- equalize rows and insert fillers
    for row, rowcells in ipairs(cellnames) do
        local diff = width - rowwidths[row]
        if #rowcells > 1 then
            -- calculate width of holes
            local delta = diff // (#rowcells - 1) -- distributed correction (equal for all holes)
            local tocorrect = diff - (#rowcells - 1) * delta -- unequal correction (only applied for the first N holes)
            local corrected = 0
            local inscorrection = 0
            for i = 2, #rowcells do
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

                for j = 1, numfill do
                    table.insert(rowcells, i + inscorrection, "isogate")
                end
                inscorrection = inscorrection + numfill
            end
        else
            for i = 1, diff do
                table.insert(rowcells, "isogate")
            end
        end
    end

    return M.rowwise(parent, cellnames, startpt, startanchor, noflipeven, growdirection)
end

function M.rowwise(parent, cellnames, startpt, startanchor, noflipeven, growdirection)
    growdirection = growdirection or "upright"
    local cells = {}
    local references = {}

    local last
    local lastleft
    for row, entries in ipairs(cellnames) do
        cells[row] = {}
        for column, cellname in ipairs(entries) do
            local storebyname = false
            if type(cellname) == "table" then
                instname, cellname = cellname.instance, cellname.reference
                storebyname = true
            else
                instname = string.format("I_%d_%d", row, column + 1)
            end

            -- create reference
            if not references[cellname] then
                references[cellname] = pcell.add_cell_reference(pcell.create_layout(string.format("stdcells/%s", cellname)), cellname)
            end

            -- add cell
            local cell = parent:add_child(references[cellname], instname)

            -- position cell
            if column == 1 then
                if row == 1 then -- first cell
                    if startanchor and startpt then
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

            -- store cell link
            cells[row][column] = cell
            if storebyname then
                cells[instname] = cell
            end

            last = cell
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
