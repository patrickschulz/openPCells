#! /bin/sh

commonargs="--write-children-ports --flatten-ports"
opcexec="../../opc"

# args:
# 1: basename
# 2: cellname
# 3: export type
function do_cell_test()
{
    if [ ! -f pfile_${1}.lua ]; then
        printf "\033[1;31mpfile 'pfile_%s.lua' does not exist: test %s (%s)\n\033[0m" ${1} ${1} ${2}
        return
    fi
    if [ ! -x ${opcexec} ]; then
        printf "\033[1;31mopc is not available: test %s (%s)\n\033[0m" ${1} ${2}
        return
    fi
    ${opcexec} ${commonargs} --export ${3} --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -ne 0 ]; then
        echo
        ${opcexec} ${commonargs} --export ${3} --technology opc --cell ${2} --pfile pfile_${1}.lua --filename test_${1}
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
# 4: extra arguments
function do_cellscript_test()
{
    if [ ! -x ${opcexec} ]; then
        printf "\033[1;31mopc is not available: test %s (%s)\n\033[0m" ${1} ${2}
        return
    fi
    ${opcexec} ${commonargs} ${4} --export ${3} --technology opc --cellscript ${2} --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -ne 0 ]; then
        echo
        ${opcexec} ${commonargs} ${4} --export ${3} --technology opc --cellscript ${2} --filename test_${1}
    fi
    if ../helpers/test_compare ${1} ${3}; then
        printf "\033[1;32mcellscript test succeeded: %s (%s)\n\033[0m" ${1} ${2}
    else
        printf "\033[1;31mcellscript test failed: %s (%s)\n\033[0m" ${1} ${2}
        echo
    fi
}

# args:
# 1: basename
# 2: cellscript filename
# 3: export type
# 4: extra arguments
function do_cellscript_failtest()
{
    if [ ! -x ${opcexec} ]; then
        printf "\033[1;31mopc is not available: test %s (%s)\n\033[0m" ${1} ${2}
        return
    fi
    ${opcexec} ${commonargs} ${4} --export ${3} --technology opc --cellscript ${2} --filename test_${1} --stdout-to /dev/null --stderr-to /dev/null
    if [ $? -eq 0 ]; then
        printf "\033[1;31mcellscript fail test failed (cellscript should raise an error): %s (%s)\n\033[0m" ${1} ${2}
        echo
    else
        printf "\033[1;32mcellscript fail test succeeded: %s (%s)\n\033[0m" ${1} ${2}
    fi
}

#######################################################
# Every cell test should have an '_00' test
# with an empty pfile ('return {}')
#######################################################

# tech/via test
do_cellscript_test cellscript_tech_vias cellscript_tech_vias.lua gds

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
do_cellscript_test cellscript_mosfet_01 cellscript_mosfet_01.lua gds
do_cell_test mosfet_00 basic/mosfet gds
do_cell_test mosfet_01 basic/mosfet gds
do_cell_test mosfet_02 basic/mosfet gds
do_cell_test mosfet_03 basic/mosfet gds
do_cell_test mosfet_04 basic/mosfet gds
do_cell_test mosfet_05 basic/mosfet gds
do_cell_test mosfet_06 basic/mosfet gds
do_cell_test mosfet_07 basic/mosfet gds
do_cell_test mosfet_08 basic/mosfet gds
do_cell_test mosfet_09 basic/mosfet gds
do_cell_test mosfet_10 basic/mosfet gds
do_cell_test mosfet_11 basic/mosfet gds
do_cell_test mosfet_12 basic/mosfet gds
do_cell_test mosfet_13 basic/mosfet gds
do_cell_test mosfet_14 basic/mosfet gds
do_cell_test mosfet_15 basic/mosfet gds

# polyresistor
do_cell_test polyresistor_01 basic/polyresistor gds
do_cell_test polyresistor_02 basic/polyresistor gds
do_cell_test polyresistor_03 basic/polyresistor gds
do_cell_test polyresistor_04 basic/polyresistor gds
do_cell_test polyresistor_05 basic/polyresistor gds
do_cell_test polyresistor_06 basic/polyresistor gds
do_cell_test polyresistor_07 basic/polyresistor gds
do_cell_test polyresistor_08 basic/polyresistor gds
do_cell_test polyresistor_09 basic/polyresistor gds
do_cell_test polyresistor_10 basic/polyresistor gds
do_cell_test polyresistor_11 basic/polyresistor gds
do_cell_test polyresistor_12 basic/polyresistor gds
do_cell_test polyresistor_13 basic/polyresistor gds
do_cell_test polyresistor_14 basic/polyresistor gds

