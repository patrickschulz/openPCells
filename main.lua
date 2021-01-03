-- for random shuffle
math.randomseed(os.time())

-- load user configuration
config.get_user_config()

local techlib = _load_module("technology")
local interface = _load_module("interface")

-- parse command line arguments
local argparse = _load_module("argparse")
local args = argparse.parse(arg)

-- list available cells
if args.listcells then
    support.listcells("cells")
    os.exit(0)
end

if not args.cell then
    error("no cell type given")
end

-- prepare cell arguments
local cellargs = {}
for k, v in string.gmatch(table.concat(args.cellargs, " "), "([%w/._]+)%s*=%s*(%S+)") do
    cellargs[k] = v
end

-- output cell parameters
if args.params then
    local sep = args.separator or "\n"
    local params = pcell.parameters(args.cell)
    io.write(table.concat(params, sep) .. sep)
    os.exit(0)
end

if not args.notech and not args.technology then
    error("no technology given")
end
if not args.interface then
    error("no interface given")
end

if not args.notech then
    techlib.load(args.technology)
end
interface.load(args.interface)

local cell, msg = pcell.create_layout(args.cell, cellargs, true)
if not cell then
    error(string.format("error while creating cell, received: %s", msg))
end

-- move origin
if args.origin then
    local dx, dy = string.match(args.origin, "%(%s*([-%d]+)%s*,%s*([-%d]+)%s*%)")
    if not dx then
        error(string.format("could not parse origin (%s)", args.origin))
    end
    cell:translate(dx, dy)
end

-- orientation
if args.orientation then
    local lut = {
        ["0"] = function() end, -- do nothing
        ["fx"] = function() cell:flipx() end,
        ["fy"] = function() cell:flipy() end,
        ["fxy"] = function() cell:flipx(); cell:flipy() end,
    }
    local f = lut[args.orientation]
    if not f then
        error(string.format("unknown orientation: %s", args.orientation))
    end
    f()
end

local techintf = interface.get_techinterface() or args.interface
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
