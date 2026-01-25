if [ ! $# -gt 0 ]; then
    echo "no test name given"
    exit 1
fi
if [ ! $# -gt 1 ]; then
    echo "no command given, can be 'diff' or 'update'"
    exit 1
fi

if [ $2 = "diff" ]; then
    testfile=$(mktemp)
    reffile=$(mktemp)
    ../../opc --show-gds-data test_$1.gds > ${testfile}
    ../../opc --show-gds-data reference_$1.gds > ${reffile}
    vim -d ${testfile} ${reffile}
    rm ${testfile}
    rm ${reffile}
fi

if [ $2 = "update" ]; then
    cp test_$1.gds reference_$1.gds
fi

