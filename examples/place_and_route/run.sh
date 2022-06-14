#! /bin/sh

../../opc --import-verilog place_route_generate.lua
../../opc --technology opc --export gds --cell verilogimport/inverter_chain --cellpath verilogimport
