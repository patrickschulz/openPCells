local M = {}

function M.get_extension()
    return "il"
end

-- private variables
local gridfmt = "%.3f"

local function _write_shape(file, shape)
    local sep = sep or "\n"
    local fmt = string.format("%s %s%s", gridfmt, gridfmt, sep)
    file:write(string.format('    dbCreatePolygon(cv list("%s" "%s") ', shape.lpp:get().virtuoso.layer, shape.lpp:get().virtuoso.purpose))
    file:write(string.format("list(%s)", shape.points:concat(function(pt) return string.format(gridfmt .. ":" .. gridfmt, pt.x, pt.y) end)))
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
