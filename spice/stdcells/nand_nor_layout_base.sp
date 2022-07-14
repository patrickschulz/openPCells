* Created by KLayout

* cell nand_nor_layout_base
* pin SUBSTRATE
.SUBCKT nand_nor_layout_base 8
* net 8 SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 2 3 4 6 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 4 5 2 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 2 2 2 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $4 r0 *1 -0.25,-1.2 slvtnfet
M$4 1 3 7 8 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $5 r0 *1 0.25,-1.2 slvtnfet
M$5 7 5 4 8 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 0.75,-1.2 slvtnfet
M$6 4 1 1 8 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS nand_nor_layout_base
