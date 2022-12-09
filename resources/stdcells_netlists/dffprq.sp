* Created by KLayout

* cell dffprq
* pin VSS
* pin CLK
* pin Q
* pin RST
* pin D
* pin VDD
* pin SUBSTRATE
.SUBCKT dffprq VSS CLK Q RST D VDD SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD CLK \$21 \$35 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$21 VDD VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 VDD \$21 \$22 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 \$22 VDD VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 VDD \$21 VDD \$35 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 VDD \$22 \$40 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 \$40 D \$24 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.5,1.2 slvtpfet
M$8 \$24 VDD \$24 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 4,1.2 slvtpfet
M$9 \$24 \$25 \$43 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.5,1.2 slvtpfet
M$10 \$43 \$21 VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 5,1.2 slvtpfet
M$11 VDD \$22 VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 5.5,1.2 slvtpfet
M$12 VDD RST \$25 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 6,1.2 slvtpfet
M$13 \$25 \$24 VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 6.5,1.2 slvtpfet
M$14 VDD VDD \$25 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 7,1.2 slvtpfet
M$15 \$25 \$22 \$25 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.5,1.2 slvtpfet
M$16 \$25 \$21 \$27 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 8,1.2 slvtpfet
M$17 \$27 VDD \$27 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $18 r0 *1 8.5,1.2 slvtpfet
M$18 \$27 \$28 \$53 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 9,1.2 slvtpfet
M$19 \$53 \$22 VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 10,1.2 slvtpfet
M$21 VDD RST \$28 \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 10.5,1.2 slvtpfet
M$22 \$28 \$27 VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 11,1.2 slvtpfet
M$23 VDD VDD VDD \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $24 r0 *1 11.5,1.2 slvtpfet
M$24 VDD \$28 Q \$35 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $25 r0 *1 0,-1.2 slvtnfet
M$25 VSS CLK \$21 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $26 r0 *1 0.5,-1.2 slvtnfet
M$26 \$21 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $27 r0 *1 1,-1.2 slvtnfet
M$27 VSS \$21 \$22 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 1.5,-1.2 slvtnfet
M$28 \$22 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 2,-1.2 slvtnfet
M$29 VSS \$21 \$23 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 2.5,-1.2 slvtnfet
M$30 \$23 \$22 \$23 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 3,-1.2 slvtnfet
M$31 \$23 D \$24 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 3.5,-1.2 slvtnfet
M$32 \$24 VSS \$24 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 4,-1.2 slvtnfet
M$33 \$24 \$25 \$26 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 4.5,-1.2 slvtnfet
M$34 \$26 \$21 \$26 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 5,-1.2 slvtnfet
M$35 \$26 \$22 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 5.5,-1.2 slvtnfet
M$36 VSS RST \$32 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 6,-1.2 slvtnfet
M$37 \$32 \$24 \$25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 6.5,-1.2 slvtnfet
M$38 \$25 VSS \$25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 7,-1.2 slvtnfet
M$39 \$25 \$22 \$27 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 7.5,-1.2 slvtnfet
M$40 \$27 \$21 \$27 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 8,-1.2 slvtnfet
M$41 \$27 VSS \$27 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 8.5,-1.2 slvtnfet
M$42 \$27 \$28 \$29 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 9,-1.2 slvtnfet
M$43 \$29 \$22 \$29 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 9.5,-1.2 slvtnfet
M$44 \$29 \$21 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $45 r0 *1 10,-1.2 slvtnfet
M$45 VSS RST \$31 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $46 r0 *1 10.5,-1.2 slvtnfet
M$46 \$31 \$27 \$28 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $47 r0 *1 11,-1.2 slvtnfet
M$47 \$28 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $48 r0 *1 11.5,-1.2 slvtnfet
M$48 VSS \$28 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS dffprq
