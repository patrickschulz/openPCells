local module = "counter"
local exporttype = "gds"

local netlist = verilog.read_parse_file(string.format("examples/place_and_route/%s.v", module))

verilog.filter_excluded_nets(netlist, { "clk", "_mem.clk", "vdd", "vss", "in", "out", })

local instances, nets = verilogprocessor.collect_nets_cells(netlist)

local rows = placement.optimize(instances, nets, 0.5, 1)

local routes = routing.legalize(nets, rows)

local filename = generator.get_cell_filename("verilogimport", "verilogimport", module)
print(string.format("writing to file '%s'", filename))
local file = io.open(filename, "w")
generator.digital(file, rows, routes)
file:close()
