* Created by KLayout

* cell latch_cell
* pin SUBSTRATE
.SUBCKT latch_cell 15
* net 15 SUBSTRATE
* device instance $1 r0 *1 -1.25,1.2 slvtpfet
M$1 7 1 1 9 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.75,1.2 slvtpfet
M$2 1 2 8 9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -0.25,1.2 slvtpfet
M$3 8 3 8 9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.25,1.2 slvtpfet
M$4 8 4 6 9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 0.75,1.2 slvtpfet
M$5 6 5 11 9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 1.25,1.2 slvtpfet
M$6 11 6 10 9 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 -1.25,-1.2 slvtnfet
M$7 7 1 1 15 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 -0.75,-1.2 slvtnfet
M$8 1 2 13 15 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 -0.25,-1.2 slvtnfet
M$9 13 3 6 15 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 0.25,-1.2 slvtnfet
M$10 6 4 6 15 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 0.75,-1.2 slvtnfet
M$11 6 5 12 15 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 1.25,-1.2 slvtnfet
M$12 12 6 14 15 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS latch_cell
