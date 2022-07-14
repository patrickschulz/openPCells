* Created by KLayout

* cell cinv
* pin I
* pin EN,EP
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT cinv 1 2 3 4 5 9
* net 1 I
* net 2 EN,EP
* net 3 O
* net 4 VDD
* net 5 VSS
* net 9 SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 3 1 7 6 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 7 2 4 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $3 r0 *1 -0.25,-1.2 slvtnfet
M$3 3 1 8 9 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $4 r0 *1 0.25,-1.2 slvtnfet
M$4 8 2 5 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS cinv
