local scripthomes = {
    "/home/patrick/Workspace/lua/pcells",
    "/home/pschulz/path"
}

for _, scripthome in ipairs(scripthomes) do
    package.path = package.path .. string.format(";%s/?.lua", scripthome) .. string.format(";%s/interface/?.lua", scripthome)
end

local virtuoso = require "virtuoso"
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
