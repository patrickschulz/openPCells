#! /bin/sh

CELL=command_reg

#../../opc --import-verilog place_route_generate.lua ${CELL}
../../opc --technology opc --export gds --cell verilogimport/${CELL} --cellpath verilogimport
