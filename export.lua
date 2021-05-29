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

local function _write_cell(file, cell, name)
    aux.call_if_present(export.at_begin_cell, file, name)
    for _, S in cell:iterate_shapes() do
        S:apply_transformation(cell.trans)
        local layer = export.get_layer(S)
        if S:is_type("polygon") then
            export.write_polygon(file, layer, 0, 0, S.points)
        else
            export.write_rectangle(file, layer, 0, 0, S.points.bl, S.points.tr)
        end
    end
    for _, child in cell:iterate_children_links() do
        local other = cell.children.lookup[child.identifier]
        local shiftx, shifty = other:get_transformation_correction()
        export.write_cell_reference(file, child.identifier, child.x0 + cell.x0, child.y0 + cell.y0, child.orientation, shiftx, shifty)
    end
    aux.call_if_present(export.at_end_cell, file)
end

local function _write_children(file, cell)
    for name, child in cell:iterate_children() do
        _write_children(file, child)
        _write_cell(file, child, name)
    end
end

function M.write_toplevel(filename, toplevel, fake)
    if toplevel:is_empty() then
        error("export: toplevel is empty")
    end
    if not export.write_cell_reference then
        modinfo("this export does not know how to write hierarchies, hence the cell is being written flat")
        toplevel:flatten()
    end
    local extension = export.get_extension()
    local file = stringfile.open(string.format("%s.%s", filename, extension))
    aux.call_if_present(export.at_begin, file)

    _write_children(file, toplevel)
    _write_cell(file, toplevel, "opctoplevel")

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
