* Created by KLayout

* cell opctoplevel
* pin A
* pin B1
* pin B2
* pin C1
* pin C2
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT opctoplevel 4 5 6 7 8 9 10 11 12
* net 4 A
* net 5 B1
* net 6 B2
* net 7 C1
* net 8 C2
* net 9 O
* net 10 VDD
* net 11 VSS
* net 12 SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 10 7 19 20 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 19 8 15 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 15 10 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.25,1.2 slvtpfet
M$4 10 10 10 20 slvtpfet L=0.2U W=8U AS=1.2P AD=1.45P PS=10.4U PD=11.9U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 10 15 2 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 2 10 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.25,1.2 slvtpfet
M$8 10 4 16 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 3.75,1.2 slvtpfet
M$9 16 2 17 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.25,1.2 slvtpfet
M$10 17 10 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 5.25,1.2 slvtpfet
M$12 10 17 1 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 5.75,1.2 slvtpfet
M$13 1 10 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $15 r0 *1 6.75,1.2 slvtpfet
M$15 10 5 18 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $16 r0 *1 7.25,1.2 slvtpfet
M$16 18 6 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $19 r0 *1 8.75,1.2 slvtpfet
M$19 10 18 3 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $20 r0 *1 9.25,1.2 slvtpfet
M$20 3 10 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $22 r0 *1 10.25,1.2 slvtpfet
M$22 10 1 9 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 10.75,1.2 slvtpfet
M$23 9 3 10 20 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 -0.25,-1.2 slvtnfet
M$25 11 7 15 12 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $26 r0 *1 0.25,-1.2 slvtnfet
M$26 15 8 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $27 r0 *1 0.75,-1.2 slvtnfet
M$27 11 11 11 12 slvtnfet L=0.2U W=8U AS=1.2P AD=1.2P PS=10.4U PD=10.4U
* device instance $29 r0 *1 1.75,-1.2 slvtnfet
M$29 11 15 2 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $30 r0 *1 2.25,-1.2 slvtnfet
M$30 2 11 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $32 r0 *1 3.25,-1.2 slvtnfet
M$32 11 4 17 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $33 r0 *1 3.75,-1.2 slvtnfet
M$33 17 2 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $36 r0 *1 5.25,-1.2 slvtnfet
M$36 11 17 1 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $37 r0 *1 5.75,-1.2 slvtnfet
M$37 1 11 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $39 r0 *1 6.75,-1.2 slvtnfet
M$39 11 5 13 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $40 r0 *1 7.25,-1.2 slvtnfet
M$40 13 6 18 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $41 r0 *1 7.75,-1.2 slvtnfet
M$41 18 11 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $43 r0 *1 8.75,-1.2 slvtnfet
M$43 11 18 3 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $44 r0 *1 9.25,-1.2 slvtnfet
M$44 3 11 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $46 r0 *1 10.25,-1.2 slvtnfet
M$46 11 1 14 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $47 r0 *1 10.75,-1.2 slvtnfet
M$47 14 3 9 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $48 r0 *1 11.25,-1.2 slvtnfet
M$48 9 11 11 12 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS opctoplevel
