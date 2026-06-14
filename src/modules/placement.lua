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

local function _sanitize_rows(rows)
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

local function _find_object_place(places, object)
    for _, place in ipairs(places) do
        if place.object == object then
            return place.x, place.y
        end
    end
    return nil
end

local function _calculate_total_wire_length(wires, places, weights)
    local total_wire_length = 0
    local num_jogs = 0
    for _, wire in ipairs(wires) do
        local minx = math.huge
        local miny = math.huge
        local maxx = -math.huge
        local maxy = -math.huge
        for _, object in ipairs(wire.targets) do
            local x, y = _find_object_place(places, object)
            minx = math.min(minx, x)
            miny = math.min(miny, y)
            maxx = math.max(maxx, x)
            maxy = math.max(maxy, y)
        end
        local xlength = maxx - minx
        local ylength = maxy - miny
        local jog = ((xlength > 0) and (ylength > 0)) and 1 or 0
        num_jogs = num_jogs + weights.jog * jog
        total_wire_length =
            total_wire_length
            + weights.x_wirelength * xlength
            + weights.y_wirelength * ylength
    end
    return weights.wirelength * total_wire_length + num_jogs
end

local function _generate_object_placement(permutation, numx, numy)
    local places = {}
    local index = 1
    local run = true
    for x = 1, numx do
        for y = 1, numy do
            if run then
                table.insert(places, {
                    object = permutation[index],
                    x = x,
                    y = y,
                })
                --places[object.name] = object
                index = index + 1
            end
            if index > #permutation then -- grid has more places than available devices
                run = false
            end
        end
    end
    return places
end

local function _get_group_index(groups, device)
    for index, group in ipairs(groups) do
        if util.any_of(device.name, group) then
            return index
        end
    end
    return nil
end

local function _is_local_net(netname, groups)
    local counter = 0
    for _, group in ipairs(groups) do
        local found = false
        for _, device in ipairs(group.devices) do
            for _, net in pairs(device.connections) do
                if net == netname then
                    found = true
                end
            end
        end
        if found then
            counter = counter + 1
        end
    end
    return counter == 1 -- net is only present in one group
end

local function _run_placement(objects, wires, weights)
    local numobjects = #objects
    local permutations = util.generate_all_permutations(objects)
    local total_wire_length = math.huge
    local numx_result
    local numy_result
    local perm_index
    -- iterate over all grid combinations
    -- the size is calculated based on the number of objects in x,
    -- so that numx * numy == numobjects
    -- this will not always fit (the grid will be larger sometimes)
    -- so just fill grid places starting at (1, 1) until there are no objects left
    for numx = 1, numobjects do
        local numy = math.ceil(numobjects / numx)
        for permnum, permutation in ipairs(permutations) do
            -- generate placement
            local places = _generate_object_placement(permutation, numx, numy)
            -- calculate wire length
            local new_length = _calculate_total_wire_length(wires, places, weights)
            -- compare to previous results
            if new_length < total_wire_length then
                total_wire_length = new_length
                numx_result = numx
                numy_result = numy
                perm_index = permnum
            end
        end
    end

    -- re-generate best placement as result
    local places = _generate_object_placement(
        permutations[perm_index],
        numx_result, numy_result
    )

    return places
end

local function _get_wire_by_name(wires, netname)
    for _, wire in ipairs(wires) do
        if wire.net == netname then
            return wire
        end
    end
    return nil
end

function placement.place_analog(devices, groups, constraints, ignored_nets)
    -- notes to me:
    -- * the analog placer is currently very simple and rather brute-force.
    --   It simply computes every permutation and checks if that is a possible placement.
    --   If it is, it minimizes the wire length as sole optimization target.
    --   Obviously there should be more optimization targets, but with proper group support
    --   this will probably work reasonable well (as the groups already force
    --   a lot of symmetry and short wires).
    -- * groups should create some sort of 'super device', so that
    --   only connections between this group and other groups/devices
    --   are considered for placement.
    --   The global placement then is performed as if the routing of
    --   group-local nets has no costs.
    --   The local in-group placement can then be done in the same way.
    --   There is probably some potential for optimizing group interconnects
    --   by placing them properly ('pins' close to the edges), but this is secondary.
    -- * add simple symmetry constraints

    local penalties = constraints.penalties or {}
    local weights = {
        wirelength = penalties.wirelength or 1,
        x_wirelength = penalties.x_wirelength or 1,
        y_wirelength = penalties.y_wirelength or 1,
        jog = penalties.wire_jogs or 0,
    }

    -- put every device in a group.
    -- if it is specified in 'groups' put all devices that belong to it in the same group.
    -- wire length collection is only done for wires that connect groups.
    -- for singular devices, this makes no difference, but for groups with multiple devices
    -- there might be some nets that don't need to be routed and are ignored for the
    -- wire length calculation
    local device_groups = {}
    for index, group in ipairs(groups) do
        device_groups[index] = { devices = {} }
    end
    for _, device in ipairs(devices) do
        local groupindex = _get_group_index(groups, device)
        if not groupindex then -- create new group
            table.insert(device_groups, { devices = {} })
            groupindex = #device_groups
        end
        local group = device_groups[groupindex]
        table.insert(group.devices, device)
    end

    -- add group names
    for groupindex, group in ipairs(device_groups) do
        group.name = string.format("group_%d", groupindex)
    end

    local device_places = {}
    -- in-group placement
    for _, group in ipairs(device_groups) do
        -- collect in-group wires
        local wires = {}
        for _, device in ipairs(group.devices) do
            for _, net in pairs(device.connections) do
                local is_ignored = util.any_of(net, ignored_nets or {})
                if not is_ignored then
                    local wire = _get_wire_by_name(wires, net)
                    if not wire then
                        wire = {
                            net = net,
                            targets = {},
                        }
                        table.insert(wires, wire)
                    end
                    if not util.any_of(device, wire.targets) then
                        table.insert(wire.targets, device)
                    end
                end
            end
        end
        -- perform in-group placement
        local places = _run_placement(group.devices, wires, weights)
        for _, place in ipairs(places) do
            device_places[place.object.name] = {
                x = place.x,
                y = place.y,
            }
        end
    end

    -- collect global wires
    local wires = {}
    for _, group in ipairs(device_groups) do
        for _, device in ipairs(group.devices) do
            for _, net in pairs(device.connections) do
                local is_local = _is_local_net(net, device_groups)
                local is_ignored = util.any_of(net, ignored_nets or {})
                if not is_ignored and not is_local then
                    local wire = _get_wire_by_name(wires, net)
                    if not wire then
                        wire = {
                            net = net,
                            targets = {},
                        }
                        table.insert(wires, wire)
                    end
                    if not util.any_of(group, wire.targets) then
                        table.insert(wire.targets, group)
                    end
                end
            end
        end
    end

    -- perform global placement
    local group_places = _run_placement(device_groups, wires, weights)

    return {
        devices = device_places,
        groups = group_places,
    }
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

