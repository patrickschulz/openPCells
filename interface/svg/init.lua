local M = {}

function M.get_extension()
    return "svg"
end

-- private variables
local gridfmt = "%.3f"

local function _get_color_opacity(shape)
    local color = shape.lpp:get().color or "black"
    local opacity = shape.lpp:get().opacity or 0.1
    return color, opacity
end

local function _write_shape(file, shape, scale)
    local pointstr = shape.points:concat(function(pt) return string.format(gridfmt .. "," .. gridfmt, scale * pt.x, scale * pt.y) end)
    local strokewidth = "1"
    local color, opacity = _get_color_opacity(shape)
    local str = string.format('<polyline points="%s" stroke="%s" stroke-width="%s" fill="%s" opacity = "%.2f" />', pointstr, color, strokewidth, color, opacity)
    file:write(str)
    file:write("\n")
end

local function _get_dimensions(cell)
    local minx =  math.huge
    local maxx = -math.huge
    local miny =  math.huge
    local maxy = -math.huge
    for shape in cell:iter() do
        for _, pt in ipairs(shape.points) do
            minx = math.min(minx, pt.x)
            maxx = math.max(maxx, pt.x)
            miny = math.min(miny, pt.y)
            maxy = math.max(maxy, pt.y)
        end
    end
    return maxx - minx, maxy - miny
end

function M.print_object(file, cell)
    local width, height = _get_dimensions(cell)
    local target = 1000
    local scale = math.ceil(target / math.max(width, height))
    local x = math.ceil(1.1 * scale * width)
    local y = math.ceil(1.1 * scale * height)
    if x % 2 == 1 then x = x + 1 end
    if y % 2 == 1 then y = y + 1 end
    local lines = {
        string.format('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'),
        string.format('<svg width="%d" height="%d" viewBox="-%d -%d %d %d">', x, y, 0.5 * x, 0.5 * y, x, y),
        '<rect fill="#fff" x="-50%" y="-50%" width="100%" height="100%"/>',
    }
    file:write(table.concat(lines, '\n') .. '\n')
    for shape in cell:iter() do
        _write_shape(file, shape, scale)
    end
    file:write('\n</svg>\n')
end

return M
