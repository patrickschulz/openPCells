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
        st = "Rectangle"
    end
    file:write(string.format('    dbCreate%s(cv list("%s" "%s") ', st, shape.lpp:get().virtuoso.layer, shape.lpp:get().virtuoso.purpose))
    local pointlist = shape:concat_points(function(pt) return string.format(gridfmt .. ":" .. gridfmt, pt.x, pt.y) end)
    file:write(string.format("list(%s)", table.concat(pointlist, " ")))
    file:write(")\n")
end

function M.print_object(file, object)
    file:write([[
let(
    (
        (cv geGetEditCellView())
    )
]])
    local sep = sep or "\n"
    for shape in object:iter() do
        _write_shape(file, shape)
    end
    file:write(") ; let\n")
end

return M
