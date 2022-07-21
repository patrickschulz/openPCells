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
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 VDD A1 \$I8 \$I4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 \$I8 A2 VDD \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 VDD VDD VDD \$I4 slvtpfet L=0.2U W=6U AS=0.9P AD=0.9P PS=7.8U PD=7.8U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 VDD \$I8 \$1 \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 \$1 VDD VDD \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.25,1.2 slvtpfet
M$8 VDD B1 \$I59 \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 3.75,1.2 slvtpfet
M$9 \$I59 B2 VDD \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 5.25,1.2 slvtpfet
M$12 VDD \$I59 \$2 \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 5.75,1.2 slvtpfet
M$13 \$2 VDD VDD \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 6.75,1.2 slvtpfet
M$15 VDD \$2 \$I52 \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.25,1.2 slvtpfet
M$16 \$I52 \$1 O \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 7.75,1.2 slvtpfet
M$17 O VDD VDD \$I4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $18 r0 *1 -0.25,-1.2 slvtnfet
M$18 VSS A1 \$I66 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $19 r0 *1 0.25,-1.2 slvtnfet
M$19 \$I66 A2 \$I8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 0.75,-1.2 slvtnfet
M$20 \$I8 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $21 r0 *1 1.25,-1.2 slvtnfet
M$21 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=5U AS=0.75P AD=1P PS=6.5U PD=8U
* device instance $22 r0 *1 1.75,-1.2 slvtnfet
M$22 VSS \$I8 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 2.25,-1.2 slvtnfet
M$23 \$1 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $25 r0 *1 3.25,-1.2 slvtnfet
M$25 VSS B1 \$I76 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 3.75,-1.2 slvtnfet
M$26 \$I76 B2 \$I59 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $27 r0 *1 4.25,-1.2 slvtnfet
M$27 \$I59 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 5.25,-1.2 slvtnfet
M$29 VSS \$I59 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 5.75,-1.2 slvtnfet
M$30 \$2 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 6.75,-1.2 slvtnfet
M$32 VSS \$2 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 7.25,-1.2 slvtnfet
M$33 O \$1 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
.ENDS 22_gate
