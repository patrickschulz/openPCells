* Created by KLayout

* cell dffprq
* pin VSS
* pin CLK
* pin Q
* pin RESET
* pin D
* pin VDD
* pin SUBSTRATE
.SUBCKT dffprq VSS CLK Q RESET D VDD SUBSTRATE
* device instance $1 r0 *1 -5.75,1.2 slvtpfet
M$1 VDD CLK \$3 \$17 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -5.25,1.2 slvtpfet
M$2 \$3 VDD VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -4.75,1.2 slvtpfet
M$3 VDD \$3 \$4 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -4.25,1.2 slvtpfet
M$4 \$4 VDD VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 -3.75,1.2 slvtpfet
M$5 VDD \$3 VDD \$17 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 -3.25,1.2 slvtpfet
M$6 VDD \$4 \$19 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 -2.75,1.2 slvtpfet
M$7 \$19 D \$6 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -2.25,1.2 slvtpfet
M$8 \$6 VDD \$6 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1.75,1.2 slvtpfet
M$9 \$6 \$7 \$20 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -1.25,1.2 slvtpfet
M$10 \$20 \$3 VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 -0.75,1.2 slvtpfet
M$11 VDD \$4 VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 -0.25,1.2 slvtpfet
M$12 VDD RESET \$7 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 0.25,1.2 slvtpfet
M$13 \$7 \$6 VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 0.75,1.2 slvtpfet
M$14 VDD VDD \$7 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 1.25,1.2 slvtpfet
M$15 \$7 \$4 \$7 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 1.75,1.2 slvtpfet
M$16 \$7 \$3 \$9 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 2.25,1.2 slvtpfet
M$17 \$9 VDD \$9 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $18 r0 *1 2.75,1.2 slvtpfet
M$18 \$9 \$10 \$21 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 3.25,1.2 slvtpfet
M$19 \$21 \$4 VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 4.25,1.2 slvtpfet
M$21 VDD RESET \$10 \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 4.75,1.2 slvtpfet
M$22 \$10 \$9 VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 5.25,1.2 slvtpfet
M$23 VDD VDD VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $24 r0 *1 5.75,1.2 slvtpfet
M$24 VDD \$10 Q \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 6.25,1.2 slvtpfet
M$25 Q VDD VDD \$17 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $26 r0 *1 -5.75,-1.2 slvtnfet
M$26 VSS CLK \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $27 r0 *1 -5.25,-1.2 slvtnfet
M$27 \$3 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 -4.75,-1.2 slvtnfet
M$28 VSS \$3 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 -4.25,-1.2 slvtnfet
M$29 \$4 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 -3.75,-1.2 slvtnfet
M$30 VSS \$3 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 -3.25,-1.2 slvtnfet
M$31 \$5 \$4 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 -2.75,-1.2 slvtnfet
M$32 \$5 D \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 -2.25,-1.2 slvtnfet
M$33 \$6 VSS \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 -1.75,-1.2 slvtnfet
M$34 \$6 \$7 \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 -1.25,-1.2 slvtnfet
M$35 \$8 \$3 \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 -0.75,-1.2 slvtnfet
M$36 \$8 \$4 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 -0.25,-1.2 slvtnfet
M$37 VSS RESET \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 0.25,-1.2 slvtnfet
M$38 \$14 \$6 \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 0.75,-1.2 slvtnfet
M$39 \$7 VSS \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 1.25,-1.2 slvtnfet
M$40 \$7 \$4 \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 1.75,-1.2 slvtnfet
M$41 \$9 \$3 \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 2.25,-1.2 slvtnfet
M$42 \$9 VSS \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 2.75,-1.2 slvtnfet
M$43 \$9 \$10 \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 3.25,-1.2 slvtnfet
M$44 \$11 \$4 \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $45 r0 *1 3.75,-1.2 slvtnfet
M$45 \$11 \$3 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $46 r0 *1 4.25,-1.2 slvtnfet
M$46 VSS RESET \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $47 r0 *1 4.75,-1.2 slvtnfet
M$47 \$13 \$9 \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $48 r0 *1 5.25,-1.2 slvtnfet
M$48 \$10 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $49 r0 *1 5.75,-1.2 slvtnfet
M$49 VSS \$10 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $50 r0 *1 6.25,-1.2 slvtnfet
M$50 Q VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS dffprq
