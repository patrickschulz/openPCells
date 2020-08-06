local M = {}

function M.get_extension()
    return "svg"
end

-- private variables
local gridfmt = "%.3f"

local function _write_shape(file, shape)
    local pointstr = shape.points:concat(function(pt) return string.format(gridfmt .. "," .. gridfmt, pt.x, pt.y) end)
    local color = "red"
    local strokewidth = "1"
    local str = string.format('<polyline points="%s" stroke="%s" stroke-width="%s" fill="%s" />', pointstr, color, strokewidth, color)
    file:write(str)
    file:write("\n")
end

function M.print_object(file, obj)
    file:write([[
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="391" height="391" viewBox="-70.5 -70.5 391 391" xmlns="http://www.w3.org/2000/svg">
<rect fill="#fff" stroke="#000" x="-70" y="-70" width="390" height="390"/>
]])
    for shape in obj:iter() do
        _write_shape(file, shape)
    end
    file:write([[
</svg>
]])
end

return M
