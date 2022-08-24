* Created by KLayout

* cell latch_cell
* pin SUBSTRATE
.SUBCKT latch_cell SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 \$9 \$2 \$2 \$1 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$2 \$3 \$10 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 \$10 \$4 \$10 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 \$10 \$5 \$8 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 \$8 \$6 \$22 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 \$22 \$8 \$21 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 0,-1.2 slvtnfet
M$7 \$9 \$2 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 0.5,-1.2 slvtnfet
M$8 \$2 \$3 \$24 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $9 r0 *1 1,-1.2 slvtnfet
M$9 \$24 \$4 \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $10 r0 *1 1.5,-1.2 slvtnfet
M$10 \$7 \$5 \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 2,-1.2 slvtnfet
M$11 \$7 \$6 \$23 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $12 r0 *1 2.5,-1.2 slvtnfet
M$12 \$23 \$7 \$25 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS latch_cell
