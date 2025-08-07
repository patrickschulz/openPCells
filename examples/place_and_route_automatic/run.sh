#! /bin/sh

CELL=serial_ctrl

../../opc --import place_route_generate.lua ${CELL}
../../opc --technology GF22FDSOI --export gds --cellscript generate_cell.lua --cellpath verilogimport ${CELL}
