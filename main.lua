local virtuoso = require "interface.virtuoso"
local cell = require "cell"

local cellname = arg[1]
local cellargs = {}
for i = 2, #arg do
    cellargs[i - 1] = arg[i]
end

local cell = cell.create(cellname, cellargs)

if not cell then
    os.exit(42)
end

local layermap = require "layermaps.cmos22fdsoi"
virtuoso.register_layermap(layermap)
virtuoso.register_filename_generation_func(function() return "openPCells.points" end)
virtuoso.print_object(cell)

-- signal success
os.exit(0)
