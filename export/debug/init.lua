local M = {}

local __content = {}

function M.finalize()
    return table.concat(__content, "\n")
end

function M.get_techexport()
    return "raw"
end

function M.get_extension()
    return "debug"
end

function M.get_layer(S)
    return S:get_lpp():str()
end

function M.write_rectangle(layer, bl, tr)
    local xbot, ybot = bl:unwrap()
    local xtop, ytop = tr:unwrap()
    table.insert(__content, string.format("rect (%s): (%d, %d) (%d, %d)", layer, xbot, ybot, xtop, ytop))
end

function M.write_polygon(layer, pts)
    local t = {}
    for _, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        table.insert(t, string.format("(%d, %d)", x, y))
    end
    table.insert(__content, string.format("poly (%s): %s", layer, table.concat(t, " ")))
end

function M.write_cell_reference(identifier, instname, x, y)
    table.insert(__content, string.format("ref  (%s): (%d, %d)", identifier, x, y))
end

function M.at_begin_cell(cellname)
    table.insert(__content, string.format("cell (%s) >", cellname))
end

function M.at_end_cell()
    table.insert(__content, "<\n")
end

return M
