local point = require "point"
local object = require "object"
local layout = require "layout"

return function(args)
    -- momcap settings
    local fingers   = args.fingers  or 4
    local fwidth    = args.fwidth   or 0.1
    local fspace    = args.fspace   or 0.1
    local fheight   = args.fheight  or 1
    local foffset   = args.foffset  or 0.1
    local rwidth    = args.rwidth   or 0.1

    -- derived settings
    local pitch = fwidth + fspace

    local momcap = object.create()

    local origin = point.create(0, 0)

    -- fingers
    local firstmetal = 1
    local lastmetal = 3
    for i = firstmetal, lastmetal do
        momcap:add_shape(layout.rectangle(
            string.format("M%d", i), "drawing", 
            fwidth, fheight, 
            { 
                xrep = fingers + 1, 
                xpitch = 2 * pitch,
                yoffset = 0.5 * foffset
            }
        ))
        momcap:add_shape(layout.rectangle(
            string.format("M%d", i), "drawing", 
            fwidth, fheight, 
            { 
                xrep = fingers, 
                xpitch = 2 * pitch,
                yoffset = -0.5 * foffset
            }
        ))
        -- rails
        momcap:add_shape(layout.rectangle(
            string.format("M%d", i), "drawing", 
            (2 * fingers + 1) * (fwidth + fspace), rwidth,
            { 
                yrep = 2,
                ypitch = 2 * foffset + fheight
            }
        ))
    end
    for i = firstmetal, lastmetal - 1 do
        local vias = layout.via(
            string.format("M%d->M%d", i, i + 1),
            (2 * fingers + 1) * (fwidth + fspace), rwidth,
            { 
                yrep = 2,
                ypitch = 2 * foffset + fheight
            }
        )
        for _, s in ipairs(vias) do
            momcap:add_shape(s)
        end
    end

    return momcap
end
