local M = {}

function M.get_extension()
    return "svg"
end

-- private variables
local gridfmt = "%.3f"

function M.get_layer(shape)
    if not shape.lpp:get() then
        return string.format('fill="%s" opacity="%s"', "black", "0.1")
    end
    local color = shape.lpp:get().color or "black"
    local opacity = shape.lpp:get().opacity or 0.1
    local fill = shape.lpp:get().fill or false
    return string.format('stroke="%s" fill="%s" opacity="%s"', color, fill and color or "none", opacity)
end

function M.get_index(shape)
    if not shape.lpp:get() then
        return 1
    end
    local order = shape.lpp:get().order or 1
    return order
end

function M.write_layer(file, layer, pcol)
    file:write(string.format('<g %s>\n', layer))
    for _, pts in ipairs(pcol) do
        file:write(string.format("  %s\n", pts))
    end
    file:write("</g>\n")
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

local function _write_style(file)
    local lines = {
        '<style type = "text/css">',
        'rect {}',
        '.poly { fill:#ff0000 }',
        '</style>',
    }
    file:write(table.concat(lines, '\n') .. '\n')
end

function M.precompute(cell)
    local width, height = _get_dimensions(cell)
    local target = 1000
    local scale = math.ceil(target / math.max(width, height))
    return { width = width, height = height, scale = scale }
end

function M.at_begin(file, precomputed)
    local scale = precomputed.scale
    local width = precomputed.width
    local height = precomputed.height
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

function M.get_points(shape, precomputed)
    local scale = precomputed.scale
    local fmt
    if shape.typ == "polygon" then
        local pointstr = table.concat(shape:concat_points(function(pt) return string.format(gridfmt .. "," .. gridfmt, scale * pt.x, scale * pt.y) end), ' ')
        fmt = string.format('<polyline points="%s" />', pointstr)
    elseif shape.typ == "rectangle" then
        local pointstr = string.format('x="%f" y="%f" width="%f" height="%f"', 
            scale * shape.points.bl.x, 
            scale * shape.points.bl.y, 
            scale * shape:width(), 
            scale * shape:height()
        )
        fmt = string.format('<rect %s />', pointstr)
    end
    return fmt
end

function M.at_end(file)
    file:write('</svg>')
end

function M.set_options(opt)
    local opt = opt or {}
    for k, v in pairs(opt) do print(k, v) end
end

return M
