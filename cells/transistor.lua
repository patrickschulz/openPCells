local scripthome = "/home/pschulz/path/"
package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local point = require "point"
local shape = require "shape"
local object = require "object"
local layout = require "layout"
local virtuoso = require "interface.virtuoso"

-- transistor settings
local fingers = 4
local gatewidth = 1
local gatelength = 0.1
local gatepitch = 0.5
local activexoverlap = 0.2
local activeyoverlap = 0.0
local sdwidth = 0.1

local obj = object.create()

local origin = point.create(0, 0)

local gates = layout.rectangle_array("gate", "drawing", origin, gatelength, gatewidth, { xrep = fingers, xpitch = gatepitch })
local active = layout.rectangle("active", "drawing", origin, (fingers - 1) * gatepitch + gatelength + 2 * activexoverlap, gatewidth + 2 * activeyoverlap)
local sdmetals = layout.rectangle_array("firstmetal", "drawing", origin, sdwidth, gatewidth, { xrep = fingers + 1, xpitch = gatepitch })

obj:add_shape(gates)
obj:add_shape(active)
obj:add_shape(sdmetals)

virtuoso.print_object(obj)
