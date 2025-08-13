#! /bin/sh

../../opc --technology opc --export gds --cellscript mosfet.lua --filename mosfet
../../opc --technology opc --export gds --cellscript ringoscillator.lua --filename ringoscillator
../../opc --technology opc --export gds --cellscript stacked_ringoscillator.lua --filename stacked_ringoscillator --enable-fallback-vias
../../opc --technology opc --export gds --cellscript current_starved_ringoscillator.lua --filename current_starved_ringoscillator --enable-dprint
../../opc --technology opc --export gds --cellscript comparator.lua --filename comparator
../../opc --technology opc --export gds --cellscript LC_oscillator.lua --filename LC_oscillator --enable-fallback-vias
../../opc --technology opc --export gds --cellscript ldmos.lua --filename ldmos
