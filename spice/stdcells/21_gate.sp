* Created by KLayout

* cell 21_gate
* pin A
* pin B1
* pin B2
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT 21_gate 2 3 4 5 6 7 8
* net 2 A
* net 3 B1
* net 4 B2
* net 5 O
* net 6 VDD
* net 7 VSS
* net 8 SUBSTRATE
* device instance $1 r0 *1 -1.5,1.2 slvtpfet
M$1 6 3 1 11 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -1,1.2 slvtpfet
M$2 1 4 6 11 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -0.5,1.2 slvtpfet
M$3 6 6 6 11 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $5 r0 *1 0.5,1.2 slvtpfet
M$5 6 2 10 11 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 1,1.2 slvtpfet
M$6 10 1 5 11 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 1.5,1.2 slvtpfet
M$7 5 6 6 11 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $8 r0 *1 -1.5,-1.2 slvtnfet
M$8 7 3 9 8 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $9 r0 *1 -1,-1.2 slvtnfet
M$9 9 4 1 8 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 -0.5,-1.2 slvtnfet
M$10 1 7 7 8 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 0,-1.2 slvtnfet
M$11 7 7 7 8 slvtnfet L=0.2U W=2U AS=0.3P AD=0.55P PS=2.6U PD=4.1U
* device instance $12 r0 *1 0.5,-1.2 slvtnfet
M$12 7 2 5 8 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $13 r0 *1 1,-1.2 slvtnfet
M$13 5 1 7 8 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
.ENDS 21_gate
