local M = {}

local interface

function _collect_shapes(cell, get_layer_func)
    local shapes = {}
    for shape in cell:iter() do
        local layer = get_layer_func(shape)
        if not shapes[layer] then
            shapes[layer] = {}
        end
        table.insert(shapes[layer], shape.points)
    end
    return shapes
end

function M.load(name)
    interface = dofile(string.format("%s/interface/%s/init.lua", _get_opc_home(), name))
end

local function _call_if_present(func, ...)
    if func then
        func(...)
    end
end

function M.write_cell(filename, cell)
    local extension = interface.get_extension()
    local file = io.open(string.format("%s.%s", filename, extension), "w")
    _call_if_present(interface.at_begin, file)
    interface.print_object(file, cell)
    _call_if_present(interface.at_end, file)
    file:close()
end

return M