# inverter
do_cell_test inverter_01 analog/inverter gds
do_cell_test inverter_02 analog/inverter gds

# inverter chain
do_cell_test inverter_chain_00 analog/inverter_chain gds
do_cell_test inverter_chain_01 analog/inverter_chain gds

# common centroid
do_cell_test common_centroid_01 analog/common_centroid gds
do_cell_test common_centroid_02 analog/common_centroid gds
do_cell_test common_centroid_03 analog/common_centroid gds
do_cell_test common_centroid_04 analog/common_centroid gds
do_cell_test common_centroid_05 analog/common_centroid gds
do_cellscript_test cellscript_common_centroid_01 cellscript_common_centroid_01.lua gds
do_cellscript_test cellscript_common_centroid_02 cellscript_common_centroid_02.lua gds
do_cellscript_test cellscript_common_centroid_03 cellscript_common_centroid_03.lua gds
do_cellscript_test cellscript_common_centroid_04 cellscript_common_centroid_04.lua gds
do_cellscript_test cellscript_common_centroid_05 cellscript_common_centroid_05.lua gds
#do_cellscript_test cellscript_common_centroid_06 cellscript_common_centroid_06.lua gds
do_cellscript_test cellscript_common_centroid_07 cellscript_common_centroid_07.lua gds
do_cellscript_test cellscript_common_centroid_08 cellscript_common_centroid_08.lua gds

# stacked_mosfet_array
do_cell_test stacked_mosfet_array_01 basic/stacked_mosfet_array gds

# simple cellscript test (for name)
do_cellscript_test cellscript_name cellscript_name.lua gds

# cellscript test for object:flatten_inline()
do_cellscript_test cellscript_flatten cellscript_flatten.lua gds

# cellscript test for object hierarchies with translations
do_cellscript_test cellscript_hierarchy cellscript_hierarchy.lua gds

# cellscript test for object anchors
do_cellscript_test cellscript_anchor cellscript_anchor.lua gds --draw-all-anchors

# cellscript test for ports
do_cellscript_test cellscript_port cellscript_port.lua gds

# cellscript test for transformation corrections
do_cellscript_test cellscript_transformation_correction cellscript_transformation_correction.lua gds

# cellscript test for automatic line/via placement
do_cellscript_test cellscript_line_place_via cellscript_line_place_via.lua gds

# power lines placement test
do_cellscript_test cellscript_powerlines cellscript_powerlines.lua gds

# cellscript test for bounding box
do_cellscript_test cellscript_bounding_box cellscript_bounding_box.lua gds

# cellscript test for overlap vias
do_cellscript_test cellscript_overlap_via cellscript_overlap_via.lua gds
do_cellscript_failtest cellscript_overlap_via cellscript_overlap_via_fail.lua gds

# cell test for analog/cascode
do_cell_test cascode_01 analog/cascode gds

# cell test for analog/moscap
do_cell_test moscap_01 analog/moscap gds
do_cell_test moscap_02 analog/moscap gds
do_cell_test moscap_03 analog/moscap gds
do_cell_test moscap_04 analog/moscap gds

# cell test for analog/cross_coupled_pair
do_cell_test cross_coupled_pair_01 analog/cross_coupled_pair gds

# cell test for analog/currentmirror
do_cell_test currentmirror_00 analog/currentmirror gds
do_cell_test currentmirror_01 analog/currentmirror gds
do_cell_test currentmirror_02 analog/currentmirror gds

# cell test for analog/self_biased_inverter
do_cell_test self_biased_inverter_00 analog/self_biased_inverter gds

# cell test for analog/transmission_gate
do_cell_test transmission_gate_00 analog/transmission_gate gds

# cell test for analog/vertical_inverter
do_cell_test vertical_inverter_00 analog/vertical_inverter gds

# test for label size
do_cellscript_test cellscript_labeltest cellscript_labeltest.lua gds

# basic tests for cells/analog
