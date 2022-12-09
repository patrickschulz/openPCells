* Created by KLayout

* cell xor_gate
* pin VSS
* pin A,B,O
* pin VDD
* pin SUBSTRATE
.SUBCKT xor_gate VSS A|B|O VDD SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD A|B|O A|B|O \$14 slvtpfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 A|B|O VDD VDD \$14 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $5 r0 *1 2,1.2 slvtpfet
M$5 VDD A|B|O \$16 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $6 r0 *1 2.5,1.2 slvtpfet
M$6 \$16 A|B|O \$16 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 3,1.2 slvtpfet
M$7 \$16 A|B|O \$12 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 3.5,1.2 slvtpfet
M$8 \$12 A|B|O \$22 \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 4,1.2 slvtpfet
M$9 \$22 A|B|O VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 4.5,1.2 slvtpfet
M$10 VDD A|B|O VDD \$14 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $11 r0 *1 0,-1.2 slvtnfet
M$11 VSS A|B|O A|B|O SUBSTRATE slvtnfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U
+ PD=2.6U
* device instance $12 r0 *1 0.5,-1.2 slvtnfet
M$12 A|B|O VSS VSS SUBSTRATE slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U
+ PD=2.6U
* device instance $15 r0 *1 2,-1.2 slvtnfet
M$15 VSS A|B|O VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 2.5,-1.2 slvtnfet
M$16 VSS A|B|O \$13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $17 r0 *1 3,-1.2 slvtnfet
M$17 \$13 A|B|O \$12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $18 r0 *1 3.5,-1.2 slvtnfet
M$18 \$12 A|B|O \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 4,-1.2 slvtnfet
M$19 \$10 A|B|O \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 4.5,-1.2 slvtnfet
M$20 \$10 A|B|O VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
.ENDS xor_gate
