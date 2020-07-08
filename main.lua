local scripthome = "/home/patrick/Workspace/lua/pcells"

package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)

local virtuoso = require "virtuoso"
local cell = require "cell"

local cell = cell.create("transistor")

local layermap = require "layermap"
virtuoso.register_layermap(layermap)
virtuoso.register_filename_generation_func(function() return "testpoints" end)
virtuoso.print_object(cell)

-- signal success
os.exit(0)
