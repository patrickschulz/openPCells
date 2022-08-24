* Created by KLayout

* cell tbuf
* pin VSS
* pin EN
* pin I
* pin VDD
* pin SUBSTRATE
.SUBCKT tbuf VSS EN I VDD SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD EN \$6 \$10 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$6 VDD VDD \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 VDD VDD \$7 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 \$7 I \$13 \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 \$13 \$6 VDD \$10 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $6 r0 *1 0,-1.2 slvtnfet
M$6 VSS EN \$6 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $7 r0 *1 0.5,-1.2 slvtnfet
M$7 \$6 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 1,-1.2 slvtnfet
M$8 VSS VSS \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 1.5,-1.2 slvtnfet
M$9 \$7 I \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 2,-1.2 slvtnfet
M$10 \$8 EN VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS tbuf
