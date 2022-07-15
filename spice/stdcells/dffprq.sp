* Created by KLayout

* cell dffprq
* pin VSS
* pin D
* pin VDD
* pin CLK
* pin RESET
* pin Q
* pin SUBSTRATE
.SUBCKT dffprq VSS D VDD CLK RESET Q SUBSTRATE
* device instance $1 r0 *1 -5.75,1.2 slvtpfet
M$1 VDD CLK \$10 \$15 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -5.25,1.2 slvtpfet
M$2 \$10 VDD VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -4.75,1.2 slvtpfet
M$3 VDD \$10 \$11 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -4.25,1.2 slvtpfet
M$4 \$11 VDD VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 -3.75,1.2 slvtpfet
M$5 VDD \$10 VDD \$15 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 -3.25,1.2 slvtpfet
M$6 VDD \$11 \$17 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 -2.75,1.2 slvtpfet
M$7 \$17 D \$3 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -2.25,1.2 slvtpfet
M$8 \$3 VDD \$3 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1.75,1.2 slvtpfet
M$9 \$3 \$13 \$18 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -1.25,1.2 slvtpfet
M$10 \$18 \$10 VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 -0.75,1.2 slvtpfet
M$11 VDD \$11 VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 -0.25,1.2 slvtpfet
M$12 VDD RESET \$13 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 0.25,1.2 slvtpfet
M$13 \$13 \$3 VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 0.75,1.2 slvtpfet
M$14 VDD VDD \$13 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 1.25,1.2 slvtpfet
M$15 \$13 \$11 \$13 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 1.75,1.2 slvtpfet
M$16 \$13 \$10 \$5 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 2.25,1.2 slvtpfet
M$17 \$5 VDD \$5 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $18 r0 *1 2.75,1.2 slvtpfet
M$18 \$5 \$14 \$20 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 3.25,1.2 slvtpfet
M$19 \$20 \$11 VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 4.25,1.2 slvtpfet
M$21 VDD RESET \$14 \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 4.75,1.2 slvtpfet
M$22 \$14 \$5 VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 5.25,1.2 slvtpfet
M$23 VDD VDD VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $24 r0 *1 5.75,1.2 slvtpfet
M$24 VDD \$14 Q \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 6.25,1.2 slvtpfet
M$25 Q VDD VDD \$15 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $26 r0 *1 -5.75,-1.2 slvtnfet
M$26 VSS CLK \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $27 r0 *1 -5.25,-1.2 slvtnfet
M$27 \$10 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 -4.75,-1.2 slvtnfet
M$28 VSS \$10 \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 -4.25,-1.2 slvtnfet
M$29 \$11 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 -3.75,-1.2 slvtnfet
M$30 VSS \$10 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 -3.25,-1.2 slvtnfet
M$31 \$2 \$11 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 -2.75,-1.2 slvtnfet
M$32 \$2 D \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 -2.25,-1.2 slvtnfet
M$33 \$3 VSS \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 -1.75,-1.2 slvtnfet
M$34 \$3 \$13 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 -1.25,-1.2 slvtnfet
M$35 \$4 \$10 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 -0.75,-1.2 slvtnfet
M$36 \$4 \$11 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 -0.25,-1.2 slvtnfet
M$37 VSS RESET \$19 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 0.25,-1.2 slvtnfet
M$38 \$19 \$3 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 0.75,-1.2 slvtnfet
M$39 \$13 VSS \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 1.25,-1.2 slvtnfet
M$40 \$13 \$11 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 1.75,-1.2 slvtnfet
M$41 \$5 \$10 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 2.25,-1.2 slvtnfet
M$42 \$5 VSS \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 2.75,-1.2 slvtnfet
M$43 \$5 \$14 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 3.25,-1.2 slvtnfet
M$44 \$6 \$11 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $45 r0 *1 3.75,-1.2 slvtnfet
M$45 \$6 \$10 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $46 r0 *1 4.25,-1.2 slvtnfet
M$46 VSS RESET \$21 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $47 r0 *1 4.75,-1.2 slvtnfet
M$47 \$21 \$5 \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $48 r0 *1 5.25,-1.2 slvtnfet
M$48 \$14 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $49 r0 *1 5.75,-1.2 slvtnfet
M$49 VSS \$14 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $50 r0 *1 6.25,-1.2 slvtnfet
M$50 Q VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS dffprq
