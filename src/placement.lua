local M = {}

local function _get_geometry(instances)
    local total_width = 0
    local required_width = 0
    for _, instance in ipairs(instances) do
        local width = instance.width
        total_width = total_width + width
        required_width = math.max(required_width, width)
    end
    return required_width, total_width
end

local function _create_options(fixedrows, required_width, total_width, utilization, aspectratio)
    local height = 7
    local area = total_width * height
    local floorplan_width, floorplan_height
    if fixedrows then
        floorplan_height = fixedrows
        floorplan_width = total_width / utilization / fixedrows
    else
        floorplan_width = math.sqrt(area / utilization * aspectratio)
        floorplan_height = math.sqrt(area / utilization / aspectratio)

        -- check for too narrow floorplan
        if floorplan_width < required_width then
            floorplan_width = required_width / math.sqrt(utilization)
            floorplan_height = area / utilization / floorplan_width
            print("Floorplan width is smaller than required width, this will be fixed.")
            print(string.format("The actual aspect ratio (%.2f) will differ from the specified aspect ratio (%.2f)", floorplan_width / floorplan_height, aspectratio))
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
    if options.desired_row_width >= options.floorplan_width then
        moderror("desired row width must be smaller than floorplan width")
    end
    return options
end

function _sanitize_rows(rows)
    for row = #rows, 1, -1 do
        if #rows[row] == 0 then
            table.remove(rows, row)
        end
    end
end

function M.optimize(instances, nets, utilization, aspectratio)
    -- placer options
    local required_width, total_width = _get_geometry(instances)
    local options = _create_options(fixedrows, required_width, total_width, utilization, aspectratio)

    local rows = placer.place_simulated_annealing(instances, nets, options)
    _sanitize_rows(rows) -- removes empty rows
    return rows
end

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
    -- the cell map allows different cells in the gate netlist to actually use the same pcell (e.g. dffp vs. dffn)
    -- Also, mapping allows the use of cell parameters
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
        for column, entry in ipairs(entries) do
            local instance, cellname
            if type(entry) == "table" then
                instance = entry.instance
                cellname = entry.reference
            else
                instance = string.format("I_%d_%d", row, column)
                cellname = entry
            end
            if not references[cellname] then
                local mapped = cell_map[cellname]
                if mapped then
                    references[cellname] = pcell.add_cell_reference(pcell.create_layout(string.format("stdcells/%s", mapped.name), mapped.parameters), cellname)
                else
                    references[cellname] = pcell.add_cell_reference(pcell.create_layout(string.format("stdcells/%s", cellname)), cellname)
                end
            end
            names[row][column] = { 
                instance = instance,
                reference = references[cellname],
                width = cellwidths[cellname]
            }
        end
    end
    return names
end

function M.format_rows(cellnames)
    local rows = {}
    for row, entries in ipairs(cellnames) do
        rows[row] = {}
        for column, entry in ipairs(entries) do
            local cellname = entry
            rows[row][column] = { 
                instance = string.format("I_%d_%d", row, column),
                reference = entry,
            }
        end
    end
    return rows
end

function M.regular_rows(cellname, numrows, numcolumns)
    local rows = {}
    for row = 1, numrows do
        rows[row] = {}
        for col = 1, numcolumns do
            rows[row][col] = { reference = cellname, instance = string.format("cell_%d_%d", row, col) }
        end
    end
    return rows
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
                    instance = string.format("fill_%d_%d", row, i),
                    reference = fillref,
                    width = 1,
                })
            end
        end
    end

    return M.rowwise(parent, cellnames, startpt, startanchor, flipfirst, growdirection, noflip)
end

function M.rowwise(parent, cellnames, startpt, startanchor, flipfirst, growdirection, noflip)
    startpt = startpt or point.create(0, 0)
    growdirection = growdirection or "upright"
    local cells = {}
    local references = {}

    local last
    local lastborder
    for row, entries in ipairs(cellnames) do
        cells[row] = {}
        for column, cellname in ipairs(entries) do
            -- add cell
            local cell = parent:add_child(cellname.reference, cellname.instance)

            -- position cell
            if column == 1 then
                if row == 1 then -- first cell
                    if startanchor then
                        cell:move_anchor(startanchor, startpt)
                    else
                        cell:translate(startpt)
                    end
                else
                    if string.match(growdirection, "up") then
                        if string.match(growdirection, "right") then
                            cell:move_anchor("bottomleft", lastborder:get_anchor("topleft"))
                        else
                            cell:move_anchor("bottomright", lastborder:get_anchor("topright"))
                        end
                    else
                        if string.match(growdirection, "right") then
                            cell:move_anchor("topleft", lastborder:get_anchor("bottomleft"))
                        else
                            cell:move_anchor("topright", lastborder:get_anchor("bottomright"))
                        end
                    end
                end
                lastborder = cell
            else
                if string.match(growdirection, "left") then
                    cell:move_anchor("right", last:get_anchor("left"))
                else
                    cell:move_anchor("left", last:get_anchor("right"))
                end
            end

            -- store cell link (numeric and by name)
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

