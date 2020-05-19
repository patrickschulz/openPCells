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

local pts = layout.symmetric_inductor(R, r, width, sep, grid)

virtuoso.print_points(pts)
