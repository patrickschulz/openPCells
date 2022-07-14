* Created by KLayout

* cell tbuf
* pin VSS
* pin VDD
* pin EN
* pin I
* pin O
* pin SUBSTRATE
.SUBCKT tbuf 1 2 3 4 6 9
* net 1 VSS
* net 2 VDD
* net 3 EN
* net 4 I
* net 6 O
* net 9 SUBSTRATE
* device instance $1 r0 *1 -1,1.2 slvtpfet
M$1 2 3 3 5 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 -0.5,1.2 slvtpfet
M$2 3 2 2 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 0,1.2 slvtpfet
M$3 2 2 6 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $4 r0 *1 0.5,1.2 slvtpfet
M$4 6 4 7 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 1,1.2 slvtpfet
M$5 7 3 2 5 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $6 r0 *1 -1,-1.2 slvtnfet
M$6 1 3 3 9 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $7 r0 *1 -0.5,-1.2 slvtnfet
M$7 3 1 1 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $8 r0 *1 0,-1.2 slvtnfet
M$8 1 1 6 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $9 r0 *1 0.5,-1.2 slvtnfet
M$9 6 4 8 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $10 r0 *1 1,-1.2 slvtnfet
M$10 8 3 1 9 slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS tbuf
