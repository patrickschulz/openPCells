* Created by KLayout

* cell not_gate
* pin SUBSTRATE
.SUBCKT not_gate 6
* net 6 SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 2 3 5 4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 5 2 2 4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $3 r0 *1 0,-1.2 slvtnfet
M$3 1 3 5 6 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $4 r0 *1 0.5,-1.2 slvtnfet
M$4 5 1 1 6 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS not_gate
