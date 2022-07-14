* Created by KLayout

* cell harness
* pin SUBSTRATE
.SUBCKT harness SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 \$6 \$1 \$5 \$2 slvtpfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 \$8 \$1 \$7 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
.ENDS harness
