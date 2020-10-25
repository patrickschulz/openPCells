-- for random shuffle
math.randomseed(os.time())

local techlib = _load_module("technology")
local interface = _load_module("interface")

-- parse command line arguments
local argparse = _load_module("argparse")
local args = argparse.parse(arg)
-- prepare cell arguments
local cellargs = {}
for k, v in string.gmatch(table.concat(args.cellargs, " "), "(%w+)%s*=%s*(%S+)") do
    cellargs[k] = v
end

if not args.cell then
    error("no cell type given", 0)
end

-- output cell parameters
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell)
    print(table.concat(params, sep))
    os.exit(0)
end

if not args.technology then
    error("no technology given", 0)
end
if not args.interface then
    error("no interface given", 0)
end

local tech = techlib.load(args.technology)
interface.load(args.interface)

local cell, msg = pcell.create_layout(args.cell, cellargs, true)
if not cell then
    error(string.format("error while creating cell, received: %s", msg), 0)
end
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then 
        error(string.format("could not parse origin (%s)", args.origin), 0)
    end
    cell:translate(dx, dy)
end

local techintf = args.interface
if not args.notech then
    techlib.translate_metals(cell)
    techlib.split_vias(cell)
    techlib.place_via_conductors(cell, techintf)
    techlib.translate(cell, techintf)
    techlib.fix_to_grid(cell)
end

local filename = args.filename or "openPCells"
interface.set_options(args.interface_options)
interface.write_cell(filename, cell)

-- vim: ft=lua
