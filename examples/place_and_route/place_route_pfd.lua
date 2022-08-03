local module = "pfd"
local exporttype = "gds"

local netlist = verilog.read_parse_file(string.format("%s.v", module))

verilog.filter_excluded_nets(netlist, { "reset", "clk", "update" })

local cellinfo = verilogprocessor.read_cellinfo_from_file("../../tech/opc/place_route/cellinfo.lua")
local ignorednets = {
    --"up", "down",
    "net1",
    "net2",
    "net3",
    "net4",
    "net5",
    "net6",
    "resetb",
    "reset",
}
local instances, nets = verilogprocessor.collect_nets_cells(netlist, cellinfo, ignorednets)

local utilization = 0.8
local numrows = 5
local floorplan = placement.create_floorplan_fixed_rows(instances, utilization, numrows)
local plan = {
    { "nor3", "nor4" },
    { "nor1", "nor2" },
    { "nandr", "notr" },
    { "nor5", "nor6" },
    { "nor7", "nor8" },
}
local rows = placement.manual(instances, plan)
placement.insert_filler_names(rows, floorplan.floorplan_width)

-- this value can be (at least in theory) changed in the generated layout, but the router assumes this many tracks
-- this means that reducing this value CAN work, but only increasing it will work certainly
local numtracks = 9
local routes = routing.legalize(nets, rows, numtracks, floorplan, instances)

local filename = generator.get_cell_filename("verilogimport", "verilogimport", module)
print(string.format("writing to file '%s'", filename))
local file = io.open(filename, "w")
generator.digital(file, rows, routes, numtracks)
file:close()
