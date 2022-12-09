* Created by KLayout

* cell tgate
* pin EN
* pin EP
* pin I
* pin O
* pin SUBSTRATE
.SUBCKT tgate EN EP I O SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 I EP O \$7 slvtpfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 I EN O SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
.ENDS tgate
