local M = {}

local function _write_module(rows, routes, numinnerroutes, pnumtracks, nnumtracks)
    local lines = {}
    table.insert(lines, 'function layout(toplevel)')
    --[[
    table.insert(lines, '    pcell.push_overwrites("stdcells/base", {')
    table.insert(lines, string.format('        pnumtracks = %i,', pnumtracks))
    table.insert(lines, string.format('        nnumtracks = %i,', nnumtracks))
    table.insert(lines, string.format('        numinnerroutes= %i,', numinnerroutes))
    table.insert(lines, string.format('        drawtopbotwelltaps = %s,', 'false'))
    table.insert(lines, '    })')
    --]]

    -- placement
    if rows then
        table.insert(lines, '    local cellnames = {')
        for _, row in ipairs(rows) do
            table.insert(lines, '        {')
            for _, column in ipairs(row) do
                table.insert(lines, string.format('            { instance = "%s", reference = "stdcells/%s" },',
                column.instance,
                column.reference
                ))
            end
            table.insert(lines, '        },')
        end
        table.insert(lines, '    }')
        -- FIXME: remove hard-coded values (values are for opc tech)
        table.insert(lines, '    local baseopt = {')
        table.insert(lines, '        sdwidth = 200,')
        table.insert(lines, '        gatelength = 500,')
        table.insert(lines, '        gatespace = 320,')
        table.insert(lines, '        routingwidth = 200,')
        table.insert(lines, '        routingspace = 200,')
        table.insert(lines, '        pnumtracks = 3,')
        table.insert(lines, '        nnumtracks = 3,')
        table.insert(lines, '        numinnerroutes = 3,')
        table.insert(lines, '    }')
        table.insert(lines, '    local xpitch = 820')
        table.insert(lines, '    local rows = placement.create_reference_rows(cellnames, xpitch, baseopt)')
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
        table.insert(lines, '    local width = 200 -- routingwidth')
        table.insert(lines, '    local xgrid = 500 + 320 -- gatelength + gatespace')
        table.insert(lines, '    local ygrid = 200 + 200 -- routingwidth + routingspace')
        table.insert(lines, '    local pnumtracks = 3')
        table.insert(lines, '    local nnumtracks = 3')
        table.insert(lines, '    local numinnerroutes = 3')
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

local function _section(lines, what)
    table.insert(lines, string.format("-- %s", what))
end

local function _newline(lines)
    table.insert(lines, "")
end

function M.analog(file, settings, devices, places, routes)
    local lines = {}
    local level = 0
    local function _insert(fmt, ...)
        table.insert(lines, string.rep(" ", 4 * level) .. string.format(fmt, ...))
    end
    local function _increase()
        level = level + 1
    end
    local function _decrease()
        level = level - 1
    end
    -- top-level cell
    table.insert(lines, "local toplevel = object.create(\"toplevel\")")
    _newline(lines)
    -- important value settings
    _insert("local interconnectlinewidth = %d", (settings and settings.interconnectlinewidth) or 100)
    _insert("local interconnectlinespace = %d", (settings and settings.interconnectlinespace) or 100)
    _newline(lines)
    -- begin of device bases
    _insert("local devicebases = {")
    _increase()
    for _, device in ipairs(devices) do
        -- start of device
        _insert("-- * %s *", device.name)
        _insert("[\"%sbase\"] = {", device.name)
        _increase()
        -- parameters
        for k, v in pairs(device.parameters) do
            if type(v) == "number" then
                _insert("%s = %d,", k, math.floor(v + 0.5))
            else
                _insert("%s = %q,", k, v)
            end
        end
        _decrease()
        _insert("},")
        -- end of device
    end
    _decrease()
    _insert("}")
    -- end of device bases
    _newline(lines)
    -- begin of devices
    _insert("local devices = {")
    _increase()
    for _, device in ipairs(devices) do
        -- start of device
        _insert("-- * %s *", device.name)
        _insert("{")
        _increase()
        -- name
        _insert("name = \"%s\",", device.name)
        -- base
        _insert("base = \"%sbase\",", device.name)
        -- placement
        _insert("x = %d,", places.devices[device.name].x)
        _insert("y = %d,", places.devices[device.name].y)
        -- nets
        _insert("nets = {")
        _increase()
        for k, v in pairs(device.connections) do
            _insert("%s = \"%s\",", k, v)
        end
        _decrease()
        _insert("},")
        -- end of nets
        _decrease()
        _insert("},")
        -- end of device
    end
    _decrease()
    _insert("}")
    -- end of devices
    _newline(lines)
    -- begin of device groups
    _insert("local devicegroups = {")
    _increase()
    for i, place in ipairs(places.groups) do
        -- start of group
        _insert("-- * group %d *", i)
        _insert("{")
        _increase()
        -- name
        _insert("name = \"group_%d\",", i)
        -- devices
        local devicetable = util.select_key(place.object.devices, "name")
        _insert("devices = { %s },", util.tconcatfmt(devicetable, ", ", "\"%s\""))
        -- well type (FIXME)
        _insert("welltype = \"%s\",", "n")
        -- grid position
        _insert("x = %d,", place.x)
        _insert("y = %d,", place.y)
        -- grid position
        --_insert("x = %d,", places[device.name].x)
        --_insert("y = %d,", places[device.name].y)
        _decrease()
        _insert("},")
        -- end of group
    end
    _decrease()
    _insert("}")
    -- end of device groups
    --[[
    _insert("intergridlines = {")
    _increase()
    for _, route in ipairs(routes.vertical) do
        _insert("{")
        _increase()
        _insert("net = \"%s\",", route.net)
        _insert("xgrid = %d,", route.xgrid)
        _insert("xline = %d,", route.xline)
        _insert("ygridstart = %d,", route.ygridstart)
        _insert("ygridend = %d,", route.ygridend)
        _insert("ylinestart = %d,", route.ylinestart)
        _insert("ylineend = %d,", route.ylineend)
        _decrease()
        _insert("},")
    end
    _decrease()
    _insert("},")
    -- end of intergridlines
    _insert("gridlines = {")
    _increase()
    for _, route in ipairs(routes.horizontal) do
        _insert("{")
        _increase()
        _insert("net = \"%s\",", route.net)
        _insert("xgridstart = %d,", route.xgridstart)
        _insert("xgridend = %d,", route.xgridend)
        _insert("xlinestart = %d,", route.xlinestart)
        _insert("xlineend = %d,", route.xlineend)
        _insert("ygrid = %d,", route.ygrid)
        _insert("yline = %d,", route.yline)
        _decrease()
        _insert("},")
    end
    _decrease()
    _insert("},")
    -- end of gridlines
    _insert("netlabel_size = 50,")
    _decrease()
    _insert("})")
    -- end of analog/circuit
    -- merge circuit into toplevel
    --]]
    -- device creation
    _newline(lines)
    _insert("local circuit = pcell.create_layout(\"analog/circuit\", \"circuit\", {")
    _increase()
    _insert("allow_failed_grid_connections = true,")
    _insert("check_grid_connections = false,")
    _insert("devicebases = devicebases,")
    _insert("devices = devices,")
    _insert("devicegroups = devicegroups,")
    _insert("interconnectlinewidth = interconnectlinewidth,")
    _insert("interconnectlinespace = interconnectlinespace,")
    _insert("vlines = vlines,")
    _insert("hlines = hlines,")
    _decrease()
    _insert("})")
    _newline(lines)
    _insert("toplevel:merge_into(circuit)")
    _newline(lines)
    _insert("return toplevel")
    file:write(table.concat(lines, '\n'))
end

return M
