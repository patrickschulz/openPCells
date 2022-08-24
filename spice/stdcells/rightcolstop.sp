* Created by KLayout

* cell rightcolstop
* pin SUBSTRATE
.SUBCKT rightcolstop SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 \$7 \$2 \$2 \$4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 \$8 \$1 \$1 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
.ENDS rightcolstop
