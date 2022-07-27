#!/bin/bash
FILENAMES=`cd ../cells/stdcells/ && ls *.lua`
OUTPUTPATH="spice/stdcells"

for FILE in $FILENAMES
do
    (cd .. &&
    ./opc --technology opc --export gds --cell /stdcells/${FILE%.lua} &&
    klayout openPCells.gds -rd filename=${FILE%.lua}.sp -z -n opc -r ressources/opc.lylvs &&
    sed -i "s/opctoplevel/${FILE%.lua}/" *.sp &&
    mv *.sp $OUTPUTPATH)
done
