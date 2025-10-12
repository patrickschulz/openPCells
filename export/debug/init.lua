local M = {}

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

function M.get_techexport()
    return "debug"
end

function M.get_extension()
    return "debug"
end

function M.write_rectangle(layer, bl, tr)
    table.insert(__content, string.format("rect (%s): (%d, %d) (%d, %d)", layer.layer, bl.x, bl.y, tr.x, tr.y))
end

function M.write_polygon(layer, pts)
    local t = {}
    for _, pt in ipairs(pts) do
        table.insert(t, string.format("(%d, %d)", pt.x, pt.y))
    end
    table.insert(__content, string.format("poly (%s): %s", layer.layer, table.concat(t, " ")))
end

function M.write_cell_reference(identifier, instname, origin)
    table.insert(__content, string.format("cell reference  (%s): (%d, %d)", identifier, origin.x, origin.y))
end

function M.write_port(name, layer, where, sizehint)
    table.insert(__content, string.format("port (%s): %s at (%d, %d)", layer.layer, name, where.x, where.y))
end

function M.at_begin_cell(cellname)
    table.insert(__content, string.format("cell definition begin (%s)", cellname))
end

function M.at_end_cell()
    table.insert(__content, "cell definition end")
end

return M
