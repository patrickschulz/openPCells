#!/bin/bash

#if [ -z "$1" ]; then
#    echo "no cell name supplied"
#    exit
#fi
#file=$1

file=openPCells
technology=cmos22fdsoi
interface=svg
cell=transistor

cmd="./opc -T $technology -I $interface -C $cell -f $file"

if [[ ! -f ${file}.${interface} ]]; then
    $cmd
fi

while true
do
    ATIME=$(stat -c %Z cells/${cell}.lua)
    if [[ "$ATIME" != "$LTIME" ]]
    then
        $cmd
        LTIME=$ATIME
    fi
    sleep 2
done
