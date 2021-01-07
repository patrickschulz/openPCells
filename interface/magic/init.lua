local M = {}

function M.get_extension()
    return "mag"
end

function M.write_layer(file, layer, pcol)
    file:write(string.format("<< %s >>\n", layer))
    for _, pts in ipairs(pcol) do
        file:write(string.format("rect %s\n", pts))
    end
end

function M.get_layer(shape)
    return shape.lpp:get().layer
end

function M.get_points(shape)
    if shape.typ == "rectangle" then
        local grid = 1000
        local xbot, ybot = shape.points.bl:unwrap()
        xbot = xbot * grid
        ybot = ybot * grid
        local xtop, ytop = shape.points.tr:unwrap()
        xtop = xtop * grid
        ytop = ytop * grid
        return string.format("%d %d %d %d", math.floor(xbot), math.floor(ybot), math.floor(xtop), math.floor(ytop))
    else
        print("sorry, the magic interface does not (yet) support polygons")
        return nil
    end
end

function M.at_begin(file)
    file:write(string.format("%s\n", "magic"))
    file:write(string.format("tech %s\n", "sky130A")) -- FIXME: make flexible
    file:write(string.format("timestamp %s\n", os.time()))
end

function M.at_end(file)
    file:write(string.format("%s\n", "<< end >>"))
end

return M
