#! /bin/sh

# args:
# 1: basename
# 2: cellname
# 3: export type
function do_test()
{
    ../../opc --export ${3} --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -ne 0 ]; then
        echo
        ../../opc --export ${3} --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1}
    fi
    if ../helpers/test_compare ${1} ${3}; then
        printf "\033[1;32mtest succeeded: %s (%s)\n\033[0m" ${1} ${2}
    else
        printf "\033[1;31mtest failed: %s (%s)\n\033[0m" ${1} ${2}
        echo
    fi
}

# cmos 01
do_test cmos_01 basic/cmos gds

# diode 01
do_test diode_01 basic/diode gds

# guardring 01
do_test guardring_01 auxiliary/guardring gds
# guardring 02
do_test guardring_02 auxiliary/guardring gds

# ldmos 01
do_test ldmos_01 basic/ldmos gds

# mosfet 01
do_test mosfet_01 basic/mosfet gds
# mosfet 02
do_test mosfet_02 basic/mosfet gds

# polyresistor 01
do_test polyresistor_01 basic/polyresistor gds

# stacked_mosfet_array 01
do_test stacked_mosfet_array_01 basic/stacked_mosfet_array gds
