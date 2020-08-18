local function _loader(name)
    local filename = string.format("%s/%s.lua", path, name)
    local module = dofile(filename)
    return module
end

-- load API into global space
object     = _loader("object")
shape      = _loader("shape")
point      = _loader("point")
geometry   = _loader("geometry")
graphics   = _loader("graphics")
pcell      = _loader("pcell")
generics   = _loader("generics")
bitop      = _loader("bitop")
celllib    = _loader("cell")
util       = _loader("util")

local techlib = _loader("technology")
local interface = _loader("interface")

-- parse command line arguments
local argparse = _loader("argparse")
local args = argparse.parse(arg)
-- prepare cell arguments
local cellargs = {}
for k, v in string.gmatch(table.concat(args.cellargs, " "), "(%w+)%s*=%s*(%S+)") do
    cellargs[k] = v
end

if not args.cell then
    print("no cell type given")
    os.exit(1)
end

-- output cell parameters
if args.params then
    print("params") 
    os.exit(0)
end

if not args.technology then
    print("no technology given")
    os.exit(1)
end
if not args.interface then
    print("no interface given")
    os.exit(1)
end

techlib.load(args.technology)
interface.load(args.interface)

local cell, msg = celllib.create_layout(args.cell, cellargs)

if not cell then
    print(string.format("error while creating cell, received: %s", msg))
    os.exit(1)
end

techlib.translate_metals(cell)
techlib.split_vias(cell)
techlib.create_via_geometries(cell)
techlib.map_layers(cell)
techlib.fix_to_grid(cell)

local filename = args.filename or "openPCells"
interface.write_cell(filename, cell)

-- vim: ft=lua
