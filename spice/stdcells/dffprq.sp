* Created by KLayout

* cell dffprq
* pin VDD,VSS
* pin D
* pin CLK
* pin Q
* pin SUBSTRATE
.SUBCKT dffprq VDD|VSS D CLK Q SUBSTRATE
* device instance $1 r0 *1 -5.75,1.2 slvtpfet
M$1 VDD|VSS CLK \$9 \$14 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -5.25,1.2 slvtpfet
M$2 \$9 VDD|VSS VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $3 r0 *1 -4.75,1.2 slvtpfet
M$3 VDD|VSS \$9 \$10 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -4.25,1.2 slvtpfet
M$4 \$10 VDD|VSS VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $5 r0 *1 -3.75,1.2 slvtpfet
M$5 VDD|VSS \$9 VDD|VSS \$14 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U
+ PD=2.6U
* device instance $6 r0 *1 -3.25,1.2 slvtpfet
M$6 VDD|VSS \$10 \$16 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $7 r0 *1 -2.75,1.2 slvtpfet
M$7 \$16 D \$3 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -2.25,1.2 slvtpfet
M$8 \$3 VDD|VSS \$3 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1.75,1.2 slvtpfet
M$9 \$3 \$12 \$17 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -1.25,1.2 slvtpfet
M$10 \$17 \$9 VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 -0.75,1.2 slvtpfet
M$11 VDD|VSS \$10 VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $12 r0 *1 -0.25,1.2 slvtpfet
M$12 VDD|VSS \$11 \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $13 r0 *1 0.25,1.2 slvtpfet
M$13 \$12 \$3 VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $14 r0 *1 0.75,1.2 slvtpfet
M$14 VDD|VSS VDD|VSS \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $15 r0 *1 1.25,1.2 slvtpfet
M$15 \$12 \$10 \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 1.75,1.2 slvtpfet
M$16 \$12 \$9 \$5 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 2.25,1.2 slvtpfet
M$17 \$5 VDD|VSS \$5 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $18 r0 *1 2.75,1.2 slvtpfet
M$18 \$5 \$13 \$19 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 3.25,1.2 slvtpfet
M$19 \$19 \$10 VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $21 r0 *1 4.25,1.2 slvtpfet
M$21 VDD|VSS \$11 \$13 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $22 r0 *1 4.75,1.2 slvtpfet
M$22 \$13 \$5 VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 5.25,1.2 slvtpfet
M$23 VDD|VSS VDD|VSS VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $24 r0 *1 5.75,1.2 slvtpfet
M$24 VDD|VSS \$13 Q \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 6.25,1.2 slvtpfet
M$25 Q VDD|VSS VDD|VSS \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
* device instance $26 r0 *1 -5.75,-1.2 slvtnfet
M$26 VDD|VSS CLK \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $27 r0 *1 -5.25,-1.2 slvtnfet
M$27 \$9 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $28 r0 *1 -4.75,-1.2 slvtnfet
M$28 VDD|VSS \$9 \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 -4.25,-1.2 slvtnfet
M$29 \$10 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $30 r0 *1 -3.75,-1.2 slvtnfet
M$30 VDD|VSS \$9 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 -3.25,-1.2 slvtnfet
M$31 \$2 \$10 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 -2.75,-1.2 slvtnfet
M$32 \$2 D \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 -2.25,-1.2 slvtnfet
M$33 \$3 VDD|VSS \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 -1.75,-1.2 slvtnfet
M$34 \$3 \$12 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 -1.25,-1.2 slvtnfet
M$35 \$4 \$9 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 -0.75,-1.2 slvtnfet
M$36 \$4 \$10 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 -0.25,-1.2 slvtnfet
M$37 VDD|VSS \$11 \$18 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 0.25,-1.2 slvtnfet
M$38 \$18 \$3 \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 0.75,-1.2 slvtnfet
M$39 \$12 VDD|VSS \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 1.25,-1.2 slvtnfet
M$40 \$12 \$10 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 1.75,-1.2 slvtnfet
M$41 \$5 \$9 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 2.25,-1.2 slvtnfet
M$42 \$5 VDD|VSS \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 2.75,-1.2 slvtnfet
M$43 \$5 \$13 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 3.25,-1.2 slvtnfet
M$44 \$6 \$10 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $45 r0 *1 3.75,-1.2 slvtnfet
M$45 \$6 \$9 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $46 r0 *1 4.25,-1.2 slvtnfet
M$46 VDD|VSS \$11 \$20 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $47 r0 *1 4.75,-1.2 slvtnfet
M$47 \$20 \$5 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $48 r0 *1 5.25,-1.2 slvtnfet
M$48 \$13 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $49 r0 *1 5.75,-1.2 slvtnfet
M$49 VDD|VSS \$13 Q SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $50 r0 *1 6.25,-1.2 slvtnfet
M$50 Q VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS dffprq
