local point = require "point"
local object = require "object"
local shape  = require "shape"
local layout = require "layout"
local graphics = require "graphics"
local pcell = require "pcell"

return function(args)
    local width = pcell.process_args(args, "width", "number", 10.0)
    return layout.corner("M10", "drawing", point.create(0, 0), point.create(100, 100), 10, 30, 0.1)
end
