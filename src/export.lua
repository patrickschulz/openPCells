local M = {}

local export
local _name
local _leftdelim, _rightdelim = "", ""

local exportpaths = {}

function M.add_path(path)
    table.insert(exportpaths, path)
end

local function _get_export_filename(name)
    for _, path in ipairs(exportpaths) do
        local filename = string.format("%s/%s/init.lua", path, name)
        if dir.exists(filename) then
            -- first found matching cell is used
            return filename
        end
    end
end

function M.set_bus_delimiters(leftdelim, rightdelim)
    _leftdelim = leftdelim
    _rightdelim = rightdelim
end

function M.load(name)
    local filename = _get_export_filename(name)
    if not filename then
        moderror(string.format("export '%s' not found", name))
    end
    local chunkname = string.format("@export/%s", name)
    local reader = _get_reader(filename)
    if not reader then
        moderror(string.format("export '%s' not found", name))
    end
    export = _generic_load(reader, chunkname)
    _name = name
end

function M.get_techexport()
    if export.get_techexport then
        return export.get_techexport()
    end
end

local function _check_function(func)
    if not export[func] then
        moderror(string.format("export '%s' does not define '%s'", _name, func))
    end
    if not type(export[func]) == "function" then
        moderror(string.format("export '%s': field '%s' is not a function (table/userdata with __call meta field are not supported)", _name, func))
    end
end

function M.check()
    _check_function("get_extension")
    _check_function("write_rectangle")
    _check_function("write_polygon")
    _check_function("finalize")
end

local function _write_cell(cell)
    -- shapes
    for _, S in cell:iterate_shapes() do
        if S:is_type("path") and not export.write_path then
            S:resolve_path()
        end
        S:apply_transformation(cell.trans, cell.trans.apply_transformation)
        local layer = S:get_layer()
        if S:is_type("polygon") then
            export.write_polygon(layer, S:get_points())
        elseif S:is_type("rectangle") then
            export.write_rectangle(layer, S:get_points().bl, S:get_points().tr)
        elseif S:is_type("path") then
            export.write_path(layer, S:get_points(), S:get_path_width(), S:get_path_extension())
        else
            moderror(string.format("export: unknown shape type '%s'", S.typ))
        end
    end
    -- children links
    for _, child in cell:iterate_children() do
        local origin = child.origin
        child.trans:apply_transformation(origin)
        cell.trans:apply_transformation(origin)
        local x, y = origin:unwrap()
        local orientation = child.trans:orientation_string()
        if child.isarray and export.write_cell_array then
            export.write_cell_array(child.identifier, x, y, orientation, child.xrep, child.yrep, child.xpitch, child.ypitch)
        else
            for ix = 1, child.xrep or 1 do
                for iy = 1, child.yrep or 1 do
                    export.write_cell_reference(child.identifier, x + (ix - 1) * (child.xpitch or 0), y + (iy - 1) * (child.ypitch or 0), orientation)
                end
            end
        end
    end
end

local function _write_ports(cell)
    for _, port in pairs(cell.ports) do
        if port.isbusport then
            local name = string.format("%s%s%d%s",  port.name, _leftdelim, port.busindex, _rightdelim)
            cell.trans:apply_transformation(port.where)
            export.write_port(name, port.layer:get(), port.where)
        else
            cell.trans:apply_transformation(port.where)
            export.write_port(port.name, port:get_layer(), port.where)
        end
    end
end

local cellrefs = {}
local function _write_cell_references(cell, writechildrenports)
    for _, child in cell:iterate_children() do
        if not cellrefs[child.identifier] then
            local cellref = pcell.get_cell_reference(child.identifier)
            aux.call_if_present(export.at_begin_cell, child.identifier)
            _write_cell(cellref)
            if writechildrenports then
                if export.write_port then
                    _write_ports(cellref)
                end
            end
            aux.call_if_present(export.at_end_cell)
            cellrefs[child.identifier] = true
            _write_cell_references(cellref, writechildrenports)
        end
    end
end

function M.write_toplevel(filename, technology, toplevel, toplevelname, writechildrenports, fake)
    if toplevel:is_empty() then
        moderror("export: toplevel is empty")
    end
    if not export.write_cell_reference then
        modinfo("this export does not know how to write hierarchies, hence the cell is being written flat")
        toplevel:flatten()
    end

    if export.initialize then
        export.initialize(toplevel)
    end

    local extension = export.get_extension()
    aux.call_if_present(export.at_begin, technology)

    _write_cell_references(toplevel, writechildrenports)

    aux.call_if_present(export.at_begin_cell, toplevelname)
    _write_cell(toplevel)
    if export.write_port then
        _write_ports(toplevel)
    end
    aux.call_if_present(export.at_end_cell)

    aux.call_if_present(export.at_end)

    local content = export.finalize()
    if not fake then
        local file = io.open(string.format("%s.%s", filename, extension), "w")
        if not file then
            moderror("could not create file")
        end
        file:write(content)
    end
end

function M.set_options(opt)
    if opt and export.set_options then
        local argparse = cmdparser()
        argparse:load_options_from_file(string.format("%s/export/%s/cmdoptions.lua", _get_opc_home(), _name))
        local arg = {}
        for a in string.gmatch(opt, "(%S+)") do
            table.insert(arg, a)
        end
        local args, msg = argparse:parse(arg)
        if not args then
            errprint(msg)
            return 1
        end
        export.set_options(args)
    end
end

return M
