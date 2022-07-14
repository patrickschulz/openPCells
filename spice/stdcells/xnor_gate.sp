* Created by KLayout

* cell xnor_gate
* pin VSS
* pin A,B
* pin VDD
* pin O
* pin SUBSTRATE
.SUBCKT xnor_gate VSS A|B VDD O SUBSTRATE
* device instance $1 r0 *1 -2.25,1.2 slvtpfet
M$1 VDD A|B A|B \$5 slvtpfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $2 r0 *1 -1.75,1.2 slvtpfet
M$2 A|B VDD VDD \$5 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $5 r0 *1 -0.25,1.2 slvtpfet
M$5 VDD A|B \$6 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 0.25,1.2 slvtpfet
M$6 \$6 A|B \$6 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 0.75,1.2 slvtpfet
M$7 \$6 A|B \$7 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 1.25,1.2 slvtpfet
M$8 \$7 A|B \$10 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 1.75,1.2 slvtpfet
M$9 \$10 A|B VDD \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 2.25,1.2 slvtpfet
M$10 VDD A|B VDD \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 2.75,1.2 slvtpfet
M$11 VDD VDD VDD \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 3.25,1.2 slvtpfet
M$12 VDD \$7 O \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 3.75,1.2 slvtpfet
M$13 O VDD VDD \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $14 r0 *1 -2.25,-1.2 slvtnfet
M$14 VSS A|B A|B SUBSTRATE slvtnfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $15 r0 *1 -1.75,-1.2 slvtnfet
M$15 A|B VSS VSS SUBSTRATE slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $18 r0 *1 -0.25,-1.2 slvtnfet
M$18 VSS A|B VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 0.25,-1.2 slvtnfet
M$19 VSS A|B \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 0.75,-1.2 slvtnfet
M$20 \$9 A|B \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $21 r0 *1 1.25,-1.2 slvtnfet
M$21 \$7 A|B \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $22 r0 *1 1.75,-1.2 slvtnfet
M$22 \$2 A|B \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 2.25,-1.2 slvtnfet
M$23 \$2 A|B VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 2.75,-1.2 slvtnfet
M$24 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $25 r0 *1 3.25,-1.2 slvtnfet
M$25 VSS \$7 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $26 r0 *1 3.75,-1.2 slvtnfet
M$26 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS xnor_gate
