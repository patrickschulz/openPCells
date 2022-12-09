* Created by KLayout

* cell dffpq
* pin VSS
* pin CLK
* pin Q
* pin D
* pin VDD
* pin SUBSTRATE
.SUBCKT dffpq VSS CLK Q D VDD SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD CLK \$19 \$30 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$19 VDD VDD \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 VDD \$19 \$20 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 \$20 VDD VDD \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 VDD \$19 VDD \$30 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 VDD \$20 \$35 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 \$35 D \$22 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.5,1.2 slvtpfet
M$8 \$22 VDD \$22 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 4,1.2 slvtpfet
M$9 \$22 \$23 \$40 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.5,1.2 slvtpfet
M$10 \$40 \$19 VDD \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 5,1.2 slvtpfet
M$11 VDD \$20 VDD \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 5.5,1.2 slvtpfet
M$12 VDD \$22 \$23 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 6,1.2 slvtpfet
M$13 \$23 \$20 \$23 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 6.5,1.2 slvtpfet
M$14 \$23 \$19 \$25 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 7,1.2 slvtpfet
M$15 \$25 VDD \$25 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.5,1.2 slvtpfet
M$16 \$25 \$26 \$47 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 8,1.2 slvtpfet
M$17 \$47 \$20 VDD \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 9,1.2 slvtpfet
M$19 VDD \$25 \$26 \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 9.5,1.2 slvtpfet
M$20 \$26 VDD VDD \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 10,1.2 slvtpfet
M$21 VDD \$26 Q \$30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $22 r0 *1 0,-1.2 slvtnfet
M$22 VSS CLK \$19 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $23 r0 *1 0.5,-1.2 slvtnfet
M$23 \$19 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 1,-1.2 slvtnfet
M$24 VSS \$19 \$20 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $25 r0 *1 1.5,-1.2 slvtnfet
M$25 \$20 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 2,-1.2 slvtnfet
M$26 VSS \$19 \$21 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $27 r0 *1 2.5,-1.2 slvtnfet
M$27 \$21 \$20 \$21 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 3,-1.2 slvtnfet
M$28 \$21 D \$22 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 3.5,-1.2 slvtnfet
M$29 \$22 VSS \$22 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 4,-1.2 slvtnfet
M$30 \$22 \$23 \$24 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 4.5,-1.2 slvtnfet
M$31 \$24 \$19 \$24 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 5,-1.2 slvtnfet
M$32 \$24 \$20 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 5.5,-1.2 slvtnfet
M$33 VSS \$22 \$23 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 6,-1.2 slvtnfet
M$34 \$23 \$20 \$25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 6.5,-1.2 slvtnfet
M$35 \$25 \$19 \$25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 7,-1.2 slvtnfet
M$36 \$25 VSS \$25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 7.5,-1.2 slvtnfet
M$37 \$25 \$26 \$27 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 8,-1.2 slvtnfet
M$38 \$27 \$20 \$27 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 8.5,-1.2 slvtnfet
M$39 \$27 \$19 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 9,-1.2 slvtnfet
M$40 VSS \$25 \$26 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 9.5,-1.2 slvtnfet
M$41 \$26 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 10,-1.2 slvtnfet
M$42 VSS \$26 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS dffpq
