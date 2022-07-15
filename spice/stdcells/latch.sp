* Created by KLayout

* cell latch
* pin VSS
* pin VDD
* pin D
* pin SUBSTRATE
.SUBCKT latch VSS VDD D SUBSTRATE
* device instance $1 r0 *1 -1.75,1.2 slvtpfet
M$1 VDD \$3 \$5 \$4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -1.25,1.2 slvtpfet
M$2 \$5 VDD VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -0.75,1.2 slvtpfet
M$3 VDD \$5 \$6 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -0.25,1.2 slvtpfet
M$4 \$6 VDD VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 0.25,1.2 slvtpfet
M$5 VDD VDD \$7 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 0.75,1.2 slvtpfet
M$6 \$7 \$8 \$17 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 1.25,1.2 slvtpfet
M$7 \$17 \$6 VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 1.75,1.2 slvtpfet
M$8 VDD D \$11 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 2.25,1.2 slvtpfet
M$9 \$11 VDD VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 2.75,1.2 slvtpfet
M$10 VDD VDD \$12 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 3.25,1.2 slvtpfet
M$11 \$12 \$13 \$20 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 3.75,1.2 slvtpfet
M$12 \$20 \$14 VDD \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $13 r0 *1 -1.75,-1.2 slvtnfet
M$13 VSS \$3 \$5 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $14 r0 *1 -1.25,-1.2 slvtnfet
M$14 \$5 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $15 r0 *1 -0.75,-1.2 slvtnfet
M$15 VSS \$5 \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 -0.25,-1.2 slvtnfet
M$16 \$6 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $17 r0 *1 0.25,-1.2 slvtnfet
M$17 VSS VSS \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $18 r0 *1 0.75,-1.2 slvtnfet
M$18 \$7 \$8 \$18 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 1.25,-1.2 slvtnfet
M$19 \$18 \$9 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 1.75,-1.2 slvtnfet
M$20 VSS D \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 2.25,-1.2 slvtnfet
M$21 \$11 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $22 r0 *1 2.75,-1.2 slvtnfet
M$22 VSS VSS \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 3.25,-1.2 slvtnfet
M$23 \$12 \$13 \$19 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 3.75,-1.2 slvtnfet
M$24 \$19 \$15 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS latch
