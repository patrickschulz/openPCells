local M = {}

function M.get_techexport()
    return "raw"
end

function M.get_extension()
    return "debug"
end

function M.get_layer(S)
    return S:get_lpp():str()
end

function M.write_rectangle(file, layer, x0, y0, bl, tr)
    local xbot, ybot = bl:unwrap()
    local xtop, ytop = tr:unwrap()
    file:write(string.format("rect (%s): (%d, %d) (%d, %d) \n", layer, xbot + x0, ybot + y0, xtop + x0, ytop + y0))
end

function M.write_polygon(file, layer, x0, y0, pts)
    local t = {}
    for _, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        table.insert(t, string.format("(%d, %d)", x + x0, y + y0))
    end
    file:write(string.format("poly (%s): %s\n", layer, table.concat(t, " ")))
end

function M.write_cell_reference(file, identifier, x, y)
    file:write(string.format("ref  (%s): (%d, %d)\n", identifier, x, y))
end

function M.at_begin_cell(file, cellname)
    file:write(string.format("cell (%s) >\n", cellname))
end

function M.at_end_cell(file)
    file:write("<\n\n")
end

return M
