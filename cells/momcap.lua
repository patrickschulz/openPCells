local point = require "point"
local object = require "object"
local layout = require "layout"

return function()
    -- momcap settings
    local fingers = 4
    local fwidth = 0.1
    local fspace = 0.1
    local fheight = 1
    local foffset = 0.1
    local rwidth = 0.1

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
            origin, 
            fwidth, fheight, 
            { 
                xrep = fingers + 1, 
                xpitch = 2 * pitch,
                yoffset = 0.5 * foffset
            }
        ))
        momcap:add_shape(layout.rectangle(
            string.format("M%d", i), "drawing", 
            origin, 
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
            origin, 
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
