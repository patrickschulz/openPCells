* Created by KLayout

* cell latch
* pin VDD,VSS
* pin D
* pin SUBSTRATE
.SUBCKT latch VDD|VSS D SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD|VSS \$15 \$9 \$16 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$9 VDD|VSS VDD|VSS \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 VDD|VSS \$9 VDD|VSS \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 VDD|VSS VDD|VSS VDD|VSS \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 VDD|VSS \$17 \$26 \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 \$26 VDD|VSS VDD|VSS \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 VDD|VSS D \$11 \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.5,1.2 slvtpfet
M$8 \$11 VDD|VSS VDD|VSS \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $9 r0 *1 4,1.2 slvtpfet
M$9 VDD|VSS \$19 \$30 \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $10 r0 *1 4.5,1.2 slvtpfet
M$10 \$30 \$20 VDD|VSS \$16 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
* device instance $11 r0 *1 0,-1.2 slvtnfet
M$11 VDD|VSS \$15 \$9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $12 r0 *1 0.5,-1.2 slvtnfet
M$12 \$9 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $13 r0 *1 1,-1.2 slvtnfet
M$13 VDD|VSS \$9 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $14 r0 *1 1.5,-1.2 slvtnfet
M$14 VDD|VSS VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $15 r0 *1 2,-1.2 slvtnfet
M$15 VDD|VSS \$17 \$14 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 2.5,-1.2 slvtnfet
M$16 \$14 \$10 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $17 r0 *1 3,-1.2 slvtnfet
M$17 VDD|VSS D \$11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $18 r0 *1 3.5,-1.2 slvtnfet
M$18 \$11 VDD|VSS VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $19 r0 *1 4,-1.2 slvtnfet
M$19 VDD|VSS \$19 \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 4.5,-1.2 slvtnfet
M$20 \$13 \$12 VDD|VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS latch
