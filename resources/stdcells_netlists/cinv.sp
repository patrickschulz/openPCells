* Created by KLayout

* cell cinv
* pin I
* pin EN
* pin EP
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT cinv I EN EP VDD VSS SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 \$5 I \$13 \$1 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$13 EP VDD \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $3 r0 *1 0,-1.2 slvtnfet
M$3 \$5 I \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $4 r0 *1 0.5,-1.2 slvtnfet
M$4 \$14 EN VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS cinv
