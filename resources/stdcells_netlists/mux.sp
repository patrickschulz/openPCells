* Created by KLayout

* cell mux
* pin A,B
* pin O
* pin VDD
* pin VSS
* pin SUBSTRATE
.SUBCKT mux A|B O VDD VSS SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 VDD A|B \$7 \$1 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0.5,1.2 slvtpfet
M$2 \$7 \$3 \$9 \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 1,1.2 slvtpfet
M$3 \$9 O VDD \$1 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $4 r0 *1 0,-1.2 slvtnfet
M$4 VSS A|B \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $5 r0 *1 0.5,-1.2 slvtnfet
M$5 \$8 \$3 \$10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $6 r0 *1 1,-1.2 slvtnfet
M$6 \$10 O VSS SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS mux
