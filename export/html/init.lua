local M = {}

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
    return "html"
end

-- re-use svg definitions
function M.get_techexport()
    return "svg"
end

local __width = 1400
local __height

local __minx, __maxx, __miny, __maxy
function M.initialize(minx, maxx, miny, maxy)
    local ratio = (maxx - minx) / (maxy - miny)
    __height = math.floor(__width / ratio)
    __minx = minx
    __maxx = maxx
    __miny = miny
    __maxy = maxy
end

local function _translate_coordinates(pt)
    local xt = __width * (pt.x - __minx) / (__maxx - __minx)
    local yt = __height * (pt.y - __miny) / (__maxy - __miny)
    return math.floor(xt), math.floor(yt)
end

function M.at_begin()
    table.insert(__content.before, "<!DOCTYPE html>")
    table.insert(__content.before, "<html lang=\"en-US\">")
    table.insert(__content.before, "    <head>")
    table.insert(__content.before, "        <meta charset=\"UTF-8\"/>")
    table.insert(__content.before, "        <title>OpenPCells</title>")
    table.insert(__content.before, "        <style>")
    table.insert(__content.before, "            canvas {")
    table.insert(__content.before, "                border: 1px solid black;")
    table.insert(__content.before, "            }")
    table.insert(__content.before, "        </style>")
    table.insert(__content.before, "    </head>")
    table.insert(__content.before, "    <body>")
    table.insert(__content.before, string.format("        <canvas id=\"canvas\" width=\"%d\" height=\"%d\">", __width, __height))
    table.insert(__content.before, "            Canvas not supported")
    table.insert(__content.before, "        </canvas>")
    table.insert(__content.before, "        <script type=\"application/javascript\">")
    table.insert(__content.before, "            const canvas = document.getElementById('canvas');")
    table.insert(__content.before, "            const ctx = canvas.getContext('2d');")
end

function M.at_end()
    table.insert(__content.after, "       </script>")
    table.insert(__content.after, "    </body>")
    table.insert(__content.after, "</html>")
end

local function _get_layer_color(layer)
    local pattern = "^rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)$"
    local r, g, b = string.match(layer.color, pattern)
    if r then
        return string.format("%02x%02x%02x", r, g, b)
    else
        return layer.color
    end
end

function M.write_rectangle(layer, bl, tr)
    local blx, bly = _translate_coordinates(bl)
    local trx, try = _translate_coordinates(tr)
    local width = trx - blx
    local height = try - bly
    local color = _get_layer_color(layer)
    _insert_ordered_content(layer.order or 0, string.format("            ctx.fillStyle = '#%s';", color))
    _insert_ordered_content(layer.order or 0, string.format("            ctx.fillRect(%d, %d, %d, %d);", 
        blx, bly, width, height))
end

function M.write_polygon(layer, pts)
    local color = _get_layer_color(layer)
    _insert_ordered_content(layer.order or 0, string.format("            ctx.fillStyle = '#%s';", color))
    _insert_ordered_content(layer.order or 0, "            ctx.beginPath();")
    local x0, y0 = _translate_coordinates(pts[1])
    _insert_ordered_content(layer.order or 0, string.format("            ctx.moveTo(%d, %d);", x0, y0))
    for i = 2, #pts do
        local x, y = _translate_coordinates(pts[i])
        _insert_ordered_content(layer.order or 0, string.format("            ctx.lineTo(%d, %d);", x, y))
    end
    _insert_ordered_content(layer.order or 0, "            ctx.closePath();")
    _insert_ordered_content(layer.order or 0, "            ctx.fill();")
end

function M.write_port()
end

return M
