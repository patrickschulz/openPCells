* Created by KLayout

* cell latch_cell
* pin SUBSTRATE
.SUBCKT latch_cell SUBSTRATE
* device instance $1 r0 *1 -1.25,1.2 slvtpfet
M$1 \$8 \$1 \$1 \$10 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.75,1.2 slvtpfet
M$2 \$1 \$2 \$9 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -0.25,1.2 slvtpfet
M$3 \$9 \$3 \$9 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.25,1.2 slvtpfet
M$4 \$9 \$4 \$7 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 0.75,1.2 slvtpfet
M$5 \$7 \$5 \$12 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 1.25,1.2 slvtpfet
M$6 \$12 \$7 \$11 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 -1.25,-1.2 slvtnfet
M$7 \$8 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 -0.75,-1.2 slvtnfet
M$8 \$1 \$2 \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $9 r0 *1 -0.25,-1.2 slvtnfet
M$9 \$14 \$3 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $10 r0 *1 0.25,-1.2 slvtnfet
M$10 \$6 \$4 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 0.75,-1.2 slvtnfet
M$11 \$6 \$5 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $12 r0 *1 1.25,-1.2 slvtnfet
M$12 \$13 \$6 \$15 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS latch_cell
