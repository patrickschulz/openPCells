* Created by KLayout

* cell half_adder
* pin A,B,COUT,S
* pin SUBSTRATE
.SUBCKT half_adder A|B|COUT|S SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 \$20 A|B|COUT|S \$15 \$19 slvtpfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U
+ PD=2.6U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 \$20 \$20 \$20 \$19 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 \$20 \$15 A|B|COUT|S \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 A|B|COUT|S \$20 \$20 \$19 slvtpfet L=0.2U W=3U AS=0.45P AD=0.45P PS=3.9U
+ PD=3.9U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 \$20 A|B|COUT|S A|B|COUT|S \$19 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P
+ PS=2.6U PD=2.6U
* device instance $11 r0 *1 5,1.2 slvtpfet
M$11 \$20 A|B|COUT|S \$21 \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $12 r0 *1 5.5,1.2 slvtpfet
M$12 \$21 A|B|COUT|S \$21 \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $13 r0 *1 6,1.2 slvtpfet
M$13 \$21 A|B|COUT|S \$16 \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $14 r0 *1 6.5,1.2 slvtpfet
M$14 \$16 A|B|COUT|S \$30 \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $15 r0 *1 7,1.2 slvtpfet
M$15 \$30 A|B|COUT|S \$20 \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 7.5,1.2 slvtpfet
M$16 \$20 A|B|COUT|S \$20 \$19 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
* device instance $17 r0 *1 0,-1.2 slvtnfet
M$17 \$1 A|B|COUT|S \$17 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P
+ PS=2.8U PD=1.3U
* device instance $18 r0 *1 0.5,-1.2 slvtnfet
M$18 \$17 A|B|COUT|S \$15 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $19 r0 *1 1,-1.2 slvtnfet
M$19 \$15 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 1.5,-1.2 slvtnfet
M$20 \$1 \$15 A|B|COUT|S SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $21 r0 *1 2,-1.2 slvtnfet
M$21 A|B|COUT|S \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=3U AS=0.45P AD=0.45P
+ PS=3.9U PD=3.9U
* device instance $22 r0 *1 2.5,-1.2 slvtnfet
M$22 \$1 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 3,-1.2 slvtnfet
M$23 \$1 A|B|COUT|S A|B|COUT|S SUBSTRATE slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P
+ PS=2.6U PD=2.6U
* device instance $27 r0 *1 5,-1.2 slvtnfet
M$27 \$1 A|B|COUT|S \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $28 r0 *1 5.5,-1.2 slvtnfet
M$28 \$1 A|B|COUT|S \$18 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $29 r0 *1 6,-1.2 slvtnfet
M$29 \$18 A|B|COUT|S \$16 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $30 r0 *1 6.5,-1.2 slvtnfet
M$30 \$16 A|B|COUT|S \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $31 r0 *1 7,-1.2 slvtnfet
M$31 \$13 A|B|COUT|S \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $32 r0 *1 7.5,-1.2 slvtnfet
M$32 \$13 A|B|COUT|S \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P
+ PS=1.3U PD=2.8U
.ENDS half_adder
