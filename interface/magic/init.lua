local M = {}

function M.get_extension()
    return "mag"
end

-- private variables
local gridfmt = "%.3f"

local function _get_layer(shape)
    return shape.lpp:get().layer.name
end

local function _write_layer(file, layer, pcol)
    file:write(string.format("<< %s >>\n", layer))
    local grid = 1000
    for _, pts in ipairs(pcol) do
        local xbot, ybot = pts[1]:unwrap(grid)
        local xtop, ytop = pts[3]:unwrap(grid)
        file:write(string.format("rect %d %d %d %d\n", math.floor(xbot), math.floor(ybot), math.floor(xtop), math.floor(ytop)))
    end
end

local function _order_shapes(obj)
    local shapes = {}
    for shape in obj:iter() do
        local layer = _get_layer(shape)
        if not shapes[layer] then
            shapes[layer] = {}
        end
        table.insert(shapes[layer], shape.points)
    end
    return shapes
end

function M.print_object(file, obj)
    file:write(string.format("%s\n", "magic"))
    file:write(string.format("tech %s\n", "sky130A")) -- FIXME: make flexible
    file:write(string.format("timestamp %s\n", "1595254680")) -- FIXME: insert real timestamp
    for layer, pcol in pairs(_order_shapes(obj)) do
        _write_layer(file, layer, pcol)
    end
    file:write(string.format("%s\n", "<< end >>"))
end

--[[
timestamp 1595254680
<< nwell >>
rect 0 272 208 416
<< mcon >>
rect 44 76 61 93
rect 148 76 165 93
rect 96 115 113 132
rect 96 284 113 301
rect 44 323 61 340
rect 148 323 165 340
<< poly >>
rect 97 48 112 107
rect 88 107 121 140
rect 88 276 121 309
rect 97 309 112 368
<< bound >>
rect 0 0 208 416
<< li1 >>
rect 36 68 69 101
rect 140 68 173 101
rect 88 107 121 140
rect 88 276 121 309
rect 36 315 69 348
rect 140 315 173 348
<< met1 >>
rect 0 -20 208 20
rect 45 20 59 73
rect 41 73 64 96
rect 93 112 116 135
rect 97 135 111 281
rect 93 281 116 304
rect 145 73 168 96
rect 149 96 163 320
rect 145 320 168 343
rect 41 320 64 343
rect 45 343 59 397
rect 0 397 208 436
<< li1 >>
<< met1 >>
<< li1 >>
<< met1 >>
rect 0 -20 208 20
rect 93 112 116 135
rect 97 135 111 281
rect 93 281 116 304
rect 145 73 168 96
rect 149 96 163 320
rect 145 320 168 343
rect 0 397 208 436
<< ndiffusion >>
rect 40 72 65 78
rect 144 72 169 78
rect 40 78 169 93
rect 40 93 65 97
rect 144 93 169 97
<< pdiffusion >>
rect 40 319 65 323
rect 144 319 169 323
rect 40 323 169 338
rect 40 338 65 344
rect 144 338 169 344
<< licon1 >>
rect 96 115 113 132
rect 96 284 113 301
<< licon1 >>
rect 44 76 61 93
rect 148 76 165 93
rect 44 323 61 340
rect 148 323 165 340
--]]

return M
