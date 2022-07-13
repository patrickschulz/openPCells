* Created by KLayout

* cell opctoplevel
* pin SUBSTRATE
.SUBCKT opctoplevel 7
* net 7 SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 4 1 3 2 slvtpfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 6 1 5 7 slvtnfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
.ENDS opctoplevel
