* Created by KLayout

* cell nand_gate
* pin VSS
* pin VDD
* pin A
* pin O
* pin B
* pin SUBSTRATE
.SUBCKT nand_gate VSS VDD A O B SUBSTRATE
* device instance $1 r0 *1 -0.25,1.2 slvtpfet
M$1 VDD A O \$6 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.25,1.2 slvtpfet
M$2 O B VDD \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.75,1.2 slvtpfet
M$3 VDD VDD VDD \$6 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $4 r0 *1 -0.25,-1.2 slvtnfet
M$4 VSS A \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $5 r0 *1 0.25,-1.2 slvtnfet
M$5 \$7 B O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 0.75,-1.2 slvtnfet
M$6 O VSS VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS nand_gate
