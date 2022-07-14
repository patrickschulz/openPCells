* Created by KLayout

* cell half_adder
* pin A,B,COUT
* pin SUBSTRATE
.SUBCKT half_adder A|B|COUT SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 \$3 A|B|COUT \$4 \$5 slvtpfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 \$3 \$3 \$3 \$5 slvtpfet L=0.2U W=3U AS=0.45P AD=0.45P PS=3.9U PD=3.9U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 \$3 \$4 A|B|COUT \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 A|B|COUT \$3 \$3 \$5 slvtpfet L=0.2U W=3U AS=0.45P AD=0.45P PS=3.9U PD=3.9U
* device instance $8 r0 *1 3.25,1.2 slvtpfet
M$8 \$3 A|B|COUT A|B|COUT \$5 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U
+ PD=2.6U
* device instance $12 r0 *1 5.25,1.2 slvtpfet
M$12 \$3 A|B|COUT \$7 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 5.75,1.2 slvtpfet
M$13 \$7 A|B|COUT \$7 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 6.25,1.2 slvtpfet
M$14 \$7 A|B|COUT \$8 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 6.75,1.2 slvtpfet
M$15 \$8 A|B|COUT \$11 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 7.25,1.2 slvtpfet
M$16 \$11 A|B|COUT \$3 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $17 r0 *1 7.75,1.2 slvtpfet
M$17 \$3 A|B|COUT \$3 \$5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $18 r0 *1 -0.25,-1.2 slvtnfet
M$18 \$1 A|B|COUT \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $19 r0 *1 0.25,-1.2 slvtnfet
M$19 \$9 A|B|COUT \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 0.75,-1.2 slvtnfet
M$20 \$4 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $21 r0 *1 1.25,-1.2 slvtnfet
M$21 \$1 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $22 r0 *1 1.75,-1.2 slvtnfet
M$22 \$1 \$4 A|B|COUT SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 2.25,-1.2 slvtnfet
M$23 A|B|COUT \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=3U AS=0.45P AD=0.45P PS=3.9U
+ PD=3.9U
* device instance $25 r0 *1 3.25,-1.2 slvtnfet
M$25 \$1 A|B|COUT A|B|COUT SUBSTRATE slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P
+ PS=2.6U PD=2.6U
* device instance $29 r0 *1 5.25,-1.2 slvtnfet
M$29 \$1 A|B|COUT \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 5.75,-1.2 slvtnfet
M$30 \$1 A|B|COUT \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 6.25,-1.2 slvtnfet
M$31 \$10 A|B|COUT \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 6.75,-1.2 slvtnfet
M$32 \$8 A|B|COUT \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 7.25,-1.2 slvtnfet
M$33 \$2 A|B|COUT \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 7.75,-1.2 slvtnfet
M$34 \$2 A|B|COUT \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS half_adder
