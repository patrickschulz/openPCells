* Created by KLayout

* cell 221_gate
* pin A
* pin B1
* pin B2
* pin C1
* pin C2
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT 221_gate A B1 B2 C1 C2 O VDD VSS SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 VDD C1 \$I11 \$I9 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 \$I11 C2 \$I33 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 \$I33 VDD VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.25,1.2 slvtpfet
M$4 VDD VDD VDD \$I9 slvtpfet L=0.2U W=8U AS=1.2P AD=1.45P PS=10.4U PD=11.9U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 VDD \$I33 \$2 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 \$2 VDD VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.25,1.2 slvtpfet
M$8 VDD A \$I26 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 3.75,1.2 slvtpfet
M$9 \$I26 \$2 \$I25 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.25,1.2 slvtpfet
M$10 \$I25 VDD VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 5.25,1.2 slvtpfet
M$12 VDD \$I25 \$1 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 5.75,1.2 slvtpfet
M$13 \$1 VDD VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 6.75,1.2 slvtpfet
M$15 VDD B1 \$I15 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.25,1.2 slvtpfet
M$16 \$I15 B2 VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 8.75,1.2 slvtpfet
M$19 VDD \$I15 \$3 \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 9.25,1.2 slvtpfet
M$20 \$3 VDD VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 10.25,1.2 slvtpfet
M$22 VDD \$1 O \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 10.75,1.2 slvtpfet
M$23 O \$3 VDD \$I9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 -0.25,-1.2 slvtnfet
M$25 VSS C1 \$I33 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $26 r0 *1 0.25,-1.2 slvtnfet
M$26 \$I33 C2 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $27 r0 *1 0.75,-1.2 slvtnfet
M$27 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=8U AS=1.2P AD=1.2P PS=10.4U
+ PD=10.4U
* device instance $29 r0 *1 1.75,-1.2 slvtnfet
M$29 VSS \$I33 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 2.25,-1.2 slvtnfet
M$30 \$2 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 3.25,-1.2 slvtnfet
M$32 VSS A \$I25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 3.75,-1.2 slvtnfet
M$33 \$I25 \$2 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 5.25,-1.2 slvtnfet
M$36 VSS \$I25 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 5.75,-1.2 slvtnfet
M$37 \$1 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 6.75,-1.2 slvtnfet
M$39 VSS B1 \$I107 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 7.25,-1.2 slvtnfet
M$40 \$I107 B2 \$I15 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 7.75,-1.2 slvtnfet
M$41 \$I15 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 8.75,-1.2 slvtnfet
M$43 VSS \$I15 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 9.25,-1.2 slvtnfet
M$44 \$3 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $46 r0 *1 10.25,-1.2 slvtnfet
M$46 VSS \$1 \$I99 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $47 r0 *1 10.75,-1.2 slvtnfet
M$47 \$I99 \$3 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $48 r0 *1 11.25,-1.2 slvtnfet
M$48 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS 221_gate
