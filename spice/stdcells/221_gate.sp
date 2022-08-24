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
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD C1 \$I15 \$I8 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$I15 C2 \$I52 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 \$I52 VDD VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 VDD \$I52 \$2 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 \$2 VDD VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 VDD VDD VDD \$I8 slvtpfet L=0.2U W=5U AS=0.75P AD=1P PS=6.5U PD=8U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 VDD A \$I46 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.5,1.2 slvtpfet
M$8 \$I46 \$2 \$I45 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 4,1.2 slvtpfet
M$9 \$I45 VDD VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.5,1.2 slvtpfet
M$10 VDD \$I45 \$1 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 5,1.2 slvtpfet
M$11 \$1 VDD VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 6,1.2 slvtpfet
M$13 VDD B1 \$I36 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 6.5,1.2 slvtpfet
M$14 \$I36 B2 VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.5,1.2 slvtpfet
M$16 VDD \$I36 \$3 \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 8,1.2 slvtpfet
M$17 \$3 VDD VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 9,1.2 slvtpfet
M$19 VDD \$1 O \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 9.5,1.2 slvtpfet
M$20 O \$3 VDD \$I8 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 0,-1.2 slvtnfet
M$22 VSS C1 \$I52 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $23 r0 *1 0.5,-1.2 slvtnfet
M$23 \$I52 C2 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 1,-1.2 slvtnfet
M$24 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=5U AS=0.75P AD=0.75P PS=6.5U
+ PD=6.5U
* device instance $25 r0 *1 1.5,-1.2 slvtnfet
M$25 VSS \$I52 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 2,-1.2 slvtnfet
M$26 \$2 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 3,-1.2 slvtnfet
M$28 VSS A \$I45 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 3.5,-1.2 slvtnfet
M$29 \$I45 \$2 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 4.5,-1.2 slvtnfet
M$31 VSS \$I45 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 5,-1.2 slvtnfet
M$32 \$1 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 6,-1.2 slvtnfet
M$34 VSS B1 \$I98 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 6.5,-1.2 slvtnfet
M$35 \$I98 B2 \$I36 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 7,-1.2 slvtnfet
M$36 \$I36 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 7.5,-1.2 slvtnfet
M$37 VSS \$I36 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 8,-1.2 slvtnfet
M$38 \$3 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 9,-1.2 slvtnfet
M$40 VSS \$1 \$I91 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 9.5,-1.2 slvtnfet
M$41 \$I91 \$3 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 10,-1.2 slvtnfet
M$42 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS 221_gate
