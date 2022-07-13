* Created by KLayout

* cell opctoplevel
* pin SUBSTRATE
.SUBCKT opctoplevel 18
* net 18 SUBSTRATE
* device instance $1 r0 *1 -5,1.2 slvtpfet
M$1 1 8 9 13 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -4.5,1.2 slvtpfet
M$2 9 1 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -4,1.2 slvtpfet
M$3 1 9 10 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -3.5,1.2 slvtpfet
M$4 10 1 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 -3,1.2 slvtpfet
M$5 1 10 1 13 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 -2.5,1.2 slvtpfet
M$6 1 9 15 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 -2,1.2 slvtpfet
M$7 15 7 3 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 -1.5,1.2 slvtpfet
M$8 3 1 3 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -1,1.2 slvtpfet
M$9 3 11 16 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -0.5,1.2 slvtpfet
M$10 16 10 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 0,1.2 slvtpfet
M$11 1 9 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 0.5,1.2 slvtpfet
M$12 1 3 11 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 1,1.2 slvtpfet
M$13 11 9 11 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $14 r0 *1 1.5,1.2 slvtpfet
M$14 11 10 5 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 2,1.2 slvtpfet
M$15 5 1 5 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 2.5,1.2 slvtpfet
M$16 5 12 17 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 3,1.2 slvtpfet
M$17 17 9 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 4,1.2 slvtpfet
M$19 1 5 12 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 4.5,1.2 slvtpfet
M$20 12 1 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 5,1.2 slvtpfet
M$21 1 12 14 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 5.5,1.2 slvtpfet
M$22 14 1 1 13 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $23 r0 *1 -5,-1.2 slvtnfet
M$23 1 8 9 18 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $24 r0 *1 -4.5,-1.2 slvtnfet
M$24 9 1 1 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 -4,-1.2 slvtnfet
M$25 1 9 10 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $26 r0 *1 -3.5,-1.2 slvtnfet
M$26 10 1 1 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $27 r0 *1 -3,-1.2 slvtnfet
M$27 1 10 2 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $28 r0 *1 -2.5,-1.2 slvtnfet
M$28 2 9 2 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $29 r0 *1 -2,-1.2 slvtnfet
M$29 2 7 3 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $30 r0 *1 -1.5,-1.2 slvtnfet
M$30 3 1 3 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $31 r0 *1 -1,-1.2 slvtnfet
M$31 3 11 4 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $32 r0 *1 -0.5,-1.2 slvtnfet
M$32 4 10 4 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 0,-1.2 slvtnfet
M$33 4 9 1 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $34 r0 *1 0.5,-1.2 slvtnfet
M$34 1 3 11 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $35 r0 *1 1,-1.2 slvtnfet
M$35 11 9 5 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $36 r0 *1 1.5,-1.2 slvtnfet
M$36 5 10 5 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $37 r0 *1 2,-1.2 slvtnfet
M$37 5 1 5 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $38 r0 *1 2.5,-1.2 slvtnfet
M$38 5 12 6 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $39 r0 *1 3,-1.2 slvtnfet
M$39 6 9 6 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $40 r0 *1 3.5,-1.2 slvtnfet
M$40 6 10 1 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $41 r0 *1 4,-1.2 slvtnfet
M$41 1 5 12 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $42 r0 *1 4.5,-1.2 slvtnfet
M$42 12 1 1 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $43 r0 *1 5,-1.2 slvtnfet
M$43 1 12 14 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $44 r0 *1 5.5,-1.2 slvtnfet
M$44 14 1 1 18 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS opctoplevel
