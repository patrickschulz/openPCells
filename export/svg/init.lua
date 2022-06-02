local M = {}

local __blackbackground = false
local __xmargin = 0
local __ymargin = 0
function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-b" or arg == "--black" then
            __blackbackground = true
        end
        if arg == "-x" or arg == "--x-margin" then
            if i < #opt then
                __xmargin = tonumber(opt[i + 1])
            else
                error("svg export: --x-margin: argument expected")
            end
            i = i + 1
        end
        if arg == "-y" or arg == "--y-margin" then
            if i < #opt then
                __ymargin = tonumber(opt[i + 1])
            else
                error("svg export: --y-margin: argument expected")
            end
            i = i + 1
        end
    end
end

local __width, __height
function M.initialize(minx, maxx, miny, maxy)
    local width = maxx - minx
    local height = maxy - miny
    __xoffset = -minx + __xmargin
    __yoffset = -miny + __ymargin
    __width = width + 2 * __xmargin
    __height = height + 2 * __ymargin
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

function M.at_begin()
    local x = math.ceil(__width)
    local y = math.ceil(__height)
    if x % 2 == 1 then x = x + 1 end
    if y % 2 == 1 then y = y + 1 end
    local lines = {
        string.format('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'),
        --string.format('<svg width="%d" height="%d" viewBox="-%d -%d %d %d">', x, y, x/ 2, y / 2, x, y),
        string.format('<svg width="%d" height="%d">', x, y),
    }
    local fill = "ffffff"
    if __blackbackground then
        fill = "000000"
    end
    table.insert(lines, string.format('<rect style="fill:#%s" x="0" y="0" width="%d" height="%d"/>', fill, x, y))
    table.insert(__content.before, table.concat(lines, '\n'))
end

function M.at_end()
    table.insert(__content.after, "</svg>")
end

local function _get_style(layer)
    return string.format("fill:#%s;opacity:%s;fill-opacity:%s", layer.color, layer.drawopacity or "1", layer.fillopacity or "1")
end

function M.write_rectangle(layer, bl, tr)
    local pointstr = string.format('x="%d" y="%d" width="%d" height="%d"',
        bl.x + __xoffset,
        bl.y + __yoffset,
        tr.x - bl.x,
        tr.y - bl.y
    )
    _insert_ordered_content(layer.order or 0, string.format('<rect style = "%s" %s />', _get_style(layer), pointstr))
end

function M.write_polygon(layer, pts)
    local ptstream = {}
    for _, pt in ipairs(pts) do
        table.insert(ptstream, string.format("%d,%d", pt.x + __xoffset, pt.y + __yoffset))
    end
    _insert_ordered_content(layer.order or 0, string.format('<polygon style = "%s" points = "%s" />', _get_style(layer), table.concat(ptstream, " ")))
end

return M
