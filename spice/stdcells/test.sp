* Created by KLayout

* cell test
* pin SUBSTRATE
.SUBCKT test SUBSTRATE
* device instance $1 r0 *1 -5,1.2 slvtpfet
M$1 \$7 \$9 \$10 \$14 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -4.5,1.2 slvtpfet
M$2 \$10 \$7 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -4,1.2 slvtpfet
M$3 \$7 \$10 \$11 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -3.5,1.2 slvtpfet
M$4 \$11 \$7 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 -3,1.2 slvtpfet
M$5 \$7 \$10 \$7 \$14 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 -2.5,1.2 slvtpfet
M$6 \$7 \$11 \$16 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 -2,1.2 slvtpfet
M$7 \$16 \$8 \$3 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -1.5,1.2 slvtpfet
M$8 \$3 \$7 \$3 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1,1.2 slvtpfet
M$9 \$3 \$12 \$17 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -0.5,1.2 slvtpfet
M$10 \$17 \$10 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 0,1.2 slvtpfet
M$11 \$7 \$11 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 0.5,1.2 slvtpfet
M$12 \$7 \$3 \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 1,1.2 slvtpfet
M$13 \$12 \$11 \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 1.5,1.2 slvtpfet
M$14 \$12 \$10 \$5 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 2,1.2 slvtpfet
M$15 \$5 \$7 \$5 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 2.5,1.2 slvtpfet
M$16 \$5 \$13 \$18 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 3,1.2 slvtpfet
M$17 \$18 \$11 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 4,1.2 slvtpfet
M$19 \$7 \$5 \$13 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 4.5,1.2 slvtpfet
M$20 \$13 \$7 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 5,1.2 slvtpfet
M$21 \$7 \$13 \$15 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 5.5,1.2 slvtpfet
M$22 \$15 \$7 \$7 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $23 r0 *1 -5,-1.2 slvtnfet
M$23 \$1 \$9 \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $24 r0 *1 -4.5,-1.2 slvtnfet
M$24 \$10 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $25 r0 *1 -4,-1.2 slvtnfet
M$25 \$1 \$10 \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 -3.5,-1.2 slvtnfet
M$26 \$11 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $27 r0 *1 -3,-1.2 slvtnfet
M$27 \$1 \$10 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $28 r0 *1 -2.5,-1.2 slvtnfet
M$28 \$2 \$11 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 -2,-1.2 slvtnfet
M$29 \$2 \$8 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 -1.5,-1.2 slvtnfet
M$30 \$3 \$1 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 -1,-1.2 slvtnfet
M$31 \$3 \$12 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 -0.5,-1.2 slvtnfet
M$32 \$4 \$10 \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 0,-1.2 slvtnfet
M$33 \$4 \$11 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $34 r0 *1 0.5,-1.2 slvtnfet
M$34 \$1 \$3 \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 1,-1.2 slvtnfet
M$35 \$12 \$11 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 1.5,-1.2 slvtnfet
M$36 \$5 \$10 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 2,-1.2 slvtnfet
M$37 \$5 \$1 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 2.5,-1.2 slvtnfet
M$38 \$5 \$13 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 3,-1.2 slvtnfet
M$39 \$6 \$11 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $40 r0 *1 3.5,-1.2 slvtnfet
M$40 \$6 \$10 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 4,-1.2 slvtnfet
M$41 \$1 \$5 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 4.5,-1.2 slvtnfet
M$42 \$13 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $43 r0 *1 5,-1.2 slvtnfet
M$43 \$1 \$13 \$15 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 5.5,-1.2 slvtnfet
M$44 \$15 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS test
