* Created by KLayout

* cell tbuf
* pin VSS
* pin O
* pin I
* pin EN
* pin VDD
* pin SUBSTRATE
.SUBCKT tbuf VSS O I EN VDD SUBSTRATE
* device instance $1 r0 *1 -1,1.2 slvtpfet
M$1 VDD EN \$2 \$7 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.5,1.2 slvtpfet
M$2 \$2 VDD VDD \$7 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0,1.2 slvtpfet
M$3 VDD VDD O \$7 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.5,1.2 slvtpfet
M$4 O I \$9 \$7 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 1,1.2 slvtpfet
M$5 \$9 \$2 VDD \$7 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $6 r0 *1 -1,-1.2 slvtnfet
M$6 VSS EN \$2 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $7 r0 *1 -0.5,-1.2 slvtnfet
M$7 \$2 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 0,-1.2 slvtnfet
M$8 VSS VSS O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 0.5,-1.2 slvtnfet
M$9 O I \$4 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 1,-1.2 slvtnfet
M$10 \$4 EN VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS tbuf
