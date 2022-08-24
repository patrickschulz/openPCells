* Created by KLayout

* cell or_gate
* pin VSS
* pin A
* pin O
* pin B
* pin VDD
* pin SUBSTRATE
.SUBCKT or_gate VSS A O B VDD SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD A \$12 \$6 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$12 B \$7 \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 \$7 VDD VDD \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 1.5,1.2 slvtpfet
M$4 VDD \$7 O \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 O VDD VDD \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $6 r0 *1 0,-1.2 slvtnfet
M$6 VSS A \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $7 r0 *1 0.5,-1.2 slvtnfet
M$7 \$7 B VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 1,-1.2 slvtnfet
M$8 VSS VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 1.5,-1.2 slvtnfet
M$9 VSS \$7 O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 2,-1.2 slvtnfet
M$10 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS or_gate
