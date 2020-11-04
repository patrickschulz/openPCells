local M = {}

function M.get_extension()
    return "svg"
end

-- private variables
local gridfmt = "%.3f"

local function _get_dimensions(cell)
    local minx =  math.huge
    local maxx = -math.huge
    local miny =  math.huge
    local maxy = -math.huge
    for _, shape in cell:iter() do
        if shape.typ == "polygon" then
            for _, pt in ipairs(shape.points) do
                local x, y = pt:unwrap()
                minx = math.min(minx, x)
                maxx = math.max(maxx, x)
                miny = math.min(miny, y)
                maxy = math.max(maxy, y)
            end
        elseif shape.typ == "rectangle" then
            local blx, bly = shape.points.bl:unwrap()
            local trx, try = shape.points.tr:unwrap()
            minx = math.min(minx, blx, trx)
            maxx = math.max(maxx, blx, trx)
            miny = math.min(miny, bly, try)
            maxy = math.max(maxy, bly, try)
        end
    end
    return maxx - minx, maxy - miny
end

--[[
local function _write_style(file)
    local lines = {
        '<style type = "text/css">',
        'rect {}',
        '.poly { fill:#ff0000 }',
        '</style>',
    }
    file:write(table.concat(lines, '\n') .. '\n')
end
--]]

function M.get_layer(shape)
    if not shape.lpp:get() then
        return string.format('fill="%s" opacity="%s"', "black", "0.1")
    end
    local color = shape.lpp:get().color or "black"
    local opacity = shape.lpp:get().opacity or 0.1
    local fill = shape.lpp:get().fill or false
    return string.format('stroke="%s" fill="%s" opacity="%s" stroke-width="0.5%%"', color, fill and color or "none", opacity)
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
        string.format('<svg width="%d" height="%d" viewBox="-%d -%d %d %d">', x, y, x/ 2, y / 2, x, y),
        '<rect fill="#fff" x="-50%" y="-50%" width="100%" height="100%"/>',
    }
    file:write(table.concat(lines, '\n') .. '\n')
end

function M.get_points(shape, precomputed)
    local scale = precomputed.scale
    local fmt
    if shape.typ == "polygon" then
        local pointstr = table.concat(shape:concat_points(
            function(pt)
                local x, y = pt:unwrap()
                return string.format(gridfmt .. "," .. gridfmt, scale * x, scale * y) end
            ), ' '
        )
        fmt = string.format('<polyline points="%s" />', pointstr)
    elseif shape.typ == "rectangle" then
        local x, y = shape.points.bl:unwrap()
        local pointstr = string.format('x="%f" y="%f" width="%f" height="%f"',
            scale * x,
            scale * y,
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
    opt = opt or {}
    for k, v in pairs(opt) do print(k, v) end
end

return M