function placement.hbox(...)
    local num = select("#", ...)
    local args = { ... }
    local box = {
        type = "horizontal",
        content = {}
    }
    for i = 1, num do
        box.content[i] = args[i]
    end
    return box
end

function placement.vbox(...)
    local num = select("#", ...)
    local args = { ... }
    local box = {
        type = "vertical",
        content = {}
    }
    for i = 1, num do
        box.content[i] = args[i]
    end
    return box
end

local _has_children = function(t)
    for _, e in ipairs(t.content) do
        if type(e) == "table" then
            return true
        end
    end
    return false
end

local _find_initial_group
_find_initial_group = function(t)
    if not _has_children(t) then
        return t
    else
        for _, e in ipairs(t.content) do
            if type(e) == "table" then
                return _find_initial_group(e)
            end
        end
    end
end

--[[

hbox(vbox("M1", "M2"), "M3")
-> order and grouping: (M1 M2) (M3)
-> there is one degree of freedom here, the placement can also start with M2

hbox(vbox("M1", "M2"), vbox("M3", "M4", hbox("M5", "M6")))
-> order and grouping: (M1 M2) (M3 M4 (M5 M6))

--]]

function placement.transform_plan(plan)
    local instructions = {}
    --[[
    local initial = _find_initial_group(plan)
    table.insert(instructions, {
        what = "initial",
        object = initial.content[1],
    })
    _collect_placements(plan, instructions)
    local ref = initial
    for _, element in ipairs(plan.content) do
        if element ~= initial then
            table.insert(instructions, {
                what = "abut",
                where = plan.type == "vertical" and "top" or "right",
                object = element,
                reference = ref,
            })
        end
    end
    --]]
    table.insert(instructions, {
        what = "abut",
        where = plan.type == "vertical" and "top" or "right",
        object = element,
        reference = ref,
    })
    return instructions
end

--[[
function placement.custom(parent, plan)
    local explosionvalue = 500
    for _, box in ipairs(plan) do
        if box.type == "vertical" then
            local lastboxcell
            for _, cell in ipairs(box.content) do
                if lastboxcell then
                    cell:align_center_x(lastboxcell)
                    cell:abut_top(lastboxcell)
                    cell:translate_y(explosionvalue)
                end
                parent:merge_into(cell)
                lastboxcell = cell
            end
        elseif box.type == "horizontal" then
            local lastboxcell
            for _, cell in ipairs(box.content) do
                if lastboxcell then
                    cell:align_center_y(lastboxcell)
                    cell:abut_right(lastboxcell)
                    cell:translate_x(explosionvalue)
                end
                parent:merge_into(cell)
                lastboxcell = cell
            end
        else
            error(string.format("placement.custom: unknown box type '%s'", box.type))
        end
    end
end
--]]

function placement.custom(parent, plan)
    local explosionvalue = 100
    local currentgroup
    local isgroup = false
    local lastcell
    for _, instruction in ipairs(plan) do
        if instruction.placement == "initial" then
            -- do nothing, actions are done by common code
        elseif instruction.placement == "above" then
            local target = isgroup and lastcell or currentgroup
            instruction.cell:align_center_x(target)
            instruction.cell:abut_top(target)
            instruction.cell:translate_y(explosionvalue)
        elseif instruction.placement == "right" then
            local target = isgroup and lastcell or currentgroup
            instruction.cell:align_center_y(target)
            instruction.cell:abut_right(target)
            instruction.cell:translate_x(explosionvalue)
        else
            error(string.format("placement.custom: unrecognized placemement instruction '%s'", instruction.placement))
        end
        lastcell = instruction.cell
        parent:merge_into(instruction.cell)
        if not isgroup then
            currentgroup = alignmentgroup.create()
            isgroup = true
        end
        if isgroup then
            currentgroup:add(instruction.cell)
        end
        if instruction.groupbarrier then
            isgroup = false
        end
    end
end
