local M = {}

local __blackbackground = false
local __xmargin = 0
local __ymargin = 0
local __textmode = false
function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-t" or arg == "--text" then
            __textmode = true
        end
        if arg == "-b" or arg == "--black" then
            __blackbackground = true
        end
        if arg == "-x" or arg == "--x-margin" then
            if i < #opt then
                __xmargin = tonumber(opt[i + 1])
            else
                error("ppm export: --x-margin: argument expected")
            end
            i = i + 1
        end
        if arg == "-y" or arg == "--y-margin" then
            if i < #opt then
                __ymargin = tonumber(opt[i + 1])
            else
                error("ppm export: --y-margin: argument expected")
            end
            i = i + 1
        end
    end
end

local __canvas = {}
local __xoffset, __yoffset
local __width, __height
function M.initialize(minx, maxx, miny, maxy)
    __width = maxx - minx
    __height = maxy - miny
    __xoffset = -minx
    __yoffset = -miny
    for i = 0, __height do
        __canvas[i] = {}
        for j = 0, __width do
            __canvas[i][j] = { r = 255, g = 255, b = 255 }
        end
    end
end

local __content = {
    before = {},
    after = {},
    maxorder = 0
}

local function _insert_ordered_content(order, content)
    __content.maxorder = math.max(__content.maxorder, order)
    if not __content[order] then
        __content[order] = {}
    end
    table.insert(__content[order], content)
end

function M.finalize()
    local data = {}

    -- preamble
    for _, line in ipairs(__content.before) do
        table.insert(data, line)
    end

    for r = 1, __height do
        for c = 1, __width do
            local pixel = __canvas[r][c]
            table.insert(data, string.format("%s%s%s", string.char(pixel.r), string.char(pixel.g), string.char(pixel.b)))
        end
    end
    return table.concat(data)
end

function M.get_extension()
    return "ppm"
end

function M.get_techexport()
    return "svg"
end

function M.at_begin()
    if __textmode then
        table.insert(__content.before, "P3\n")
    else
        table.insert(__content.before, "P6\n")
    end
    table.insert(__content.before, string.format("%d %d\n", __width, __height)) -- Width Height
    table.insert(__content.before, "255\n") -- Max Color
end

local function _parse_color(colordef)
    local r, g, b = string.match(colordef, "(%x%x)(%x%x)(%x%x)")
    return {
        r = tonumber("0x" .. r),
        g = tonumber("0x" .. g),
        b = tonumber("0x" .. b),
    }
end

function M.write_rectangle(layer, bl, tr)
    local color = _parse_color(layer.color)
    local blx = bl.x
    local bly = bl.y
    local trx = tr.x
    local try = tr.y
    for y = bly, try do
        for x = blx, trx do
            __canvas[y + __yoffset][x + __xoffset].r = color.r
            __canvas[y + __yoffset][x + __xoffset].g = color.g
            __canvas[y + __yoffset][x + __xoffset].b = color.b
        end
    end
end

function M.write_polygon(layer, pts)
    -- FIXME
end

function M.write_port(name, layer, where, sizehint)
    -- FIXME
end

return M
