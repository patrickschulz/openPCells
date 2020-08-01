local point = require "point"
local pointarray = require "pointarray"
local shape = require "shape"
local object = require "object"
local layout = require "layout"
local pcell = require "pcell"

return function(args)
    local turns = pcell.process_args(args, "turns", "number", 3)
    local width = pcell.process_args(args, "width", "number", 6)
    local spacing = pcell.process_args(args, "spacing", "number", 6)
    local innerdiameter = pcell.process_args(args, "innerdiameter", "number", 10)

    local pathpts = pointarray.create()
    for i = 1, turns do
        local xy = 0.5 * innerdiameter + 0.5 * width + (i - 1) * (width + spacing)
        pathpts:append(point.create( xy + 0.00 * (width + spacing), -xy + 0.00 * (width + spacing)))
        pathpts:append(point.create( xy + 0.00 * (width + spacing),  xy + 0.50 * (width + spacing)))
        pathpts:append(point.create(-xy - 0.50 * (width + spacing),  xy + 0.50 * (width + spacing)))
        pathpts:append(point.create(-xy - 0.50 * (width + spacing), -xy - 1.00 * (width + spacing)))
    end
    return layout.path_midpoint("lastmetal", "drawing", pathpts, width, "halfangle", true)
end
