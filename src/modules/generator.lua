local M = {}

local function _write_module(rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    local lines = {}
    table.insert(lines, 'function layout(toplevel)')
    table.insert(lines, '    pcell.push_overwrites("stdcells/base", {')
    table.insert(lines, string.format('        pnumtracks = %i,', pnumtracks))
    table.insert(lines, string.format('        nnumtracks = %i,', nnumtracks))
    table.insert(lines, string.format('        numinnerroutes= %i,', numinnerroutes))
    table.insert(lines, string.format('        drawtopbotwelltaps = %s,', 'false'))
    table.insert(lines, '    })')

    table.insert(lines, '    local bp = pcell.get_parameters("stdcells/base")')
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
        table.insert(lines, '    local xpitch = bp.gspace + bp.glength')
        table.insert(lines, '    local rows = placement.create_reference_rows(cellnames, xpitch)')
        table.insert(lines, string.format('    local cells = placement.rowwise(toplevel, rows)'))
    else
        print("no placement information found")
    end

    -- routes
    if routes then
        table.insert(lines, '    local routes = {')
        for _, route in ipairs(routes) do
            table.insert(lines, '        {')
            table.insert(lines, string.format('            name = "%s",', route.name))
            for _, moves in ipairs(route) do
                local entry = {}
                for k, v in pairs(moves) do
                    if k == "where" or k == "nodraw" then
                        table.insert(entry, string.format("%s = %s", k, v))
                    else
                        table.insert(entry, string.format("%s = %q", k, v))
                    end

                end
                table.insert(lines, string.format('            { %s },', table.concat(entry, ", ")))
            end
            table.insert(lines, '        },')
        end
        table.insert(lines, '    }')
        table.insert(lines, '    local width = bp.routingwidth')
        table.insert(lines, '    local xgrid = bp.gspace + bp.glength')
        table.insert(lines, '    local ygrid = bp.routingwidth + bp.routingspace')
        table.insert(lines, '    local pnumtracks = bp.pnumtracks')
        table.insert(lines, '    local nnumtracks = bp.nnumtracks')
        table.insert(lines, '    local numinnerroutes = bp.numinnerroutes')
        table.insert(lines, string.format('    routing.route(toplevel, routes, width, numinnerroutes, pnumtracks, nnumtracks, xgrid, ygrid)'))
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

function M.digital(file, rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    local lines = _write_module(rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    file:write(table.concat(lines, '\n'))
end

return M
