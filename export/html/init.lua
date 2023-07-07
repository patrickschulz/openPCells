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


local _shiftx = 0
local _shifty = 0
function M.initialize(minx, maxx, miny, maxy)
    _shiftx = -minx
    _shifty = -miny
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
    table.insert(__content.before, "        <canvas id=\"canvas\" width=\"1400\" height=\"800\">")
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

function M.write_rectangle(layer, bl, tr)
    local width = tr.x - bl.x
    local height = tr.y - bl.y
    _insert_ordered_content(layer.order or 0, string.format("            ctx.fillStyle = '#%s';", layer.color))
    _insert_ordered_content(layer.order or 0, string.format("            ctx.fillRect(%d, %d, %d, %d);", 
        _shiftx + bl.x, _shifty + bl.y, width, height))
end

function M.write_polygon(layer, pts)
    -- TODO
end

return M
