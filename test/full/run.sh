#! /bin/sh

# args:
# 1: basename
# 2: cellname
# 3: export type
function do_cell_test()
{
    if [ ! -x ../../opc ]; then
        printf "\033[1;31mopc is not available: test %s (%s)\n\033[0m" ${1} ${2}
        return
    fi
    ../../opc --export ${3} --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -ne 0 ]; then
        echo
        ../../opc --export ${3} --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1}
    fi
    if ../helpers/test_compare ${1} ${3}; then
        printf "\033[1;32mcell test succeeded: %s (%s)\n\033[0m" ${1} ${2}
    else
        printf "\033[1;31mcell test failed: %s (%s)\n\033[0m" ${1} ${2}
        echo
    fi
}

# args:
# 1: basename
# 2: cellscript filename
# 3: export type
function do_cellscript_test()
{
    if [ ! -x ../../opc ]; then
        printf "\033[1;31mopc is not available: test %s (%s)\n\033[0m" ${1} ${2}
        return
    fi
    ../../opc --export ${3} --technology opc --cellscript ${2} --pfile pfile_${1}.lua --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -ne 0 ]; then
        echo
        ../../opc --export ${3} --technology opc --cellscript ${2} --pfile pfile_${1}.lua --filename test_${1}
    fi
    if ../helpers/test_compare ${1} ${3}; then
        printf "\033[1;32mcellscript test succeeded: %s (%s)\n\033[0m" ${1} ${2}
    else
        printf "\033[1;31mcellscript test failed: %s (%s)\n\033[0m" ${1} ${2}
        echo
    fi
}

# cmos 01
do_cell_test cmos_01 basic/cmos gds

# diode 01
do_cell_test diode_01 basic/diode gds

# guardring 01
do_cell_test guardring_01 auxiliary/guardring gds
# guardring 02
do_cell_test guardring_02 auxiliary/guardring gds

# ldmos 01
do_cell_test ldmos_01 basic/ldmos gds

# mosfet 01
do_cell_test mosfet_01 basic/mosfet gds
# mosfet 02
do_cell_test mosfet_02 basic/mosfet gds

# polyresistor 01
do_cell_test polyresistor_01 basic/polyresistor gds

# stacked_mosfet_array 01
do_cell_test stacked_mosfet_array_01 basic/stacked_mosfet_array gds

# simple cellscript test (for name)
do_cellscript_test cellscript_name cellscript_name.lua gds
