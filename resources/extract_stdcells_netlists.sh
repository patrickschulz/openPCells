#!/bin/bash

FILENAMES=$(ls ../cells/stdcells/*.lua)
OUTPUTPATH="spice/stdcells"

mkdir -p ../${OUTPUTPATH}
for FILE in $FILENAMES
do
    cellname=$(basename ${FILE%.lua})
    (cd .. &&
    echo stdcells/${cellname}
    ./opc --technology opc --export gds --cell stdcells/${cellname} &&
    klayout openPCells.gds -rd filename=${cellname}.sp -z -nc -rx -n opc -r resources/opc.lylvs &&
    sed -i "s/opctoplevel/${cellname}/" *.sp &&
    mv *.sp $OUTPUTPATH
    )
done
