* Created by KLayout

* cell dffnq
* pin VDD,VSS
* pin D
* pin CLK
* pin Q
* pin SUBSTRATE
.SUBCKT dffnq VDD|VSS D CLK Q SUBSTRATE
* device instance $1 r0 *1 -5,1.2 slvtpfet
M$1 VDD|VSS CLK \$9 \$13 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -4.5,1.2 slvtpfet
M$2 \$9 VDD|VSS VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $3 r0 *1 -4,1.2 slvtpfet
M$3 VDD|VSS \$9 \$10 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -3.5,1.2 slvtpfet
M$4 \$10 VDD|VSS VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $5 r0 *1 -3,1.2 slvtpfet
M$5 VDD|VSS \$10 VDD|VSS \$13 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U
+ PD=2.6U
* device instance $6 r0 *1 -2.5,1.2 slvtpfet
M$6 VDD|VSS \$9 \$15 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 -2,1.2 slvtpfet
M$7 \$15 D \$3 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -1.5,1.2 slvtpfet
M$8 \$3 VDD|VSS \$3 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1,1.2 slvtpfet
M$9 \$3 \$11 \$16 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -0.5,1.2 slvtpfet
M$10 \$16 \$10 VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 0,1.2 slvtpfet
M$11 VDD|VSS \$9 VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $12 r0 *1 0.5,1.2 slvtpfet
M$12 VDD|VSS \$3 \$11 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $13 r0 *1 1,1.2 slvtpfet
M$13 \$11 \$9 \$11 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 1.5,1.2 slvtpfet
M$14 \$11 \$10 \$5 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 2,1.2 slvtpfet
M$15 \$5 VDD|VSS \$5 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 2.5,1.2 slvtpfet
M$16 \$5 \$12 \$17 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 3,1.2 slvtpfet
M$17 \$17 \$9 VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 4,1.2 slvtpfet
M$19 VDD|VSS \$5 \$12 \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 4.5,1.2 slvtpfet
M$20 \$12 VDD|VSS VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $21 r0 *1 5,1.2 slvtpfet
M$21 VDD|VSS \$12 Q \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 5.5,1.2 slvtpfet
M$22 Q VDD|VSS VDD|VSS \$13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
* device instance $23 r0 *1 -5,-1.2 slvtnfet
M$23 VDD|VSS CLK \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $24 r0 *1 -4.5,-1.2 slvtnfet
M$24 \$9 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $25 r0 *1 -4,-1.2 slvtnfet
M$25 VDD|VSS \$9 \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 -3.5,-1.2 slvtnfet
M$26 \$10 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $27 r0 *1 -3,-1.2 slvtnfet
M$27 VDD|VSS \$10 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 -2.5,-1.2 slvtnfet
M$28 \$2 \$9 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 -2,-1.2 slvtnfet
M$29 \$2 D \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $30 r0 *1 -1.5,-1.2 slvtnfet
M$30 \$3 VDD|VSS \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 -1,-1.2 slvtnfet
M$31 \$3 \$11 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 -0.5,-1.2 slvtnfet
M$32 \$4 \$10 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 0,-1.2 slvtnfet
M$33 \$4 \$9 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 0.5,-1.2 slvtnfet
M$34 VDD|VSS \$3 \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 1,-1.2 slvtnfet
M$35 \$11 \$9 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 1.5,-1.2 slvtnfet
M$36 \$5 \$10 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 2,-1.2 slvtnfet
M$37 \$5 VDD|VSS \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 2.5,-1.2 slvtnfet
M$38 \$5 \$12 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 3,-1.2 slvtnfet
M$39 \$6 \$9 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 3.5,-1.2 slvtnfet
M$40 \$6 \$10 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 4,-1.2 slvtnfet
M$41 VDD|VSS \$5 \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 4.5,-1.2 slvtnfet
M$42 \$12 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $43 r0 *1 5,-1.2 slvtnfet
M$43 VDD|VSS \$12 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 5.5,-1.2 slvtnfet
M$44 Q VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS dffnq
