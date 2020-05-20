local scripthome = "/home/pschulz/path"

package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local point = require "point"
local graphics = require "graphics"
local pointarray = require "pointarray"
local layout = require "layout"
local virtuoso = require "virtuoso"

local R = tonumber(arg[1]) or 40.0
local r = tonumber(arg[2]) or 14.0
local width = tonumber(arg[3]) or 6.0
local sep = tonumber(arg[4]) or 6.0
local grid = tonumber(arg[5]) or 0.1

local function symmetric_inductor(R, r, width, sep, grid)
    local x0 = 0
    local y0 = 0

    -- calculate center of auxiliary circle
    local xc = -0.5 * sep - r
    local yc = -grid * math.floor(math.sqrt((R + r)^2 - xc^2) / grid)

    -- ** Inner part **
    -- calculate meeting point
    local xm = x0 + xc * R / (r + R)
    local ym = y0 + yc * R / (r + R)

    local main  = graphics.quartercircle(3, x0, y0, R, grid)
    local aux   = graphics.quartercircle(1, xc, yc, r, grid)

    local inner = graphics.quartercircle(2, x0, y0, R, grid):reverse() -- start with topleft quarter circle
    inner:merge_append(main:filter_forward(function(pt) return pt.x < xm end))
    inner:merge_append(aux:filter_backward(function(pt) return pt.x >= xm end))
    -- mirror points and append
    inner:reverse_inline()
    inner:merge_append(inner:xmirror(0):reverse())

    -- ** Outer part **
    -- calculate meeting point
    xm = x0 + xc * (R + width) / (r + R)
    ym = y0 + yc * (R + width) / (r + R)

    main  = graphics.quartercircle(3, x0, y0, R + width, grid)
    aux   = graphics.quartercircle(1, xc, yc, r - width, grid)

    local outer = graphics.quartercircle(2, x0, y0, R + width, grid):reverse() -- start with topleft quarter circle
    outer:merge_append(main:filter_forward(function(pt) return pt.x < xm end))
    outer:merge_append(aux:filter_backward(function(pt) return pt.x >= xm end))
    -- mirror points and append
    outer:reverse_inline()
    outer:merge_append(outer:xmirror(0):reverse())

    -- ** assemble final path **
    local final = pointarray.create()
    final:merge_append(inner:reverse())
    final:merge_append(outer)

    final:close()

    return final
end


local pts = symmetric_inductor(R, r, width, sep, grid)

virtuoso.print_points(pts)
