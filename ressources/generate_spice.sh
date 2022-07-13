FILENAMES=`cd ../cells/stdcells/ && ls *.lua`

for FILE in $FILENAMES
do
    (cd .. &&
    ./opc --technology opc --export gds --cell /stdcells/${FILE%.lua} &&
    klayout openPCells.gds -rd filename=${FILE%.lua}.sp -z -n opc -r ressources/opc.lylvs &&
    mv *.sp spice/stdcells)
done
