* Created by KLayout

* cell not_gate
* pin VSS
* pin VDD
* pin I
* pin O
* pin SUBSTRATE
.SUBCKT not_gate VSS VDD I O SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD I O \$4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 O VDD VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $3 r0 *1 0,-1.2 slvtnfet
M$3 VSS I O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $4 r0 *1 0.5,-1.2 slvtnfet
M$4 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS not_gate
