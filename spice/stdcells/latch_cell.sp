* Created by KLayout

* cell latch_cell
* pin SUBSTRATE
.SUBCKT latch_cell SUBSTRATE
* device instance $1 r0 *1 -1.25,1.2 slvtpfet
M$1 \$9 \$2 \$2 \$1 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.75,1.2 slvtpfet
M$2 \$2 \$3 \$10 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -0.25,1.2 slvtpfet
M$3 \$10 \$4 \$10 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.25,1.2 slvtpfet
M$4 \$10 \$5 \$8 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 0.75,1.2 slvtpfet
M$5 \$8 \$6 \$12 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 1.25,1.2 slvtpfet
M$6 \$12 \$8 \$11 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 -1.25,-1.2 slvtnfet
M$7 \$9 \$2 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 -0.75,-1.2 slvtnfet
M$8 \$2 \$3 \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $9 r0 *1 -0.25,-1.2 slvtnfet
M$9 \$14 \$4 \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $10 r0 *1 0.25,-1.2 slvtnfet
M$10 \$7 \$5 \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 0.75,-1.2 slvtnfet
M$11 \$7 \$6 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $12 r0 *1 1.25,-1.2 slvtnfet
M$12 \$13 \$7 \$15 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS latch_cell
