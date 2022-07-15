* Created by KLayout

* cell dff
* pin VSS
* pin D
* pin VDD
* pin CLK
* pin Q
* pin SUBSTRATE
.SUBCKT dff VSS D VDD CLK Q SUBSTRATE
* device instance $1 r0 *1 -5,1.2 slvtpfet
M$1 VDD CLK \$10 \$14 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -4.5,1.2 slvtpfet
M$2 \$10 VDD VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -4,1.2 slvtpfet
M$3 VDD \$10 \$11 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -3.5,1.2 slvtpfet
M$4 \$11 VDD VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 -3,1.2 slvtpfet
M$5 VDD \$10 VDD \$14 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 -2.5,1.2 slvtpfet
M$6 VDD \$11 \$16 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 -2,1.2 slvtpfet
M$7 \$16 D \$3 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -1.5,1.2 slvtpfet
M$8 \$3 VDD \$3 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1,1.2 slvtpfet
M$9 \$3 \$12 \$17 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -0.5,1.2 slvtpfet
M$10 \$17 \$10 VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 0,1.2 slvtpfet
M$11 VDD \$11 VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 0.5,1.2 slvtpfet
M$12 VDD \$3 \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 1,1.2 slvtpfet
M$13 \$12 \$11 \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 1.5,1.2 slvtpfet
M$14 \$12 \$10 \$5 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 2,1.2 slvtpfet
M$15 \$5 VDD \$5 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 2.5,1.2 slvtpfet
M$16 \$5 \$13 \$18 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 3,1.2 slvtpfet
M$17 \$18 \$11 VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 4,1.2 slvtpfet
M$19 VDD \$5 \$13 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 4.5,1.2 slvtpfet
M$20 \$13 VDD VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 5,1.2 slvtpfet
M$21 VDD \$13 Q \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 5.5,1.2 slvtpfet
M$22 Q VDD VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $23 r0 *1 -5,-1.2 slvtnfet
M$23 VSS CLK \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $24 r0 *1 -4.5,-1.2 slvtnfet
M$24 \$10 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $25 r0 *1 -4,-1.2 slvtnfet
M$25 VSS \$10 \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 -3.5,-1.2 slvtnfet
M$26 \$11 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $27 r0 *1 -3,-1.2 slvtnfet
M$27 VSS \$10 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 -2.5,-1.2 slvtnfet
M$28 \$2 \$11 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 -2,-1.2 slvtnfet
M$29 \$2 D \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $30 r0 *1 -1.5,-1.2 slvtnfet
M$30 \$3 VSS \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 -1,-1.2 slvtnfet
M$31 \$3 \$12 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 -0.5,-1.2 slvtnfet
M$32 \$4 \$10 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 0,-1.2 slvtnfet
M$33 \$4 \$11 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 0.5,-1.2 slvtnfet
M$34 VSS \$3 \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 1,-1.2 slvtnfet
M$35 \$12 \$11 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 1.5,-1.2 slvtnfet
M$36 \$5 \$10 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 2,-1.2 slvtnfet
M$37 \$5 VSS \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 2.5,-1.2 slvtnfet
M$38 \$5 \$13 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 3,-1.2 slvtnfet
M$39 \$6 \$11 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 3.5,-1.2 slvtnfet
M$40 \$6 \$10 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 4,-1.2 slvtnfet
M$41 VSS \$5 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 4.5,-1.2 slvtnfet
M$42 \$13 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 5,-1.2 slvtnfet
M$43 VSS \$13 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $44 r0 *1 5.5,-1.2 slvtnfet
M$44 Q VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS dff
