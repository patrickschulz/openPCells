#!/bin/bash
OUTPUTPATH="."
FILENAME="register_cell"

(cd ../examples/place_and_route/ &&
    ./run.sh &&
    klayout openPCells.gds -rd filename=$FILENAME.sp -z -n opc -r ../../ressources/opc.lylvs &&
    sed -i "s/opctoplevel/${FILENAME}/" *.sp)
