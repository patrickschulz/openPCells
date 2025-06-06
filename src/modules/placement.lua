--[[
This module provides two methodologies:
 * functions around importing verilog netlists and creating a cell placement (top part)
 * functions around creating actual layouts, to be used within cell definitions (lower part)
--]]
---------------------------------------------------------------------------------
--                             Placement functions                             --
---------------------------------------------------------------------------------

local function _get_geometry(instances)
    local total_width = 0
    local required_min_width = 0
    for _, instance in ipairs(instances) do
        local width = instance.width
        total_width = total_width + width
        required_min_width = math.max(required_min_width, width)
    end
    return required_min_width, total_width
end

local function _create_options(fixedrows, required_min_width, total_width, utilization, aspectratio)
    local height = 7 -- FIXME
    local area = total_width * height
    local floorplan_width, floorplan_height
    if fixedrows then
        floorplan_height = fixedrows
        floorplan_width = total_width / utilization / fixedrows
    else
        floorplan_width = math.sqrt(area / utilization * aspectratio)
        floorplan_height = math.sqrt(area / utilization / aspectratio)

        -- check for too narrow floorplan
        if floorplan_width < required_min_width then
            floorplan_width = required_min_width / math.sqrt(utilization)
            floorplan_height = area / utilization / floorplan_width
            print("Floorplan width is smaller than required width, this will be fixed.")
            print(string.format("The actual aspect ratio (%.2f) will differ from the specified aspect ratio (%.2f)",
                floorplan_width / floorplan_height, aspectratio)
            )
        end

        -- normalize
        floorplan_height = math.ceil(floorplan_height / height)
    end

    local options = {
        floorplan_width = math.ceil(floorplan_width),
        floorplan_height = math.ceil(floorplan_height),
        desired_row_width = math.ceil(total_width / floorplan_height * utilization),
        movespercell = movespercell,
        report = report
    }

    -- check floorplan options
    if options.floorplan_width == 0 then
        moderror("floorplan width is zero")
    end
    if options.floorplan_height == 0 then
        moderror("floorplan height is zero")
    end
    if options.desired_row_width == 0 then
        moderror("desired row width is zero")
    end
    if options.desired_row_width > options.floorplan_width then
        moderror(string.format("desired row width (%d) must be smaller than floorplan width (%d)",
            options.desired_row_width, options.floorplan_width)
        )
    end
    return options
end

function placement.create_floorplan_aspectratio(instances, utilization, aspectratio)
    -- placer options
    local required_min_width, total_width = _get_geometry(instances)
    local options = _create_options(nil, required_min_width, total_width, utilization, aspectratio)
    return options
end

function placement.create_floorplan_fixed_rows(circuit, utilization, numrows)
    -- placer options
    if #circuit.instances < numrows then
        moderror(string.format("placement.create_floorplan_fixed_rows: number of rows (%d) must not be larger than number of instances (%d)", numrows, #circuit.instances))
    end
    local required_min_width, total_width = _get_geometry(circuit.instances)
    local options = _create_options(numrows, required_min_width, total_width, utilization) -- aspectratio not used
    return options
end

function _sanitize_rows(rows)
    for row = #rows, 1, -1 do
        if #rows[row] == 0 then
            table.remove(rows, row)
        end
    end
end

function placement.optimize(circuit, floorplan)
    local rows = placer.place_simulated_annealing(circuit.instances, circuit.nets, floorplan)
    _sanitize_rows(rows) -- removes empty rows
    return rows
end

function placement.manual(circuit, names)
    local rows = {}
    local processed = {}
    for _, rownames in ipairs(names) do
        local row = {}
        for _, name in ipairs(rownames) do
            for _, inst in ipairs(circuit.instances) do
                if inst.instance == name then
                    processed[name] = true
                    table.insert(row, inst)
                end
            end
        end
        table.insert(rows, row)
    end
    for _, rownames in ipairs(names) do
        local row = {}
        for _, name in ipairs(rownames) do
            if not processed[name] then
                moderror(string.format("placement.manual: provide instance name of unknown/unused instance: '%s'", name))
            end
        end
    end
    return rows
end

function placement.insert_filler_names(rows, width)
    -- calculate row widths
    local rowwidths = {}
    for row, entries in ipairs(rows) do
        rowwidths[row] = 0
        for column, cellname in ipairs(entries) do
            local cellwidth = cellname.width
            rowwidths[row] = rowwidths[row] + cellwidth
        end
        -- check for too wide rows
        if rowwidths[row] > width then
            moderror("row width is too small to fit all cells in a row")
        end
    end

    -- equalize rows and insert fillers
    for row, rowcells in ipairs(rows) do
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
                        instance = string.format("fill_%d_%d", row, j + inscorrection),
                        reference = "isogate",
                        width = 1,
                    })
                end
                inscorrection = inscorrection + numfill
            end
        else
            for i = 1, diff do
                table.insert(rowcells, {
                    instance = string.format("fill_%d_%d", row, i),
                    reference = "isogate",
                    width = 1,
                })
            end
        end
    end
