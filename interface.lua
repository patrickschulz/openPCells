local M = {}

local interface

local function _collect_shapes(cell, get_layer_func, get_index_func, point_func, precomputed)
    local shapes = {}
    if get_index_func then
        shapes.indexed = true
        shapes.maxindex = 0
    end
    for shape in cell:iter() do
        local layer = get_layer_func(shape, precomputed)
        if shapes.indexed then
            local index = get_index_func(shape, precomputed)
            if not shapes[index] then
                shapes[index] = { layer = layer, points = {} }
                shapes.maxindex = math.max(shapes.maxindex, index)
            end
            table.insert(shapes[index].points, point_func(shape, precomputed))
        else
            if not shapes[layer] then
                shapes[layer] = {}
            end
            table.insert(shapes[layer], point_func(shape, precomputed))
        end
    end
    return shapes
end

local function _iter_shapes(shapes)
    if shapes.indexed then
        local idx = 1
        local iter = function()
            while true do
                idx = idx + 1
                if idx > shapes.maxindex + 1 then
                    return nil
                end
                if shapes[idx - 1] then break end
            end
            return shapes[idx - 1].layer, shapes[idx - 1].points
        end
        return iter
    else
        return pairs(shapes)
    end
end

function M.load(name)
    interface = dofile(string.format("%s/interface/%s/init.lua", _get_opc_home(), name))
end

function M.write_cell(filename, cell)
    local extension = interface.get_extension()
    local file = stringfile.open(string.format("%s.%s", filename, extension))
    local precomputed = aux.call_if_present(interface.precompute, cell)
    aux.call_if_present(interface.at_begin, file, precomputed)
    aux.call_if_present(interface.at_begin_cell, file, precomputed)
    for layer, pcol in _iter_shapes(_collect_shapes(cell, interface.get_layer, interface.get_index, interface.get_points, precomputed)) do
        interface.write_layer(file, layer, pcol)
    end
    aux.call_if_present(interface.at_end_cell, file, precomputed)
    aux.call_if_present(interface.at_end, file, precomputed)
    file:truewrite()
end

function M.set_options(opt)
    aux.call_if_present(interface.set_options, opt)
end

return M
