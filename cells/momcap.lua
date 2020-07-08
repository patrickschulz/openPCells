local scripthome = "/home/pschulz/path/"
package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

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
    momcap:add_shape(layout.rectangle(
        "M1", "drawing", 
        origin, 
        fwidth, fheight, 
        { 
            xrep = fingers + 1, 
            xpitch = 2 * pitch,
            yoffset = 0.5 * foffset
        }
    ))
    momcap:add_shape(layout.rectangle(
        "M1", "drawing", 
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
        "M1", "drawing", 
        origin, 
        (2 * fingers + 1) * (fwidth + fspace), rwidth,
        { 
            yrep = 2,
            ypitch = 2 * foffset + fheight
        }
    ))

    return momcap
end
