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
    if export.techexport then
        return export.techexport()
    end
end

local function _write_cell(file, cell, name)
    aux.call_if_present(export.at_begin_cell, file, name)
    local x0, y0 = cell.x0, cell.y0
    for _, S in cell:iterate_shapes() do
        local layer = export.get_layer(S)
        if S:is_type("polygon") then
            export.write_polygon(file, layer, x0, y0, S.points)
        else
            export.write_rectangle(file, layer, x0, y0, S.points.bl, S.points.tr)
        end
    end
    for _, child in cell:iterate_children_links() do
        export.write_cell_reference(file, child.identifier, child.origin)
    end
    aux.call_if_present(export.at_end_cell, file)
end

function M.write_toplevel(filename, cell, fake)
    if cell:is_empty() then
        error("export: cell is empty")
    end
    --if not export.write_cell then
    --    cell:flatten()
    --end
    local extension = export.get_extension()
    local file = stringfile.open(string.format("%s.%s", filename, extension))
    aux.call_if_present(export.at_begin, file)

    for name, child in cell:iterate_children() do
        _write_cell(file, child, name)
    end
    _write_cell(file, cell, "opctoplevel")

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
