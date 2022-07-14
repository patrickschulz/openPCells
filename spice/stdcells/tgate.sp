* Created by KLayout

* cell tgate
* pin EN,EP
* pin I
* pin O
* pin SUBSTRATE
.SUBCKT tgate 1 2 3 5
* net 1 EN,EP
* net 2 I
* net 3 O
* net 5 SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 2 1 3 4 slvtpfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
* device instance $2 r0 *1 0,-1.2 slvtnfet
M$2 2 1 3 5 slvtnfet L=0.2U W=1U AS=0.4P AD=0.4P PS=2.8U PD=2.8U
.ENDS tgate