end

---------------------------------------------------------------------------------
--                         In-cell layout functions                            --
---------------------------------------------------------------------------------
function placement.create_reference_rows(cellnames, xpitch, commonargs)
    if not cellnames or type(cellnames) ~= "table" then
        moderror("placement.create_reference_rows: table for 'cellnames' (first argument) expected")
    end
    if not xpitch or type(xpitch) ~= "number" then
        moderror("placement.create_reference_rows: number for 'xpitch' (second argument) expected")
    end
    local names = {}
    local references = {}
    for row, entries in ipairs(cellnames) do
        names[row] = {}
        for column, entry in ipairs(entries) do
            local instance, cellname, args
            if type(entry) == "table" then
                instance = entry.instance
                cellname = entry.reference
                args = entry.args
            else
                instance = string.format("I_%d_%d", row, column)
                cellname = entry
            end
            if not references[cellname] then
                references[cellname] = pcell.create_layout(cellname, cellname, util.add_options(commonargs, args))
            end
            names[row][column] = {
                instance = instance,
                reference = references[cellname],
                width = references[cellname]:width_height_alignmentbox() / xpitch
            }
        end
    end
    return names
end

function placement.digital(parent, rows, width, flipfirst, noflip)
    -- calculate row widths
    local rowwidths = {}
    for row, entries in ipairs(rows) do
        rowwidths[row] = 0
        for column, entry in ipairs(entries) do
            local cellwidth = entry.width
            rowwidths[row] = rowwidths[row] + cellwidth
        end
        -- check for too wide rows
        if rowwidths[row] > width then
            moderror("row width is too small to fit all cells in a row")
        end
    end

    local fillref = pcell.create_layout("stdcells/isogate", "fill")

    -- equalize rows and insert fillers
    for row, rowcells in ipairs(rows) do
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
                    instance = string.format("fill_%d_%d", row, i),
                    reference = fillref,
                    width = 1,
                })
            end
        end
    end

    return placement.rowwise(parent, rows, not flip, flipfirst)
end

