* Created by KLayout

* cell isogate
* pin SUBSTRATE
.SUBCKT isogate 6
* net 6 SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 1 1 4 3 slvtpfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 2 2 5 6 slvtnfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
.ENDS isogate
