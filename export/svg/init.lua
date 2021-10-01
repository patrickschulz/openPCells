local M = {}

local __width, __height, __scale
local __gridfmt = "%.3f"
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

function M.get_extension()
    return "svg"
end

function M.get_layer(S)
    return S:get_lpp():get()
end

function M.at_begin(file)
    local x = math.ceil(1.1 * __scale * __width)
    local y = math.ceil(1.1 * __scale * __height)
    if x % 2 == 1 then x = x + 1 end
    if y % 2 == 1 then y = y + 1 end
    local lines = {
        string.format('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'),
        string.format('<svg width="%d" height="%d" viewBox="-%d -%d %d %d">', x, y, x/ 2, y / 2, x, y),
        '<rect fill="#fff" x="-50%" y="-50%" width="100%" height="100%"/>',
    }
    file:write(table.concat(lines, '\n') .. '\n')
end

function M.at_end(file)
    file:write("</svg>\n")
end

function M.write_rectangle(file, layer, bl, tr)
    local fmtstr = string.format('fill = "%s" fill-opacity = "0.5"', layer.color)
    local blx, bly = bl:unwrap()
    local trx, try = tr:unwrap()
    local pointstr = string.format('x="%f" y="%f" width="%f" height="%f"',
        __scale * blx,
        __scale * bly,
        __scale * (trx - blx),
        __scale * (try - bly)
    )
    file:write(string.format('<rect %s %s />\n', fmtstr, pointstr))
end

-- * mandatory *
-- how to write a polygon
function M.write_polygon(file, layer, pts)
end

-- * optional *
-- how to write a path
-- if not present, the shape will be converted accordingly (to a single rectangle if possible, otherwise to a polygon)
function M.write_path(file, layer, pts, width)
end

-- * optional *
-- how to write a named for layout topology data (e.g. LVS)
function M.write_port(file, name, layer, where)
end

return M
