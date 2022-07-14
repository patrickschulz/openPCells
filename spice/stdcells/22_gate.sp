* Created by KLayout

* cell 22_gate
* pin A1
* pin A2
* pin B1
* pin B2
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT 22_gate 3 4 5 6 7 8 9 10
* net 3 A1
* net 4 A2
* net 5 B1
* net 6 B2
* net 7 O
* net 8 VDD
* net 9 VSS
* net 10 SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 8 3 15 16 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 15 4 8 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 8 8 8 16 slvtpfet L=0.2U W=6U AS=0.9P AD=0.9P PS=7.8U PD=7.8U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 8 15 1 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 1 8 8 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.25,1.2 slvtpfet
M$8 8 5 13 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 3.75,1.2 slvtpfet
M$9 13 6 8 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 5.25,1.2 slvtpfet
M$12 8 13 2 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 5.75,1.2 slvtpfet
M$13 2 8 8 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 6.75,1.2 slvtpfet
M$15 8 2 14 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.25,1.2 slvtpfet
M$16 14 1 7 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $17 r0 *1 7.75,1.2 slvtpfet
M$17 7 8 8 16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $18 r0 *1 -0.25,-1.2 slvtnfet
M$18 9 3 12 10 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $19 r0 *1 0.25,-1.2 slvtnfet
M$19 12 4 15 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 0.75,-1.2 slvtnfet
M$20 15 9 9 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 1.25,-1.2 slvtnfet
M$21 9 9 9 10 slvtnfet L=0.2U W=5U AS=0.75P AD=1P PS=6.5U PD=8U
* device instance $22 r0 *1 1.75,-1.2 slvtnfet
M$22 9 15 1 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 2.25,-1.2 slvtnfet
M$23 1 9 9 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 3.25,-1.2 slvtnfet
M$25 9 5 11 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $26 r0 *1 3.75,-1.2 slvtnfet
M$26 11 6 13 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $27 r0 *1 4.25,-1.2 slvtnfet
M$27 13 9 9 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $29 r0 *1 5.25,-1.2 slvtnfet
M$29 9 13 2 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $30 r0 *1 5.75,-1.2 slvtnfet
M$30 2 9 9 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $32 r0 *1 6.75,-1.2 slvtnfet
M$32 9 2 7 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 7.25,-1.2 slvtnfet
M$33 7 1 9 10 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
.ENDS 22_gate
