package.path = package.path .. ";/home/pschulz/path/?.lua"

local point = require "point"
local graphics = require "graphics"
local pointarray = require "pointarray"
local layout = require "layout"
local virtuoso = require "virtuoso"

local pts = layout.symmetric_inductor(20, 10, 6, 6, 1)

virtuoso.print_points(pts)
