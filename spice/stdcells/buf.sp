* Created by KLayout

* cell buf
* pin VSS
* pin VDD
* pin I
* pin O
* pin SUBSTRATE
.SUBCKT buf VSS VDD I O SUBSTRATE
* device instance $1 r0 *1 -0.75,1.2 slvtpfet
M$1 VDD I \$5 \$4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.25,1.2 slvtpfet
M$2 \$5 VDD VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.25,1.2 slvtpfet
M$3 VDD \$5 O \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.75,1.2 slvtpfet
M$4 O VDD VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $5 r0 *1 -0.75,-1.2 slvtnfet
M$5 VSS I \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $6 r0 *1 -0.25,-1.2 slvtnfet
M$6 \$5 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 0.25,-1.2 slvtnfet
M$7 VSS \$5 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 0.75,-1.2 slvtnfet
M$8 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS buf
