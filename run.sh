#! /bin/sh

opc --import-verilog examples/place_and_route/place_route_generate.lua
opc --technology opc --export gds --cell verilogimport/counter --cellpath verilogimport
