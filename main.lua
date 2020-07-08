local virtuoso = require "interface.virtuoso"
local cell = require "cell"

local cellname = arg[1]

local cell = cell.create(cellname)

if not cell then
    os.exit(1)
end

local layermap = require "layermap"
virtuoso.register_layermap(layermap)
virtuoso.register_filename_generation_func(function() return "testpoints" end)
virtuoso.print_object(cell)

-- signal success
os.exit(0)
