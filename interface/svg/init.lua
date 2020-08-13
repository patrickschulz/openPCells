local M = {}

function M.get_extension()
    return "svg"
end

-- private variables
local gridfmt = "%.3f"

local function _get_color_opacity(shape)
    if not shape.lpp:get().svg then
        return "black", 0.1
    end
    local color = shape.lpp:get().svg.color or "black"
    local opacity = shape.lpp:get().svg.opacity or 0.1
    local fill = shape.lpp:get().svg.fill or false
    return color, opacity, fill
end

local function _write_shape(file, shape, scale)
    local strokewidth = "5"
    local color, opacity, fill = _get_color_opacity(shape)
    if shape.typ == "polygon" then
        local pointstr = shape:concat_points(function(pt) return string.format(gridfmt .. "," .. gridfmt, scale * pt.x, scale * pt.y) end)
        local str = string.format('<polyline points="%s" stroke="%s" stroke-width="%s" fill="%s" opacity = "%.2f" />', 
            table.concat(pointstr, ' '),
            color, 
            strokewidth, 
            fill and color or "none",
            opacity
        )
        file:write(str)
    elseif shape.typ == "rectangle" then
        local pointstr = string.format('x="%f" y="%f" width="%f" height="%f"', 
            scale * shape.points.bl.x, 
            scale * shape.points.bl.y, 
            scale * shape:width(), 
            scale * shape:height()
        )
        local str = string.format('<rect %s stroke="%s" stroke-width="%s" fill="%s" opacity = "%.2f" />', 
            pointstr, 
            color, 
            strokewidth, 
            fill and color or "none",
            opacity
        )
        file:write(str)
    end
    file:write("\n")
end

local function _get_dimensions(cell)
    local minx =  math.huge
    local maxx = -math.huge
    local miny =  math.huge
    local maxy = -math.huge
    for shape in cell:iter() do
        if shape.typ == "polygon" then
            for _, pt in ipairs(shape.points) do
                minx = math.min(minx, pt.x)
                maxx = math.max(maxx, pt.x)
                miny = math.min(miny, pt.y)
                maxy = math.max(maxy, pt.y)
            end
        elseif shape.typ == "rectangle" then
            minx = math.min(minx, shape.points.bl.x, shape.points.tr.x)
            maxx = math.max(maxx, shape.points.bl.x, shape.points.tr.x)
            miny = math.min(miny, shape.points.bl.y, shape.points.tr.y)
            maxy = math.max(maxy, shape.points.bl.y, shape.points.tr.y)
        end
    end
    return maxx - minx, maxy - miny
end

local function _write_header(file, scale, width, height)
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
end

local function _write_style(file)
    local lines = {
        '<style type = "text/css">',
        'rect {}',
        '.poly { fill:#ff0000 }',
        '</style>',
    }
    file:write(table.concat(lines, '\n') .. '\n')
end

function M.print_object(file, cell)
    local width, height = _get_dimensions(cell)
    local target = 1000
    local scale = math.ceil(target / math.max(width, height))
    _write_header(file, scale, width, height)
    _write_style(file)
    for shape in cell:iter() do
        _write_shape(file, shape, scale)
    end
    file:write('</svg>')
end

return M
