local module = "counter"
local exporttype = "gds"

local netlist = verilog.read_parse_file(string.format("examples/place_and_route/%s.v", module))

verilog.filter_excluded_nets(netlist, { "clk", "_mem.clk", "vdd", "vss", "in", "out", })

local instances, nets = verilogprocessor.collect_nets_cells(netlist)

--[[
for _, instance in ipairs(instances) do
    print(string.format("instance:   %s", instance.instance))
    print(string.format("reference:  %s", instance.reference))
    print(string.format("width:      %d", instance.width))
    print("nets:")
    for _, net in ipairs(instance.nets) do
        print(string.format("    { name = %s, port = %s }", net.name, net.port))
    end
    io.write(string.format("pinoffsets: { "))
    for k, v in pairs(instance.pinoffsets) do
        io.write(string.format("%s = %d, ", k, v))
    end
    print("}")
    print()
end
--]]

local rows = placement.optimize(instances, nets, 0.5, 1)

--local routes = routing.legalize(nets, rows)

local filename = generator.get_cell_filename("verilogimport", "verilogimport", module)
print(string.format("writing to file '%s'", filename))
local file = io.open(filename, "w")
generator.digital(file, rows, routes)
file:close()

--[[
-- generate layout
technology.add_techpath(string.format("%s/tech", _get_opc_home()))
technology.load("freePDK45")
pcell.append_cellpath(string.format("%s/%s", _get_opc_home(), "cells"))
pcell.append_cellpath("verilogimport")
local cellargs = {}
local cell = pcell.create_layout(string.format("verilogimport/%s", module), cellargs, nil, true) -- nil: no environment, true: evaluate parameters

technology.translate(cell, exporttype)

export.add_path(string.format("%s/export", _get_opc_home()))
export.load(exporttype)
export.write_toplevel("openPCells", "freePDK45", cell, "opctoplevel")
--]]
