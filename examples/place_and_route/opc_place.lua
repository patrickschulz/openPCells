local module = "counter"
local exporttype = "gds"

local netlist = verilog.read_parse_file(string.format("examples/place_and_route/%s.v", module))

verilog.filter_excluded_nets(netlist, { "clk", "_mem.clk", "vdd", "vss", "in", "out", })

local instances, nets = verilogprocessor.collect_nets_cells(netlist)

local rows, options = placement.optimize(instances, nets, 0.5, 1)

local routes = routing.legalize(nets, rows, options)

local filename = generator.get_cell_filename("verilogimport", "verilogimport", module)
print(string.format("writing to file '%s'", filename))
local file = io.open(filename, "w")
generator.digital(file, rows, routes)
file:close()

-- generate layout
technology.add_techpath(string.format("%s/tech", _get_opc_home()))
technology.load("GF22FDSOI")
pcell.append_cellpath(string.format("%s/%s", _get_opc_home(), "cells"))
pcell.append_cellpath("verilogimport")
local cellargs = {}
local cell = pcell.create_layout(string.format("verilogimport/%s", module), cellargs, nil, true) -- nil: no environment, true: evaluate parameters

export.add_path(string.format("%s/export", _get_opc_home()))
export.load(exporttype)
export.write_toplevel("openPCells", "GF22FDSOI", cell, "opctoplevel")

--local module = "counter"
--local exporttype = "gds"
--
--local content = generator.from_verilog(
--    string.format("%s.v", module), -- verilog file to be read
--    0.5, -- utilization
--    1, -- aspect ratio
--    { "clk", "_mem.clk", "vdd", "vss", "in", "out", }, -- excluded nets
--    false -- report
--)
--generator.write_from_verilog(content, "verilogimport", "verilogimport")
--
--technology.add_techpath(string.format("%s/tech", _get_opc_home()))
--technology.load("freePDK45")
--pcell.append_cellpath(string.format("%s/%s", _get_opc_home(), "cells"))
--pcell.append_cellpath("verilogimport")
--local cellargs = {}
--local cell = pcell.create_layout(string.format("verilogimport/%s", module), cellargs, nil, true) -- nil: no environment, true: evaluate parameters
--
--technology.translate(cell, exporttype)
--
--export.add_path(string.format("%s/export", _get_opc_home()))
--export.load(exporttype)
--export.write_toplevel("openPCells", "freePDK45", cell, "opctoplevel")

