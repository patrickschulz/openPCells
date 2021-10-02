local M = {}

local __width, __height, __scale
local __gridfmt = "%.3f"
local __content = {
    before = {},
    after = {},
    maxorder = 0
}

function M.initialize(toplevel)
    -- get cell dimensions
    local minx =  math.huge
    local maxx = -math.huge
    local miny =  math.huge
    local maxy = -math.huge
    for _, shape in toplevel:iterate_shapes() do
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
    local width = maxx - minx
    local height = maxy - miny
    local target = 1000
    local scale = math.ceil(target / math.max(width, height))
    __width = width
    __height = height
    __scale = scale
end

function M.finalize()
    local t = {}

    -- preamble
    for _, line in ipairs(__content.before) do
        table.insert(t, line)
    end

    -- main content
    for i = 0, __content.maxorder do
        if __content[i] then
            for _, line in ipairs(__content[i]) do
                table.insert(t, line)
            end
        end
    end

    -- end
    for _, line in ipairs(__content.after) do
        table.insert(t, line)
    end

    return table.concat(t, "\n")
end

function M.get_extension()
    return "svg"
end

function M.get_layer(S)
    local layer = S:get_lpp():get()
    local order = layer.order
    if not layer.order then layer.order = 0 end
    if not __content[layer.order] then
        __content[layer.order] = {}
    end
    __content.maxorder = math.max(__content.maxorder, layer.order)
    return layer
end

function M.at_begin()
    local x = math.ceil(1.1 * __scale * __width)
    local y = math.ceil(1.1 * __scale * __height)
    if x % 2 == 1 then x = x + 1 end
    if y % 2 == 1 then y = y + 1 end
    local lines = {
        string.format('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'),
        string.format('<svg width="%d" height="%d" viewBox="-%d -%d %d %d">', x, y, x/ 2, y / 2, x, y),
        '<rect fill="#fff" x="-50%" y="-50%" width="100%" height="100%"/>',
    }
    table.insert(__content.before, table.concat(lines, '\n'))
end

function M.at_end()
    table.insert(__content.after, "</svg>")
end

function M.write_rectangle(layer, bl, tr)
    local fmtstr = string.format('fill = "%s" fill-opacity = "0.5"', layer.color)
    local blx, bly = bl:unwrap()
    local trx, try = tr:unwrap()
    local pointstr = string.format('x="%f" y="%f" width="%f" height="%f"',
        __scale * blx,
        __scale * bly,
        __scale * (trx - blx),
        __scale * (try - bly)
    )
    table.insert(__content[layer.order], string.format('<rect %s %s />', fmtstr, pointstr))
end

-- * mandatory *
-- how to write a polygon
function M.write_polygon(layer, pts)
end

-- * optional *
-- how to write a path
-- if not present, the shape will be converted accordingly (to a single rectangle if possible, otherwise to a polygon)
function M.write_path(layer, pts, width)
end

-- * optional *
-- how to write a named for layout topology data (e.g. LVS)
function M.write_port(name, layer, where)
end

return M
