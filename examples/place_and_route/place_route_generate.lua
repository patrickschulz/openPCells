local module = "register_cell"
local exporttype = "gds"

local netlist = verilog.read_parse_file(string.format("%s.v", module))

verilog.filter_excluded_nets(netlist, { "clk", "_mem.clk", "vdd", "vss", "in", "out", })

local cellinfo = verilogprocessor.read_cellinfo_from_file("cellinfo.lua")
local instances, nets = verilogprocessor.collect_nets_cells(netlist, cellinfo)

local floorplan = placement.create_floorplan_fixed_rows(instances, 0.5, 2)
local rows = placement.optimize(instances, nets, floorplan)
placement.insert_filler_names(rows, floorplan.floorplan_width)

--FIXME: hardoded number of routing tracks per cell
local numtracks = 9
local routes = routing.legalize(nets, rows, numtracks, floorplan, instances)

local filename = generator.get_cell_filename("verilogimport", "verilogimport", module)
print(string.format("writing to file '%s'", filename))
local file = io.open(filename, "w")
generator.digital(file, rows, routes, numtracks)
file:close()
