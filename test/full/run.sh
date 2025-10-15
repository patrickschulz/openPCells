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

# cmos
do_cell_test cmos_01 basic/cmos gds

# diode
do_cell_test diode_01 basic/diode gds

# guardring
do_cell_test guardring_01 auxiliary/guardring gds
do_cell_test guardring_02 auxiliary/guardring gds

# ldmos
do_cell_test ldmos_01 basic/ldmos gds

# mosfet
do_cell_test mosfet_01 basic/mosfet gds
do_cell_test mosfet_02 basic/mosfet gds
do_cell_test mosfet_03 basic/mosfet gds
do_cell_test mosfet_04 basic/mosfet gds
do_cell_test mosfet_05 basic/mosfet gds
do_cell_test mosfet_06 basic/mosfet gds
do_cell_test mosfet_07 basic/mosfet gds
do_cell_test mosfet_08 basic/mosfet gds
do_cell_test mosfet_09 basic/mosfet gds

# polyresistor
do_cell_test polyresistor_01 basic/polyresistor gds
do_cell_test polyresistor_02 basic/polyresistor gds
do_cell_test polyresistor_03 basic/polyresistor gds
do_cell_test polyresistor_04 basic/polyresistor gds
do_cell_test polyresistor_05 basic/polyresistor gds
do_cell_test polyresistor_06 basic/polyresistor gds

# stacked_mosfet_array
do_cell_test stacked_mosfet_array_01 basic/stacked_mosfet_array gds

# simple cellscript test (for name)
do_cellscript_test cellscript_name cellscript_name.lua gds
