local M = {}

local __blackbackground = false
local __transparentbackground = false
local __xmargin = 0
local __ymargin = 0
local __scale = 1
local __xoffsetmanual = 0
local __yoffsetmanual = 0
local __forcetransparency = false
local __forcetransparancyfactor = 0.8
function M.set_options(opt)
    for i = 1, #opt do
        local arg = opt[i]
        if arg == "-b" or arg == "--black-background" then
            __blackbackground = true
        end
        if arg == "-t" or arg == "--transparent-background" then
            __transparentbackground = true
        end
        if arg == "--force-transparancy" then
            __forcetransparency = true
        end
        if arg == "--xoffset" then
            if i < #opt then
                __xoffsetmanual = tonumber(opt[i + 1])
            else
                error("svg export: --xoffset: argument expected")
            end
            i = i + 1
        end
        if arg == "--yoffset" then
            if i < #opt then
                __yoffsetmanual = tonumber(opt[i + 1])
            else
                error("svg export: --yoffset: argument expected")
            end
            i = i + 1
        end
        if arg == "--xmargin" then
            if i < #opt then
                __xmargin = tonumber(opt[i + 1])
            else
                error("svg export: --xmargin: argument expected")
            end
            i = i + 1
        end
        if arg == "--ymargin" then
            if i < #opt then
                __ymargin = tonumber(opt[i + 1])
            else
                error("svg export: --ymargin: argument expected")
            end
            i = i + 1
        end
        if arg == "-s" or arg == "--scale" then
            if i < #opt then
                __scale = tonumber(opt[i + 1])
            else
                error("svg export: --scale: argument (a number) expected")
            end
            i = i + 1
        end
    end
end

local __width, __height
function M.initialize(minx, maxx, miny, maxy)
    local width = maxx - minx
    local height = maxy - miny
    __xoffset = -minx * __scale + __xmargin + __xoffsetmanual
    __yoffset = -miny * __scale + __ymargin + __yoffsetmanual
    __width = width * __scale + 2 * __xmargin
    __height = height * __scale + 2 * __ymargin
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
    if not __transparentbackground then
        local fill = "ffffff"
        if __blackbackground then
            fill = "000000"
        end
        table.insert(lines, string.format('<rect style="fill:#%s" x="0" y="0" width="%d" height="%d"/>', fill, x, y))
    end
    table.insert(__content.before, table.concat(lines, '\n'))
end

function M.at_end()
    table.insert(__content.after, "</svg>")
end

local function _get_style(layer)
    if __forcetransparency then
        return string.format("fill:#%s; opacity:%s; fill-opacity:%s", layer.color, __forcetransparancyfactor, __forcetransparancyfactor)
    else
        return string.format("fill:#%s; opacity:%s; fill-opacity:%s", layer.color, layer.drawopacity or "1", layer.fillopacity or "1")
    end
end

local function _format_x_coordinate(x)
    return string.format("%d", math.floor(__scale * x) + __xoffset)
end

local function _format_y_coordinate(y, mirroroffset)
    mirroroffset = mirroroffset or 0
    return string.format("%d", __height - (mirroroffset + math.floor(__scale * y) + __yoffset))
end

local function _format_point(pt)
    return string.format("%s,%s", _format_x_coordinate(pt.x), _format_y_coordinate(pt.y))
end

local function _check_layer(layer)
    return not layer.ignore
end

function M.write_rectangle(layer, bl, tr)
    if not _check_layer(layer) then
        return
    end
    local pointstr = string.format('x="%d" y="%d" width="%d" height="%d"',
        _format_x_coordinate(bl.x),
        _format_y_coordinate(bl.y, tr.y - bl.y),
        tr.x - bl.x,
        tr.y - bl.y
    )
    _insert_ordered_content(layer.order or 0, string.format('<rect style = "%s" %s />', _get_style(layer), pointstr))
end

function M.write_polygon(layer, pts)
    if not _check_layer(layer) then
        return
    end
    local ptstream = {}
    for _, pt in ipairs(pts) do
        table.insert(ptstream, _format_point(pt))
    end
    _insert_ordered_content(layer.order or 0, string.format('<polygon style = "%s" points = "%s" />', _get_style(layer), table.concat(ptstream, " ")))
end

-- curve support (paths in SVG terminology)
local curveorder
local curvecontent
function M.setup_curve(layer, origin)
    curvecontent = {}
    curveorder = layer.order or 0
    table.insert(curvecontent, string.format('<path style = "%s" d = "M %s', _get_style(layer), _format_point(origin)))
end

function M.curve_add_line_segment(pt1)
    table.insert(curvecontent, string.format("L %s", _format_point(pt1)))
end

function M.curve_add_arc_segment(startpt, startangle, endangle, radius, clockwise)
    local pt = {
        x = math.floor(startpt.x + (math.cos(endangle * math.pi / 180) - math.cos(startangle * math.pi / 180)) * radius),
        y = math.floor(startpt.y + (math.sin(endangle * math.pi / 180) - math.sin(startangle * math.pi / 180)) * radius)
    }
    clockwise = clockwise and 0 or 1
    table.insert(curvecontent, string.format("A %d %d 0 0 %d %s", __scale * radius, __scale * radius, clockwise, _format_point(pt)))
end

function M.close_curve()
    table.insert(curvecontent, 'Z" />')
    _insert_ordered_content(curveorder, table.concat(curvecontent, ' '))
end

function M.write_port(name, layer, where, sizehint)
    _insert_ordered_content(
        layer.order or 0,
        string.format(
            '<text x = "%d" y = "%d" transform="scale(%d)">%s</text>',
            _format_x_coordinate(where.x),
            _format_y_coordinate(where.y),
            sizehint or __width / 10,
            name
        )
    )
end

return M
