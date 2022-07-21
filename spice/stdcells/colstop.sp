* Created by KLayout

* cell colstop
* pin SUBSTRATE
.SUBCKT colstop SUBSTRATE
* device instance $1 r0 *1 -0.75,1.2 slvtpfet
M$1 \$12 \$2 \$11 \$1 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.25,1.2 slvtpfet
M$2 \$11 \$3 \$9 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.25,1.2 slvtpfet
M$3 \$9 \$4 \$10 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.75,1.2 slvtpfet
M$4 \$10 \$5 \$8 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $5 r0 *1 -0.75,-1.2 slvtnfet
M$5 \$17 \$2 \$16 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $6 r0 *1 -0.25,-1.2 slvtnfet
M$6 \$16 \$3 \$15 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $7 r0 *1 0.25,-1.2 slvtnfet
M$7 \$15 \$4 \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $8 r0 *1 0.75,-1.2 slvtnfet
M$8 \$14 \$5 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS colstop
