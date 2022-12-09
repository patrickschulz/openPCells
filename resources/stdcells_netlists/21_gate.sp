* Created by KLayout

* cell 21_gate
* pin A
* pin B1
* pin B2
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT 21_gate A B1 B2 O VDD VSS SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD B1 \$1 \$I1 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$1 B2 VDD \$I1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 VDD VDD VDD \$I1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 VDD A \$I14 \$I1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 \$I14 \$1 O \$I1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 O VDD VDD \$I1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $7 r0 *1 0,-1.2 slvtnfet
M$7 VSS B1 \$I19 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $8 r0 *1 0.5,-1.2 slvtnfet
M$8 \$I19 B2 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $9 r0 *1 1,-1.2 slvtnfet
M$9 \$1 VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 1.5,-1.2 slvtnfet
M$10 VSS A O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $11 r0 *1 2,-1.2 slvtnfet
M$11 O \$1 VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 2.5,-1.2 slvtnfet
M$12 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS 21_gate
