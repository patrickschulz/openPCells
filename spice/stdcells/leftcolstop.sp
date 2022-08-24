* Created by KLayout

* cell leftcolstop
* pin SUBSTRATE
.SUBCKT leftcolstop SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 \$2 \$2 \$7 \$4 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 \$1 \$1 \$8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
.ENDS leftcolstop
