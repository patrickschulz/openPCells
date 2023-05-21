#! /bin/sh

CELL=command_reg

../../opc --import-verilog place_route_generate.lua ${CELL}
../../opc --technology GF22FDSOI --export gds --cellscript generate_cell.lua --cellpath verilogimport ${CELL}
