local M = {}

local function _write_module(rows, routes)
    local lines = {}
    table.insert(lines, 'function parameters()')
    table.insert(lines, '    pcell.reference_cell("stdcells/base")')
    table.insert(lines, 'end')
    table.insert(lines, 'function layout(toplevel)')

    -- placement
    if rows then
        table.insert(lines, '    local cellnames = {')
        for _, row in ipairs(rows) do
            table.insert(lines, '        {')
            for _, column in ipairs(row) do
                table.insert(lines, string.format('            { instance = "%s", reference = "%s" },', 
                    column.instance, 
                    column.reference
                ))
            end
            table.insert(lines, '        },')
        end
        table.insert(lines, '    }')
        table.insert(lines, '    local rows = placement.create_reference_rows(cellnames)')
        table.insert(lines, string.format('    local cells = placement.rowwise(toplevel, rows)'))
    else
        print("no placement information found")
    end

    -- routes
    if routes then
        table.insert(lines, '    local routes = {')
        for _, route in ipairs(routes) do
            table.insert(lines, '        {')
            for _, moves in ipairs(route) do
                local entry = {}
                for k, v in pairs(moves) do
                    table.insert(entry, string.format("%s = %q", k, v))
                end
                table.insert(lines, string.format('            { %s },', table.concat(entry, ", ")))
            end
            table.insert(lines, '        },')
        end
        table.insert(lines, '    }')
        table.insert(lines, '    local bp = pcell.get_parameters("stdcells/base")')
        table.insert(lines, '    local width = bp.gstwidth')
        table.insert(lines, '    local xgrid = bp.gspace + bp.glength')
        table.insert(lines, '    local ygrid = bp.gstwidth + bp.gstspace')
        --table.insert(lines, '    local ygrid = bp.pwidth + bp.nwidth + bp.powerwidth + 2 * bp.powerspace + bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace')
        table.insert(lines, string.format('    routing.route(toplevel, routes, cells, width, xgrid, ygrid)'))
    else
        print("no routing information found")
    end

    table.insert(lines, "end") -- close 'layout' function
    return lines
end

function M.get_cell_filename(prefix, libname, cellname)
    if not prefix then
        moderror("generator.get_cell_filename: not path prefix specified")
    end
    if not libname then
        moderror("generator.get_cell_filename: not library name specified")
    end
    if not cellname then
        moderror("generator.get_cell_filename: not cell name specified")
    end
    local basename = string.format("%s/%s", prefix, libname)
    if not filesystem.exists(basename) then
        local created = filesystem.mkdir(basename)
        if not created then
            moderror(string.format("generator.get_cell_filename: could not create directory '%s/%s'", prefix, libname))
        end
    end
    return string.format("%s/%s.lua", basename, cellname)
end

function M.digital(file, rows, routes)
    local lines = _write_module(rows, routes)
    file:write(table.concat(lines, '\n'))
end

return M