function placement.rowwise(parent, cellsdef, flipeverysecondrow, flipfirst)
    local cells = {}
    local references = {}

    local last
    local lastborder
    for rownum, row in ipairs(cellsdef) do
        cells[rownum] = {}
        for columnnum, entry in ipairs(row) do
            -- add cell
            local cell = parent:add_child(entry.reference, entry.instance)

            -- position cell
            if columnnum == 1 then
                if rownum == 1 then -- first cell
                else
                    cell:align_left(lastborder)
                    cell:abut_top(lastborder)
                end
                lastborder = cell
            else
                cell:align_bottom(last)
                cell:abut_right(last)
            end

            -- flip individual cells
            if entry.flipx then
                cell:flipx()
            end
            if entry.flipy then
                cell:flipy()
            end

            -- store cell link (numeric and by name)
            cells[rownum][columnnum] = cell
            cells[entry.instance] = cell

            last = cell
        end
    end

    -- check row flips
    for rownum = 1, #cells do
        local row = cellsdef[rownum]
        if row.flip then
            for columnnum = 1, #cells[rownum] do
                cells[rownum][columnnum]:flipy()
            end
        end
    end

    -- flip every second row
    if flipeverysecondrow then
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

    -- update parent alignment box
    parent:inherit_alignment_box(cells[1][1])
    parent:inherit_alignment_box(cells[#cells][#cells[#cells]])

    return cells
end

function placement.rowwise_flat(parent, cellsdef, flip, flipfirst)
    local cells = {}
    local references = {}

    local last
    local lastborder
    for rownum, row in ipairs(cellsdef) do
        cells[rownum] = {}
        for columnnum, entry in ipairs(row) do
            -- add cell
            local cell = entry.reference:copy()

            -- position cell
            if columnnum == 1 then
                if rownum == 1 then -- first cell
                else
                    cell:align_left(lastborder)
                    cell:abut_top(lastborder)
                end
                lastborder = cell
            else
                cell:align_bottom(last)
                cell:abut_right(last)
            end

            -- flip individual cells
            if entry.flipx then
                cell:flipx()
            end
            if entry.flipy then
                cell:flipy()
            end

            -- merge into parent
            parent:merge_into(cell)

            -- store cell link (numeric and by name)
            cells[rownum][columnnum] = cell
            cells[entry.instance] = cell

            last = cell
        end
    end

    -- check row flips
    for rownum = 1, #cells do
        local row = cellsdef[rownum]
        if row.flip then
            for columnnum = 1, #cells[rownum] do
                cells[rownum][columnnum]:flipy()
            end
        end
    end

    -- flip every second row
    if flip then
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

    -- update parent alignment box
    parent:inherit_alignment_box(cells[1][1])
    parent:inherit_alignment_box(cells[#cells][#cells[#cells]])

    return cells
end

function placement.columnwise(parent, cellsdef, flip, flipfirst)
    local cells = {}
    local references = {}

    local last
    local lastborder
    for columnnum, column in ipairs(cellsdef) do
        cells[columnnum] = {}
        for rownum, entry in ipairs(column) do
            -- add cell
            local cell = parent:add_child(entry.reference, entry.instance)

            -- position cell
            if rownum == 1 then
                if columnnum == 1 then -- first cell
                else
                    cell:align_bottom(lastborder)
                    cell:abut_right(lastborder)
                end
                lastborder = cell
            else
                cell:align_left(last)
                cell:abut_top(last)
            end

            -- flip individual cells
            if entry.flipx then
                cell:flipx()
            end
            if entry.flipy then
                cell:flipy()
            end

            -- store cell link (numeric and by name)
            cells[columnnum][rownum] = cell
            cells[entry.instance] = cell

            last = cell
        end
    end

    -- check column flips
    for columnnum = 1, #cells do
        local column = cellsdef[columnnum]
        if column.flip then
            for row = 1, #cells[columnnum] do
                cells[columnnum][row]:flipx()
            end
        end
    end

    -- flip every second column
    if flip then
        local flip = flipfirst
        for column = 1, #cells do
            if flip then
                for row = 1, #cells[column] do
                    cells[column][row]:flipx()
                end
            end
            flip = not flip
        end
    end

    -- update parent alignment box
    parent:inherit_alignment_box(cells[1][1])
    parent:inherit_alignment_box(cells[#cells][#cells[#cells]])

    return cells
end

function placement.columnwise_flat(parent, cellsdef, flip, flipfirst)
    local cells = {}
    local references = {}

    local last
    local lastborder
    for columnnum, column in ipairs(cellsdef) do
        cells[columnnum] = {}
        for rownum, entry in ipairs(column) do
            -- add cell
            local cell = entry.reference:copy()

            -- position cell
            if rownum == 1 then
                if columnnum == 1 then -- first cell
                else
                    cell:align_bottom(lastborder)
                    cell:abut_right(lastborder)
                end
                lastborder = cell
            else
                cell:align_left(last)
                cell:abut_top(last)
            end

            -- flip individual cells
            if entry.flipx then
                cell:flipx()
            end
            if entry.flipy then
                cell:flipy()
            end

            -- merge into parent
            parent:merge_into(cell)

            -- store cell link (numeric and by name)
            cells[columnnum][rownum] = cell
            cells[entry.instance] = cell

            last = cell
        end
    end

    -- check column flips
    for columnnum = 1, #cells do
        local column = cellsdef[columnnum]
        if column.flip then
            for row = 1, #cells[columnnum] do
                cells[columnnum][row]:flipx()
            end
        end
    end

    -- flip every second column
    if flip then
        local flip = flipfirst
        for column = 1, #cells do
            if flip then
                for row = 1, #cells[column] do
                    cells[column][row]:flipx()
                end
            end
            flip = not flip
        end
    end

    -- update parent alignment box
    parent:inherit_alignment_box(cells[1][1])
    parent:inherit_alignment_box(cells[#cells][#cells[#cells]])

    return cells
end
