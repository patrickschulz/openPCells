local M = {}

function M.get_extension()
    return "il"
end

-- private variables
local gridfmt = "%.3f"

local function _write_shape(file, shape)
    local sep = sep or "\n"
    local fmt = string.format("%s %s%s", gridfmt, gridfmt, sep)
    local st
    if shape.typ == "polygon" then
        st = "Polygon"
    elseif shape.typ == "rectangle" then
        st = "Rect"
    end
    local pointlist = shape:concat_points(function(pt) return string.format(gridfmt .. ":" .. gridfmt, pt.x, pt.y) end)
    file:write(string.format("list(%s)", table.concat(pointlist, " ")))
    file:write(")\n")
end

function M.at_begin(file)
    file:write([[
let(
    (
        (cv geGetEditCellView())
    )
]])
end

function M.at_end(file)
    file:write(") ; let\n")
end

function M.write_layer(file, layer, pcol)
    file:write(string.format("    foreach(pts list(%s)\n", table.concat(pcol, " ")))
    for _, pts in ipairs(pcol) do
        file:write(string.format("        %s pts)\n", layer))
    end
    file:write("    )\n")
end

function M.get_layer(shape)
    local st
    if shape.typ == "polygon" then
        st = "Polygon"
    elseif shape.typ == "rectangle" then
        st = "Rect"
    end
    return string.format('dbCreate%s(cv list("%s" "%s")', st, shape.lpp:get().virtuoso.layer, shape.lpp:get().virtuoso.purpose)
end

function M.get_points(shape)
    local fmt = string.format("%s %s", gridfmt, gridfmt)
    local pointlist = shape:concat_points(function(pt) return string.format(gridfmt .. ":" .. gridfmt, pt.x, pt.y) end)
    return string.format("list(%s)", table.concat(pointlist, " "))
end

return M
