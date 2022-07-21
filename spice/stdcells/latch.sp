* Created by KLayout

* cell latch
* pin VSS
* pin D
* pin VDD
* pin SUBSTRATE
.SUBCKT latch VSS D VDD SUBSTRATE
* device instance $1 r0 *1 -1.75,1.2 slvtpfet
M$1 VDD \$11 \$2 \$12 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -1.25,1.2 slvtpfet
M$2 \$2 VDD VDD \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 -0.75,1.2 slvtpfet
M$3 VDD \$2 \$3 \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 -0.25,1.2 slvtpfet
M$4 \$3 VDD VDD \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 0.25,1.2 slvtpfet
M$5 VDD VDD \$4 \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 0.75,1.2 slvtpfet
M$6 \$4 \$13 \$19 \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 1.25,1.2 slvtpfet
M$7 \$19 \$3 VDD \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 1.75,1.2 slvtpfet
M$8 VDD D \$6 \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 2.25,1.2 slvtpfet
M$9 \$6 VDD VDD \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 2.75,1.2 slvtpfet
M$10 VDD VDD \$7 \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 3.25,1.2 slvtpfet
M$11 \$7 \$15 \$20 \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 3.75,1.2 slvtpfet
M$12 \$20 \$16 VDD \$12 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $13 r0 *1 -1.75,-1.2 slvtnfet
M$13 VSS \$11 \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $14 r0 *1 -1.25,-1.2 slvtnfet
M$14 \$2 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $15 r0 *1 -0.75,-1.2 slvtnfet
M$15 VSS \$2 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 -0.25,-1.2 slvtnfet
M$16 \$3 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $17 r0 *1 0.25,-1.2 slvtnfet
M$17 VSS VSS \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $18 r0 *1 0.75,-1.2 slvtnfet
M$18 \$4 \$13 \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 1.25,-1.2 slvtnfet
M$19 \$10 \$5 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 1.75,-1.2 slvtnfet
M$20 VSS D \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 2.25,-1.2 slvtnfet
M$21 \$6 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $22 r0 *1 2.75,-1.2 slvtnfet
M$22 VSS VSS \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $23 r0 *1 3.25,-1.2 slvtnfet
M$23 \$7 \$15 \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 3.75,-1.2 slvtnfet
M$24 \$9 \$8 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS latch
