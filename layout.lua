local M = {}

local point      = require "point"
local graphics   = require "graphics"
local pointarray = require "pointarray"
local shape      = require "shape"
local object     = require "object"

-- private helper functions
local function _rectangle(center, width, height)
    local pts = pointarray.create()
    -- polygon
    pts:append(point.create(center.x - 0.5 * width, center.y - 0.5 * height))
    pts:append(point.create(center.x + 0.5 * width, center.y - 0.5 * height))
    pts:append(point.create(center.x + 0.5 * width, center.y + 0.5 * height))
    pts:append(point.create(center.x - 0.5 * width, center.y + 0.5 * height))
    return pts
end

local function _get_layer_via_lists(startlayer, endlayer)
    local layers = {}
    local vias = {}
    if startlayer == "active" or startlayer == "gate" then
        table.insert(layers, startlayer)
        table.insert(vias, startlayer == "active" and "wellcont" or "gatecont")
    end
    local startindex = string.match(startlayer, "M(%d)") or 1
    local endindex = string.match(endlayer, "M(%d)") or 1
    for i = startindex, endindex do
        table.insert(layers, string.format("M%d", i))
    end
    return layers, vias
end

local function _default_options(options)
    options.xrep    = options.xrep or 1.0
    options.yrep    = options.yrep or 1.0
    options.xpitch  = options.xpitch or 0.0
    options.ypitch  = options.ypitch or 0.0
    options.xoffset = options.xoffset or 0.0
    options.yoffset = options.yoffset or 0.0
    return options
end

-- public interface
function M.rectangle(layer, purpose, center, width, height, options)
    local opt = _default_options(options or {})
    local obj = shape.create(layer, purpose)
    for x = 1, opt.xrep do
        for y = 1, opt.yrep do
            local c = point.create(
                center.x + opt.xoffset + (x - 1) * opt.xpitch - 0.5 * (opt.xrep - 1) * opt.xpitch, 
                center.y + opt.yoffset + (y - 1) * opt.ypitch - 0.5 * (opt.yrep - 1) * opt.ypitch
            )
            local pts = _rectangle(c, width, height)
            obj:add_pointarray(pts)
        end
    end
    return obj
end

function M.via(spec, width, height, options)
    local opt = _default_options(options or {})
    local startlayer, endlayer = string.match(spec, "(%w+)%-%>(%w+)")
    local shapes = {}
    local layers, vias = _get_layer_via_lists(startlayer, endlayer)
    local origin = point.create(opt.xoffset, opt.yoffset)
    for _, layer in ipairs(layers) do
        local s = M.rectangle(layer, "drawing", origin, width, height)
        table.insert(shapes, s)
    end
    for _, via in ipairs(vias) do
        local viawidth = 0.03
        local viaheight = 0.06
        local viaxspace = 0.116
        local viayspace = 0.116
        local viaminxencl = 0.0
        local viaminyencl = 0.0
        local cols = math.max(1, math.floor((width + viaxspace - 2 * viaminxencl) / (viawidth + viaxspace)))
        local rows = math.max(1, math.floor((height + viayspace - 2 * viaminyencl) / (viaheight + viayspace)))
        --(metalxencl max(viaminxencl 0.5 * (width - cols * viawidth - (cols - 1) * viaxspace)))
        --(metalyencl max(viaminyencl 0.5 * (height - rows * viaheight - (rows - 1) * viayspace)))
        local viaopt = {
            xrep = cols,
            xpitch = viawidth + viaxspace,
            yrep = rows,
            ypitch = viaheight + viayspace
        }

        local s = M.rectangle(via, "drawing", origin, viawidth, viaheight, viaopt)
        table.insert(shapes, s)
    end
    return shapes
end

return M
