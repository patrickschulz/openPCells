* Created by KLayout

* cell opctoplevel
* pin VSS
* pin VDD
* pin I
* pin O
* pin SUBSTRATE
.SUBCKT opctoplevel 1 2 3 6 7
* net 1 VSS
* net 2 VDD
* net 3 I
* net 6 O
* net 7 SUBSTRATE
* device instance $1 r0 *1 -0.75,1.2 slvtpfet
M$1 2 3 5 4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.25,1.2 slvtpfet
M$2 5 2 2 4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0.25,1.2 slvtpfet
M$3 2 5 6 4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.75,1.2 slvtpfet
M$4 6 2 2 4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $5 r0 *1 -0.75,-1.2 slvtnfet
M$5 1 3 5 7 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $6 r0 *1 -0.25,-1.2 slvtnfet
M$6 5 1 1 7 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $7 r0 *1 0.25,-1.2 slvtnfet
M$7 1 5 6 7 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 0.75,-1.2 slvtnfet
M$8 6 1 1 7 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS opctoplevel
