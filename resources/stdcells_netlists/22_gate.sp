* Created by KLayout

* cell 22_gate
* pin A1
* pin A2
* pin B1
* pin B2
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT 22_gate A1 A2 B1 B2 O VDD VSS SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD A1 \$I10 \$I5 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$I10 A2 VDD \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 VDD VDD VDD \$I5 slvtpfet L=0.2U W=4U AS=0.6P AD=0.6P PS=5.2U PD=5.2U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 VDD \$I10 \$1 \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 \$1 VDD VDD \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 VDD B1 \$I54 \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.5,1.2 slvtpfet
M$8 \$I54 B2 VDD \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.5,1.2 slvtpfet
M$10 VDD \$I54 \$2 \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 5,1.2 slvtpfet
M$11 \$2 VDD VDD \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 6,1.2 slvtpfet
M$13 VDD \$2 \$I48 \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 6.5,1.2 slvtpfet
M$14 \$I48 \$1 O \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 7,1.2 slvtpfet
M$15 O VDD VDD \$I5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $16 r0 *1 0,-1.2 slvtnfet
M$16 VSS A1 \$I60 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $17 r0 *1 0.5,-1.2 slvtnfet
M$17 \$I60 A2 \$I10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $18 r0 *1 1,-1.2 slvtnfet
M$18 \$I10 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 1.5,-1.2 slvtnfet
M$19 VSS \$I10 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 2,-1.2 slvtnfet
M$20 \$1 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $21 r0 *1 2.5,-1.2 slvtnfet
M$21 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=3U AS=0.45P AD=0.7P PS=3.9U PD=5.4U
* device instance $22 r0 *1 3,-1.2 slvtnfet
M$22 VSS B1 \$I69 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 3.5,-1.2 slvtnfet
M$23 \$I69 B2 \$I54 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 4,-1.2 slvtnfet
M$24 \$I54 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $25 r0 *1 4.5,-1.2 slvtnfet
M$25 VSS \$I54 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 5,-1.2 slvtnfet
M$26 \$2 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 6,-1.2 slvtnfet
M$28 VSS \$2 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $29 r0 *1 6.5,-1.2 slvtnfet
M$29 O \$1 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
.ENDS 22_gate
