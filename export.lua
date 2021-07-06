local M = {}

local export
local _name

function M.load(name)
    local filename = string.format("%s/export/%s/init.lua", _get_opc_home(), name)
    local chunkname = string.format("@export/%s", name)
    local reader = _get_reader(filename)
    if not reader then
        error(string.format("export '%s' not found", name))
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
        error(string.format("export '%s' does not define '%s'", _name, func))
    end
    if not type(export[func]) == "function" then
        error(string.format("export '%s': field '%s' is not a function (table/userdata with __call meta field are not supported)", _name, func))
    end
end

function M.check()
    _check_function("get_extension")
    _check_function("get_layer")
    _check_function("write_rectangle")
    _check_function("write_polygon")
end

local function _write_cell(file, cell)
    -- shapes
    for _, S in cell:iterate_shapes() do
        if S:is_type("path") and not export.write_path then
            S:resolve_path()
        end
        S:apply_transformation(cell.trans, cell.trans.apply_transformation)
        local layer = export.get_layer(S)
        if S:is_type("polygon") then
            export.write_polygon(file, layer, S.points)
        elseif S:is_type("rectangle") then
            export.write_rectangle(file, layer, S.points.bl, S.points.tr)
        elseif S:is_type("path") then
            export.write_path(file, layer, S.points, S.width)
        else
            moderror(string.format("export: unknown shape type '%s'", S.typ))
        end
    end
    -- children links
    for _, child in cell:iterate_children() do
        if child.isarray and export.write_cell_array then
            local origin = child.origin
            child.trans:apply_transformation(origin)
            cell.trans:apply_transformation(origin)
            local x, y = origin:unwrap()
            local orientation = child.trans:orientation_string()
            export.write_cell_array(file, child.identifier, x, y, orientation, child.xrep, child.yrep, child.xpitch, child.ypitch)
        else
            for ix = 1, child.xrep or 1 do
                for iy = 1, child.yrep or 1 do
                    local origin = child.origin
                    child.trans:apply_transformation(origin)
                    cell.trans:apply_transformation(origin)
                    local x, y = origin:unwrap()
                    local orientation = child.trans:orientation_string()
                    export.write_cell_reference(file, child.identifier, x + (ix - 1) * (child.xpitch or 0), y + (iy - 1) * (child.ypitch or 0), orientation)
                end
            end
        end
    end
end

local cellrefs = {}
local function _write_children(file, cell)
    for _, child in cell:iterate_children() do
        if not cellrefs[child.identifier] then
            local cellref = pcell.get_cell_reference(child.identifier)
            print(child.identifier, cellref)
            aux.call_if_present(export.at_begin_cell, file, child.identifier)
            _write_cell(file, cellref, child.identifier)
            aux.call_if_present(export.at_end_cell, file)
            cellrefs[child.identifier] = true
        end
    end
end

function M.write_toplevel(filename, technology, toplevel, fake)
    if toplevel:is_empty() then
        error("export: toplevel is empty")
    end
    if not export.write_cell_reference then
        modinfo("this export does not know how to write hierarchies, hence the cell is being written flat")
        toplevel:flatten()
    end
    local extension = export.get_extension()
    local file = stringfile.open(string.format("%s.%s", filename, extension))
    aux.call_if_present(export.at_begin, file, technology)

    _write_children(file, toplevel)

    aux.call_if_present(export.at_begin_cell, file, "opctoplevel")
    _write_cell(file, toplevel, "opctoplevel")
    if export.write_port then
        for portname, port in pairs(toplevel.ports) do
            toplevel.trans:apply_transformation(port.where)
            export.write_port(file, portname, port.layer:get(), port.where)
        end
    end
    aux.call_if_present(export.at_end_cell, file)

    aux.call_if_present(export.at_end, file)
    if not fake then
        file:truewrite()
    end
end

function M.set_options(opt)
    if opt and export.set_options then
        local argparse = cmdparser()
        argparse:load_options_from_file(string.format("export/%s/cmdoptions", _name))
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
