#! /bin/sh

cd examples/place_and_route/
../../opc --import-verilog place_route_generate.lua
../../opc --technology opc --export gds --cell verilogimport/register_cell --cellpath verilogimport
