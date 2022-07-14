* Created by KLayout

* cell and_gate
* pin VSS
* pin VDD
* pin A
* pin B
* pin O
* pin SUBSTRATE
.SUBCKT and_gate VSS VDD A B O SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 VDD A \$4 \$6 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 \$4 B VDD \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 VDD VDD VDD \$6 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 VDD \$4 O \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 O VDD VDD \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 -0.25,-1.2 slvtnfet
M$7 VSS A \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 0.25,-1.2 slvtnfet
M$8 \$8 B \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 0.75,-1.2 slvtnfet
M$9 \$4 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 1.25,-1.2 slvtnfet
M$10 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 1.75,-1.2 slvtnfet
M$11 VSS \$4 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 2.25,-1.2 slvtnfet
M$12 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS and_gate
