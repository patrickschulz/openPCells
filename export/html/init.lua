local M = {}

local __content = {
    before = {},
    after = {},
    layerdata = {},
    maxorder = 0
}

local function _insert_ordered_content(order, content)
    __content.maxorder = math.max(__content.maxorder, order)
    if not __content[order] then
        __content[order] = {}
    end
    table.insert(__content[order], content)
end

local function _insert_layer_datum(order, name, content)
    __content.maxorder = math.max(__content.maxorder, order)
    if not __content.layerdata[order] then
        __content.layerdata[order] = {
            name = name,
            content = {}
        }
    end
    table.insert(__content.layerdata[order].content, content)
end

function M.finalize()
    local t = {}

    -- preamble
    for _, line in ipairs(__content.before) do
        table.insert(t, line)
    end

    -- layer data
    table.insert(t, "            layerdata = [")
    for i = 0, __content.maxorder do
        local layer = __content.layerdata[i]
        if layer then
            for _, entry in ipairs(layer.content) do
                table.insert(t, "                {")
                table.insert(t, string.format("                    layer: '%s',", layer.name))
                table.insert(t, string.format("                    color: '%s',", entry.color))
                table.insert(t, string.format("                    x: %d,", entry.x))
                table.insert(t, string.format("                    y: %d,", entry.y))
                table.insert(t, string.format("                    width: %d,", entry.width))
                table.insert(t, string.format("                    height: %d,", entry.height))
                table.insert(t, string.format("                    fill: %s", entry.fill and "true" or "false"))
                table.insert(t, "                },")
            end
        end
    end
    table.insert(t, "            ]")

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
    table.insert(__content.before, "        <meta charset=\"utf-8\"/>")
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
    table.insert(__content.before, "        <div>")
    table.insert(__content.before, "        </div>")
    table.insert(__content.before, "    </body>")
    table.insert(__content.before, "    <script type=\"application/javascript\">")
    table.insert(__content.before, "        var canvas = document.getElementById('canvas');")
    table.insert(__content.before, "        var ctx = canvas.getContext('2d');")
    table.insert(__content.before, "        var mouse = {")
    table.insert(__content.before, "            x : 0,")
    table.insert(__content.before, "            y : 0,")
    table.insert(__content.before, "            w : 0,")
    table.insert(__content.before, "            alt : false,")
    table.insert(__content.before, "            shift : false,")
    table.insert(__content.before, "            ctrl : false,")
    table.insert(__content.before, "            buttonLastRaw : 0, // user modified value")
    table.insert(__content.before, "            buttonRaw : 0,")
    table.insert(__content.before, "            over : false,")
    table.insert(__content.before, "            buttons : [1, 2, 4, 6, 5, 3], // masks for setting and clearing button raw bits;")
    table.insert(__content.before, "        };")
    table.insert(__content.before, "        function mouseMove(event) {")
    table.insert(__content.before, "            mouse.x = event.offsetX;")
    table.insert(__content.before, "            mouse.y = event.offsetY;")
    table.insert(__content.before, "            if (mouse.x === undefined) {")
    table.insert(__content.before, "                mouse.x = event.clientX;")
    table.insert(__content.before, "                mouse.y = event.clientY;")
    table.insert(__content.before, "            }")
    table.insert(__content.before, "            mouse.alt = event.altKey;")
    table.insert(__content.before, "            mouse.shift = event.shiftKey;")
    table.insert(__content.before, "            mouse.ctrl = event.ctrlKey;")
    table.insert(__content.before, "            if (event.type === \"mousedown\") {")
    table.insert(__content.before, "                event.preventDefault()")
    table.insert(__content.before, "                mouse.buttonRaw |= mouse.buttons[event.which-1];")
    table.insert(__content.before, "            } else if (event.type === \"mouseup\") {")
    table.insert(__content.before, "                mouse.buttonRaw &= mouse.buttons[event.which + 2];")
    table.insert(__content.before, "            } else if (event.type === \"mouseout\") {")
    table.insert(__content.before, "                mouse.buttonRaw = 0;")
    table.insert(__content.before, "                mouse.over = false;")
    table.insert(__content.before, "            } else if (event.type === \"mouseover\") {")
    table.insert(__content.before, "                mouse.over = true;")
    table.insert(__content.before, "            } else if (event.type === \"mousewheel\") {")
    table.insert(__content.before, "                event.preventDefault()")
    table.insert(__content.before, "                mouse.w = event.wheelDelta;")
    table.insert(__content.before, "            } else if (event.type === \"DOMMouseScroll\") { // FF you pedantic doffus")
    table.insert(__content.before, "               mouse.w = -event.detail;")
    table.insert(__content.before, "            }")
    table.insert(__content.before, "        }")
    table.insert(__content.before, "        function setupMouse(e) {")
    table.insert(__content.before, "            e.addEventListener('mousemove', mouseMove);")
    table.insert(__content.before, "            e.addEventListener('mousedown', mouseMove);")
    table.insert(__content.before, "            e.addEventListener('mouseup', mouseMove);")
    table.insert(__content.before, "            e.addEventListener('mouseout', mouseMove);")
    table.insert(__content.before, "            e.addEventListener('mouseover', mouseMove);")
    table.insert(__content.before, "            e.addEventListener('mousewheel', mouseMove);")
    table.insert(__content.before, "            e.addEventListener('DOMMouseScroll', mouseMove); // fire fox")
    table.insert(__content.before, "            ")
    table.insert(__content.before, "            e.addEventListener(\"contextmenu\", function (e) {")
    table.insert(__content.before, "                e.preventDefault();")
    table.insert(__content.before, "            }, false);")
    table.insert(__content.before, "        }")
    table.insert(__content.before, "        setupMouse(canvas);")
    table.insert(__content.before, "        // terms.")
    table.insert(__content.before, "        // Real space, real, r (prefix) refers to the transformed canvas space.")
    table.insert(__content.before, "        // c (prefix), chase is the value that chases a requiered value")
    table.insert(__content.before, "        var displayTransform = {")
    table.insert(__content.before, "            x:0,")
    table.insert(__content.before, "            y:0,")
    table.insert(__content.before, "            ox:0,")
    table.insert(__content.before, "            oy:0,")
    table.insert(__content.before, "            scale:1,")
    table.insert(__content.before, "            matrix:[0,0,0,0,0,0], // main matrix")
    table.insert(__content.before, "            invMatrix:[0,0,0,0,0,0], // invers matrix;")
    table.insert(__content.before, "            mouseX:0,")
    table.insert(__content.before, "            mouseY:0,")
    table.insert(__content.before, "            ctx:ctx,")
    table.insert(__content.before, "            setTransform:function(){")
    table.insert(__content.before, "                var m = this.matrix;")
    table.insert(__content.before, "                var i = 0;")
    table.insert(__content.before, "                this.ctx.setTransform(m[i++],m[i++],m[i++],m[i++],m[i++],m[i++]);")
    table.insert(__content.before, "            },")
    table.insert(__content.before, "            setHome:function(){")
    table.insert(__content.before, "                this.ctx.setTransform(1,0,0,1,0,0);")
    table.insert(__content.before, "            },")
    table.insert(__content.before, "            update:function(){")
    table.insert(__content.before, "                // create the display matrix")
    table.insert(__content.before, "                this.matrix[0] = this.scale;")
    table.insert(__content.before, "                this.matrix[1] = 0;")
    table.insert(__content.before, "                this.matrix[2] = -this.matrix[1];")
    table.insert(__content.before, "                this.matrix[3] = this.matrix[0];")
    table.insert(__content.before, "                // set the coords relative to the origin")
    table.insert(__content.before, "                this.matrix[4] = -(this.x * this.matrix[0] + this.y * this.matrix[2]) + this.ox;")
    table.insert(__content.before, "                this.matrix[5] = -(this.x * this.matrix[1] + this.y * this.matrix[3]) + this.oy;        ")
    table.insert(__content.before, "                // create invers matrix")
    table.insert(__content.before, "                var det = (this.matrix[0] * this.matrix[3] - this.matrix[1] * this.matrix[2]);")
    table.insert(__content.before, "                this.invMatrix[0] = this.matrix[3] / det;")
    table.insert(__content.before, "                this.invMatrix[1] = -this.matrix[1] / det;")
    table.insert(__content.before, "                this.invMatrix[2] = -this.matrix[2] / det;")
    table.insert(__content.before, "                this.invMatrix[3] = this.matrix[0] / det;")
    table.insert(__content.before, "                ")
    table.insert(__content.before, "                // check for mouse. Do controls and get real position of mouse.")
    table.insert(__content.before, "                if(mouse !== undefined){  // if there is a mouse get the real cavas coordinates of the mouse")
    table.insert(__content.before, "                    if(mouse.oldX !== undefined && (mouse.buttonRaw & 1)===1){ // check if panning (middle button)")
    table.insert(__content.before, "                        var mdx = mouse.x - mouse.oldX; // get the mouse movement")
    table.insert(__content.before, "                        var mdy = mouse.y - mouse.oldY;")
    table.insert(__content.before, "                        // get the movement in real space")
    table.insert(__content.before, "                        var mrx = (mdx * this.invMatrix[0] + mdy * this.invMatrix[2]);")
    table.insert(__content.before, "                        var mry = (mdx * this.invMatrix[1] + mdy * this.invMatrix[3]);   ")
    table.insert(__content.before, "                        this.x -= mrx;")
    table.insert(__content.before, "                        this.y -= mry;")
    table.insert(__content.before, "                    }")
    table.insert(__content.before, "                    // do the zoom with mouse wheel")
    table.insert(__content.before, "                    if(mouse.w !== undefined && mouse.w !== 0){")
    table.insert(__content.before, "                        this.ox = mouse.x;")
    table.insert(__content.before, "                        this.oy = mouse.y;")
    table.insert(__content.before, "                        this.x = this.mouseX;")
    table.insert(__content.before, "                        this.y = this.mouseY;")
    table.insert(__content.before, "                        if(mouse.w > 0){ // zoom in")
    table.insert(__content.before, "                            this.scale *= 1.1;")
    table.insert(__content.before, "                            mouse.w -= 20;")
    table.insert(__content.before, "                            if(mouse.w < 0){")
    table.insert(__content.before, "                                mouse.w = 0;")
    table.insert(__content.before, "                            }")
    table.insert(__content.before, "                        }")
    table.insert(__content.before, "                        if(mouse.w < 0){ // zoom out")
    table.insert(__content.before, "                            this.scale *= 1/1.1;")
    table.insert(__content.before, "                            mouse.w += 20;")
    table.insert(__content.before, "                            if(mouse.w > 0){")
    table.insert(__content.before, "                                mouse.w = 0;")
    table.insert(__content.before, "                            }")
    table.insert(__content.before, "                        }")
    table.insert(__content.before, "                    }")
    table.insert(__content.before, "                    // get the real mouse position ")
    table.insert(__content.before, "                    var screenX = (mouse.x - this.ox);")
    table.insert(__content.before, "                    var screenY = (mouse.y - this.oy);")
    table.insert(__content.before, "                    this.mouseX = this.x + (screenX * this.invMatrix[0] + screenY * this.invMatrix[2]);")
    table.insert(__content.before, "                    this.mouseY = this.y + (screenX * this.invMatrix[1] + screenY * this.invMatrix[3]);            ")
    table.insert(__content.before, "                    mouse.rx = this.mouseX;  // add the coordinates to the mouse. r is for real")
    table.insert(__content.before, "                    mouse.ry = this.mouseY;")
    table.insert(__content.before, "                    // save old mouse position")
    table.insert(__content.before, "                    mouse.oldX = mouse.x;")
    table.insert(__content.before, "                    mouse.oldY = mouse.y;")
    table.insert(__content.before, "                }")
    table.insert(__content.before, "            }")
    table.insert(__content.before, "        }")
    table.insert(__content.before, "        // set up font")
    table.insert(__content.before, "        ctx.font = \"14px verdana\";")
    table.insert(__content.before, "        ctx.textAlign = \"center\";")
    table.insert(__content.before, "        ctx.textBaseline = \"middle\";")
    table.insert(__content.before, "        function update(){")
    table.insert(__content.before, "            // update the transform")
    table.insert(__content.before, "            displayTransform.update();")
    table.insert(__content.before, "            // set home transform to clear the screem")
    table.insert(__content.before, "            displayTransform.setHome();")
    table.insert(__content.before, "            ctx.clearRect(0,0,canvas.width,canvas.height);")
    table.insert(__content.before, "            displayTransform.setTransform();")
