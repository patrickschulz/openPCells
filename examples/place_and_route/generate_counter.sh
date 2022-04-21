#! /bin/sh

../../opc --import-verilog place_route_generate.lua
../../opc --technology opc --export gds --cell verilogimport/counter --cellpath verilogimport
