-- for random shuffle
math.randomseed(os.time())

-- load user configuration
config.get_user_config()

local techlib = _load_module("technology")
local interface = _load_module("interface")

-- parse command line arguments
local argparse = _load_module("argparse")
local args = argparse.parse(arg)

-- profiler
local histo = {}
local info = {}
if args.profile then
    local logcall = function(...)
        local callinfo = debug.getinfo(1)
        local funcinfo = debug.getinfo(2)
        local name = funcinfo.name
        local namewhat = funcinfo.namewhat
        if name then
            if not histo[name] then 
                histo[name] = 0 
            end
            if not info[name] then
                print(callinfo.namewhat)
                info[name] = {
                    source = funcinfo.source
                }
            end
            histo[name] = histo[name] + 1
        end
    end
    debug.sethook(logcall, "c")
end

-- list available cells
if args.listcells then
    pcell.list()
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
interface.write_cell(filename, cell, args.dryrun)

-- remove profiler hook
debug.sethook()

if args.profile then
    local sorted = {}
    for k, v in pairs(histo) do
        table.insert(sorted, { name = k, count = v })
    end
    table.sort(sorted, function(lhs, rhs) return lhs.count < rhs.count end)
    for _, entry in ipairs(sorted) do
        print(string.format("%30s %15s: %5d", entry.name, "(" .. info[entry.name].source .. ")", entry.count))
    end
end

-- vim: ft=lua
