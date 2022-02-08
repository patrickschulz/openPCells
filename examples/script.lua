local module = "counter"
local exporttype = "gds"

local content = generator.from_verilog(
    string.format("%s.v", module), -- verilog file to be read
    0.5, -- utilization
    1, -- aspect ratio
    { "clk", "_mem.clk", "vdd", "vss", "in", "out", }, -- excluded nets
    false -- report
)
generator.write_from_verilog(content, "verilogimport", "verilogimport")

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
