local M = {}

function M.get_extension()
    return "mag"
end

local function _get_layer(shape)
    return shape.lpp:get().magic.layer
end

local function _write_layer(file, layer, pcol)
    file:write(string.format("<< %s >>\n", layer))
    for _, pts in ipairs(pcol) do
        local grid = 1000
        local xbot, ybot = pts.bl:unwrap(grid)
        local xtop, ytop = pts.tr:unwrap(grid)
        file:write(string.format("rect %d %d %d %d\n", math.floor(xbot), math.floor(ybot), math.floor(xtop), math.floor(ytop)))
    end
end

function M.print_object(file, cell)
    file:write(string.format("%s\n", "magic"))
    file:write(string.format("tech %s\n", "sky130A")) -- FIXME: make flexible
    file:write(string.format("timestamp %s\n", os.time()))
    for layer, pcol in pairs(_collect_shapes(cell, _get_layer)) do
        _write_layer(file, layer, pcol)
    end
    file:write(string.format("%s\n", "<< end >>"))
end

return M
