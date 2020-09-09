local M = {}

function M.get_extension()
    return "debug"
end

function M.get_points(shape)
    if shape.typ == "rectangle" then
        local xbot, ybot = shape.points.bl:unwrap()
        local xtop, ytop = shape.points.tr:unwrap()
        return string.format("(%8.3f %8.3f) (%8.3f %8.3f)", xbot, ybot, xtop, ytop)
    else
        local t = {}
        for _, pt in ipairs(shape.points) do
            table.insert(t, string.format("(%8.3f, %8.3f)", pt:unwrap()))
        end
        return table.concat(t, " \n")
    end
end

function M.write_layer(file, layer, pcol)
    file:write(string.format("%s\n", ">>>>> Start Shape >>>>>"))
    file:write(string.format(" %s\n", layer:str()))
    for _, pts in ipairs(pcol) do
        file:write(string.format("%s\n", pts))
        file:write("---\n")
    end
    file:write(string.format("%s\n", "<<<<<  End Shape  <<<<<"))
end

return M
