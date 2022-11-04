#! /bin/sh

../../opc --import-verilog place_route_generate.lua
../../opc --technology opc --export gds --cell verilogimport/multinet --cellpath verilogimport
