#! /bin/sh

function do_test()
{
    ../../opc --export debug --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -ne 0 ]; then
        echo
        ../../opc --export debug --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1}
    fi
    if ../helpers/test_compare ${1}; then
        printf "\033[1;32mtest succeeded: %s\n\033[0m" ${1}
    else
        printf "\033[1;31mtest failed: %s\n\033[0m" ${1}
        echo
    fi
}

# cmos 01
do_test cmos_01 basic/cmos

# diode 01
do_test diode_01 basic/diode

# guardring 01
do_test guardring_01 auxiliary/guardring

# ldmos 01
#do_test ldmos_01 basic/ldmos

# mosfet 01
do_test mosfet_01 basic/mosfet
# mosfet 02
do_test mosfet_02 basic/mosfet

# polyresistor 01
#do_test polyresistor_01 basic/polyresistor

# stacked_mosfet_array 01
do_test stacked_mosfet_array_01 basic/stacked_mosfet_array
