local M = {}

function M.create_reference_rows(cellnames)
    local names = {}
    local references = {}
    local cellwidths = {
        not_gate = 1,
        nor_gate = 2,
        nand_gate = 2,
        or_gate = 4,
        xor_gate = 10,
        dff = 21,
        dffp = 21,
        dffn = 21,
    }
    local cell_map = {
        dffp = {
            name = "dff",
            parameters = { clockpolarity = "positive" }
        },
        dffn = {
            name = "dff",
            parameters = { clockpolarity = "negative" }
        },
    }
    for row, entries in ipairs(cellnames) do
        names[row] = {}
        for column, cellname in ipairs(entries) do
            if not references[cellname] then
                local mapped = cell_map[cellname]
                if mapped then
                    references[cellname] = pcell.add_cell_reference(pcell.create_layout(string.format("stdcells/%s", mapped.name), mapped.parameters), cellname)
                else
                    references[cellname] = pcell.add_cell_reference(pcell.create_layout(string.format("stdcells/%s", cellname)), cellname)
                end
            end
            names[row][column] = { 
                instance = string.format("I_%d_%d", row, column),
                reference = references[cellname],
                width = cellwidths[cellname]
            }
        end
    end
    return names
end

function M.digital(parent, cellnames, width, startpt, startanchor, flipfirst, growdirection, noflip)
    -- calculate row widths
    local rowwidths = {}
    for row, entries in ipairs(cellnames) do
        rowwidths[row] = 0
        for column, cellname in ipairs(entries) do
            local cellwidth = cellname.width
            rowwidths[row] = rowwidths[row] + cellwidth
        end
        -- check for too wide rows
        if rowwidths[row] > width then
            moderror("row width is to small to fit all cells in a row")
        end
    end

    local fillref = pcell.add_cell_reference(pcell.create_layout("stdcells/isogate"), "fill")

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
                    table.insert(rowcells, i + inscorrection, {
                        instance = string.format("fill_%d_%d", row, j),
                        reference = fillref,
                        width = 1,
                    })
                end
                inscorrection = inscorrection + numfill
            end
        else
            for i = 1, diff do
                table.insert(rowcells, {
                    instance = string.format("fill_%d_%d", row, j),
                    reference = fillref,
                    width = 1,
                })
            end
        end
    end

    return M.rowwise(parent, cellnames, startpt, startanchor, flipfirst, growdirection, noflip)
end

function M.rowwise(parent, cellnames, startpt, startanchor, flipfirst, growdirection, noflip)
    growdirection = growdirection or "upright"
    local cells = {}
    local references = {}

    local last
    local lastleft
    for row, entries in ipairs(cellnames) do
        cells[row] = {}
        for column, cellname in ipairs(entries) do
            -- add cell
            local cell = parent:add_child(cellname.reference, cellname.instance)

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
            cells[cellname.instance] = cell

            last = cell
        end
    end

    -- flip every second row
    if not noflip then
        local flip = flipfirst
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
