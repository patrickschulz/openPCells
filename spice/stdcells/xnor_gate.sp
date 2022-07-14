* Created by KLayout

* cell xnor_gate
* pin VSS
* pin A,B
* pin VDD
* pin O
* pin SUBSTRATE
.SUBCKT xnor_gate 1 3 4 8 11
* net 1 VSS
* net 3 A,B
* net 4 VDD
* net 8 O
* net 11 SUBSTRATE
* device instance $1 r0 *1 -2.25,1.2 slvtpfet
M$1 4 3 3 5 slvtpfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $2 r0 *1 -1.75,1.2 slvtpfet
M$2 3 4 4 5 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $5 r0 *1 -0.25,1.2 slvtpfet
M$5 4 3 6 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 0.25,1.2 slvtpfet
M$6 6 3 6 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 0.75,1.2 slvtpfet
M$7 6 3 7 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 1.25,1.2 slvtpfet
M$8 7 3 10 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 1.75,1.2 slvtpfet
M$9 10 3 4 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 2.25,1.2 slvtpfet
M$10 4 3 4 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 2.75,1.2 slvtpfet
M$11 4 4 4 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 3.25,1.2 slvtpfet
M$12 4 7 8 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 3.75,1.2 slvtpfet
M$13 8 4 4 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $14 r0 *1 -2.25,-1.2 slvtnfet
M$14 1 3 3 11 slvtnfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $15 r0 *1 -1.75,-1.2 slvtnfet
M$15 3 1 1 11 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $18 r0 *1 -0.25,-1.2 slvtnfet
M$18 1 3 1 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 0.25,-1.2 slvtnfet
M$19 1 3 9 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 0.75,-1.2 slvtnfet
M$20 9 3 7 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 1.25,-1.2 slvtnfet
M$21 7 3 2 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 1.75,-1.2 slvtnfet
M$22 2 3 2 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 2.25,-1.2 slvtnfet
M$23 2 3 1 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $24 r0 *1 2.75,-1.2 slvtnfet
M$24 1 1 1 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 3.25,-1.2 slvtnfet
M$25 1 7 8 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $26 r0 *1 3.75,-1.2 slvtnfet
M$26 8 1 1 11 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS xnor_gate
