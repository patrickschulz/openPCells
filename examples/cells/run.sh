#! /bin/sh

../../opc --technology opc --export gds --cellscript mosfet.lua --filename mosfet
../../opc --technology opc --export gds --cellscript ringoscillator.lua --filename ringoscillator
../../opc --technology opc --export gds --cellscript comparator.lua --filename comparator
