* Created by KLayout

* cell or_gate
* pin VSS
* pin VDD
* pin A
* pin B
* pin O
* pin SUBSTRATE
.SUBCKT or_gate 1 2 3 5 7 9
* net 1 VSS
* net 2 VDD
* net 3 A
* net 5 B
* net 7 O
* net 9 SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 2 3 8 6 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 8 5 4 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 4 2 2 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.25,1.2 slvtpfet
M$4 2 2 2 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 1.75,1.2 slvtpfet
M$5 2 4 7 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.25,1.2 slvtpfet
M$6 7 2 2 6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 -0.25,-1.2 slvtnfet
M$7 1 3 4 9 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 0.25,-1.2 slvtnfet
M$8 4 5 1 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 0.75,-1.2 slvtnfet
M$9 1 1 1 9 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $11 r0 *1 1.75,-1.2 slvtnfet
M$11 1 4 7 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 2.25,-1.2 slvtnfet
M$12 7 1 1 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS or_gate
