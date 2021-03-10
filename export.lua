local M = {}

local export

local function _collect_shapes(cell, get_layer_func, get_index_func, point_func, precomputed)
    local shapes = {}
    if get_index_func then
        shapes.indexed = true
        shapes.maxindex = 0
    end
    get_layer_func = get_layer_func or function(s) return s.lpp end
    point_func = point_func or function(s) return s.points end
    for _, shape in cell:iter() do
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
    local filename = string.format("%s/export/%s/init.lua", _get_opc_home(), name)
    local chunkname = "@export"

    local reader = _get_reader(filename)
    if not reader then
        error(string.format("export '%s' not found", name))
    end
    export = _generic_load(reader, chunkname)
end

function M.get_techexport()
    if export.techexport then
        return export.techexport()
    end
end

function M.write_cell(filename, cell, fake)
    if cell:is_empty() then
        error("export: cell is empty")
    end
    local extension = export.get_extension()
    local file = stringfile.open(string.format("%s.%s", filename, extension))
    local precomputed = aux.call_if_present(export.precompute, cell)
    aux.call_if_present(export.at_begin, file, precomputed)
    aux.call_if_present(export.at_begin_cell, file, precomputed)
    for layer, pcol in _iter_shapes(_collect_shapes(cell, export.get_layer, export.get_index, export.get_points, precomputed)) do
        export.write_layer(file, layer, pcol)
    end
    if export.write_port then
        for name, port in pairs(cell.ports) do
            --export.write_port(file, name, port.layer, port.where)
            -- FIXME: only for testing purposes
            export.write_port(file, name, "M1", port.where)
        end
    end
    aux.call_if_present(export.at_end_cell, file, precomputed)
    aux.call_if_present(export.at_end, file, precomputed)
    if not fake then
        file:truewrite()
    end
end

function M.set_options(opt)
    aux.call_if_present(export.set_options, opt)
end

return M
