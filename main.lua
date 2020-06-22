local scripthome = "/home/patrick/Workspace/lua/pcells"

package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local point = require "point"
local graphics = require "graphics"
local pointarray = require "pointarray"
local shape = require "shape"
local object = require "object"
local layout = require "layout"
local virtuoso = require "virtuoso"

local R = tonumber(arg[1]) or 40.0
local r = tonumber(arg[2]) or 14.0
local width = tonumber(arg[3]) or 6.0
local sep = tonumber(arg[4]) or 6.0
local grid = tonumber(arg[5]) or 0.1

local shape = shape.create("QB", "drawing")
shape:add_point(point.create(0, 0))
shape:add_point(point.create(1, 0))
shape:add_point(point.create(1, 1))
shape:close()

local obj = object.create()
obj:add_shape(shape)
obj:add_shape(shape)
virtuoso.register_filename_generation_func(function() return "testpoints" end)
virtuoso.print_object(obj)