end

function M.at_end()
    table.insert(__content.after, "            layerdata.forEach(")
    table.insert(__content.after, "                function(d) {")
    -- TODO: insert layer palette control
    table.insert(__content.after, "                    if(true)")
    table.insert(__content.after, "                    {")
    table.insert(__content.after, "                        ctx.globalAlpha = 1;")
    table.insert(__content.after, "                        ctx.beginPath();")
    table.insert(__content.after, "                        ctx.strokeStyle = d.color;")
    table.insert(__content.after, "                        ctx.fillStyle = d.color;")
    table.insert(__content.after, "                        ctx.rect(d.x, d.y, d.width, d.height);")
    table.insert(__content.after, "                        if(d.fill)")
    table.insert(__content.after, "                        {")
    table.insert(__content.after, "                            ctx.fill();")
    table.insert(__content.after, "                        }")
    table.insert(__content.after, "                        else")
    table.insert(__content.after, "                        {")
    table.insert(__content.after, "                            ctx.stroke();")
    table.insert(__content.after, "                        }")
    table.insert(__content.after, "                    }")
    table.insert(__content.after, "                }")
    table.insert(__content.after, "            )")
    table.insert(__content.after, "            // request next frame")
    table.insert(__content.after, "            requestAnimationFrame(update);")
    table.insert(__content.after, "        }")
    table.insert(__content.after, "        update(); // start it happening")
    table.insert(__content.after, "    </script>")
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
    local color = _get_layer_color(layer)
    _insert_layer_datum(layer.order, layer.name, {
        x = blx,
        y = bly,
        width = trx - blx,
        height = try - bly,
        color = string.format("#%s", color),
        fill = not layer.nofill
    })
    --[[
    _insert_ordered_content(layer.order or 0, "            ctx.globalAlpha = 1;")
    _insert_ordered_content(layer.order or 0, "            ctx.beginPath();")
    _insert_ordered_content(layer.order or 0, string.format("            ctx.strokeStyle = '#%s';", color))
    _insert_ordered_content(layer.order or 0, string.format("            ctx.fillStyle = '#%s';", color))
    _insert_ordered_content(layer.order or 0, string.format("            ctx.rect(%d, %d, %d, %d);", 
        blx, bly, width, height))
    if layer.nofill then
        _insert_ordered_content(layer.order or 0, "            ctx.stroke();")
    else
        _insert_ordered_content(layer.order or 0, "            ctx.fill();")
    end
    _insert_ordered_content(layer.order or 0, "            ctx.globalAlpha = 1;")
    --]]
end

function M.write_polygon(layer, pts)
    --[[
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
    --]]
end

function M.write_port()
end

return M
