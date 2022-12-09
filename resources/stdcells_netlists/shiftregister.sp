* Created by KLayout

* cell shiftregister
* pin SUBSTRATE
.SUBCKT shiftregister SUBSTRATE
* device instance $1 r0 *1 44.25,1.2 slvtpfet
M$1 \$1 \$I10 \$I445 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $2 r0 *1 44.75,1.2 slvtpfet
M$2 \$I445 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $3 r0 *1 45.25,1.2 slvtpfet
M$3 \$1 \$I445 \$I484 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $4 r0 *1 45.75,1.2 slvtpfet
M$4 \$I484 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $5 r0 *1 46.25,1.2 slvtpfet
M$5 \$1 \$I445 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $6 r0 *1 46.75,1.2 slvtpfet
M$6 \$1 \$I484 \$I1159 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $7 r0 *1 47.25,1.2 slvtpfet
M$7 \$I1159 \$I10 \$I475 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $8 r0 *1 47.75,1.2 slvtpfet
M$8 \$I475 \$1 \$I475 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $9 r0 *1 48.25,1.2 slvtpfet
M$9 \$I475 \$I127 \$I1156 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $10 r0 *1 48.75,1.2 slvtpfet
M$10 \$I1156 \$I445 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $11 r0 *1 49.25,1.2 slvtpfet
M$11 \$1 \$I484 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $12 r0 *1 49.75,1.2 slvtpfet
M$12 \$1 \$I475 \$I127 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $13 r0 *1 50.25,1.2 slvtpfet
M$13 \$I127 \$I484 \$I127 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $14 r0 *1 50.75,1.2 slvtpfet
M$14 \$I127 \$I445 \$I469 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $15 r0 *1 51.25,1.2 slvtpfet
M$15 \$I469 \$1 \$I469 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $16 r0 *1 51.75,1.2 slvtpfet
M$16 \$I469 \$I120 \$I1184 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $17 r0 *1 52.25,1.2 slvtpfet
M$17 \$I1184 \$I484 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $19 r0 *1 53.25,1.2 slvtpfet
M$19 \$1 \$I469 \$I120 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $20 r0 *1 53.75,1.2 slvtpfet
M$20 \$I120 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $21 r0 *1 54.25,1.2 slvtpfet
M$21 \$1 \$I120 \$I11 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $22 r0 *1 54.75,1.2 slvtpfet
M$22 \$I11 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $23 r0 *1 55.25,1.2 slvtpfet
M$23 \$1 \$I11 \$I512 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $24 r0 *1 55.75,1.2 slvtpfet
M$24 \$I512 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $25 r0 *1 56.25,1.2 slvtpfet
M$25 \$1 \$I512 \$I510 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $26 r0 *1 56.75,1.2 slvtpfet
M$26 \$I510 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $27 r0 *1 57.25,1.2 slvtpfet
M$27 \$1 \$I512 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $28 r0 *1 57.75,1.2 slvtpfet
M$28 \$1 \$I510 \$I1196 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $29 r0 *1 58.25,1.2 slvtpfet
M$29 \$I1196 \$I11 \$I506 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $30 r0 *1 58.75,1.2 slvtpfet
M$30 \$I506 \$1 \$I506 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $31 r0 *1 59.25,1.2 slvtpfet
M$31 \$I506 \$I158 \$I1199 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $32 r0 *1 59.75,1.2 slvtpfet
M$32 \$I1199 \$I512 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $33 r0 *1 60.25,1.2 slvtpfet
M$33 \$1 \$I510 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $34 r0 *1 60.75,1.2 slvtpfet
M$34 \$1 \$I506 \$I158 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $35 r0 *1 61.25,1.2 slvtpfet
M$35 \$I158 \$I510 \$I158 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $36 r0 *1 61.75,1.2 slvtpfet
M$36 \$I158 \$I512 \$I500 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $37 r0 *1 62.25,1.2 slvtpfet
M$37 \$I500 \$1 \$I500 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $38 r0 *1 62.75,1.2 slvtpfet
M$38 \$I500 \$I151 \$I1206 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $39 r0 *1 63.25,1.2 slvtpfet
M$39 \$I1206 \$I510 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $41 r0 *1 64.25,1.2 slvtpfet
M$41 \$1 \$I500 \$I151 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $42 r0 *1 64.75,1.2 slvtpfet
M$42 \$I151 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $43 r0 *1 65.25,1.2 slvtpfet
M$43 \$1 \$I151 \$I12 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $44 r0 *1 65.75,1.2 slvtpfet
M$44 \$I12 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $45 r0 *1 66.25,1.2 slvtpfet
M$45 \$1 \$I12 \$I442 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $46 r0 *1 66.75,1.2 slvtpfet
M$46 \$I442 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $47 r0 *1 67.25,1.2 slvtpfet
M$47 \$1 \$I442 \$I523 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $48 r0 *1 67.75,1.2 slvtpfet
M$48 \$I523 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $49 r0 *1 68.25,1.2 slvtpfet
M$49 \$1 \$I442 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $50 r0 *1 68.75,1.2 slvtpfet
M$50 \$1 \$I523 \$I1307 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $51 r0 *1 69.25,1.2 slvtpfet
M$51 \$I1307 \$I12 \$I519 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $52 r0 *1 69.75,1.2 slvtpfet
M$52 \$I519 \$1 \$I519 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $53 r0 *1 70.25,1.2 slvtpfet
M$53 \$I519 \$I224 \$I1316 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $54 r0 *1 70.75,1.2 slvtpfet
M$54 \$I1316 \$I442 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $55 r0 *1 71.25,1.2 slvtpfet
M$55 \$1 \$I523 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $56 r0 *1 71.75,1.2 slvtpfet
M$56 \$1 \$I519 \$I224 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $57 r0 *1 72.25,1.2 slvtpfet
M$57 \$I224 \$I523 \$I224 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $58 r0 *1 72.75,1.2 slvtpfet
M$58 \$I224 \$I442 \$I566 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $59 r0 *1 73.25,1.2 slvtpfet
M$59 \$I566 \$1 \$I566 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $60 r0 *1 73.75,1.2 slvtpfet
M$60 \$I566 \$I217 \$I1318 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $61 r0 *1 74.25,1.2 slvtpfet
M$61 \$I1318 \$I523 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $63 r0 *1 75.25,1.2 slvtpfet
M$63 \$1 \$I566 \$I217 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $64 r0 *1 75.75,1.2 slvtpfet
M$64 \$I217 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $65 r0 *1 76.25,1.2 slvtpfet
M$65 \$1 \$I217 \$I13 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $66 r0 *1 76.75,1.2 slvtpfet
M$66 \$I13 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $67 r0 *1 77.25,1.2 slvtpfet
M$67 \$1 \$I13 \$I556 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $68 r0 *1 77.75,1.2 slvtpfet
M$68 \$I556 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $69 r0 *1 78.25,1.2 slvtpfet
M$69 \$1 \$I556 \$I554 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $70 r0 *1 78.75,1.2 slvtpfet
M$70 \$I554 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $71 r0 *1 79.25,1.2 slvtpfet
M$71 \$1 \$I556 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $72 r0 *1 79.75,1.2 slvtpfet
M$72 \$1 \$I554 \$I1282 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $73 r0 *1 80.25,1.2 slvtpfet
M$73 \$I1282 \$I13 \$I550 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $74 r0 *1 80.75,1.2 slvtpfet
M$74 \$I550 \$1 \$I550 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $75 r0 *1 81.25,1.2 slvtpfet
M$75 \$I550 \$I202 \$I1285 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $76 r0 *1 81.75,1.2 slvtpfet
M$76 \$I1285 \$I556 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $77 r0 *1 82.25,1.2 slvtpfet
M$77 \$1 \$I554 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $78 r0 *1 82.75,1.2 slvtpfet
M$78 \$1 \$I550 \$I202 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $79 r0 *1 83.25,1.2 slvtpfet
M$79 \$I202 \$I554 \$I202 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $80 r0 *1 83.75,1.2 slvtpfet
M$80 \$I202 \$I556 \$I489 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $81 r0 *1 84.25,1.2 slvtpfet
M$81 \$I489 \$1 \$I489 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $82 r0 *1 84.75,1.2 slvtpfet
M$82 \$I489 \$I136 \$I1292 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $83 r0 *1 85.25,1.2 slvtpfet
M$83 \$I1292 \$I554 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $85 r0 *1 86.25,1.2 slvtpfet
M$85 \$1 \$I489 \$I136 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $86 r0 *1 86.75,1.2 slvtpfet
M$86 \$I136 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $87 r0 *1 87.25,1.2 slvtpfet
M$87 \$1 \$I136 \$I477 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $88 r0 *1 87.75,1.2 slvtpfet
M$88 \$I477 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U PD=2.8U
* device instance $89 r0 *1 0.25,1.2 slvtpfet
M$89 \$1 \$I36 \$I51 \$I43 slvtpfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $90 r0 *1 0.75,1.2 slvtpfet
M$90 \$I51 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $91 r0 *1 1.25,1.2 slvtpfet
M$91 \$1 \$I51 \$I404 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $92 r0 *1 1.75,1.2 slvtpfet
M$92 \$I404 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $93 r0 *1 2.25,1.2 slvtpfet
M$93 \$1 \$I51 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $94 r0 *1 2.75,1.2 slvtpfet
M$94 \$1 \$I404 \$I1239 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $95 r0 *1 3.25,1.2 slvtpfet
M$95 \$I1239 \$I62 \$I408 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $96 r0 *1 3.75,1.2 slvtpfet
M$96 \$I408 \$1 \$I408 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $97 r0 *1 4.25,1.2 slvtpfet
M$97 \$I408 \$I64 \$I1265 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $98 r0 *1 4.75,1.2 slvtpfet
M$98 \$I1265 \$I51 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $99 r0 *1 5.25,1.2 slvtpfet
M$99 \$1 \$I404 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $100 r0 *1 5.75,1.2 slvtpfet
M$100 \$1 \$I408 \$I64 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $101 r0 *1 6.25,1.2 slvtpfet
M$101 \$I64 \$I404 \$I64 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $102 r0 *1 6.75,1.2 slvtpfet
M$102 \$I64 \$I51 \$I448 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $103 r0 *1 7.25,1.2 slvtpfet
M$103 \$I448 \$1 \$I448 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $104 r0 *1 7.75,1.2 slvtpfet
M$104 \$I448 \$I105 \$I1272 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $105 r0 *1 8.25,1.2 slvtpfet
M$105 \$I1272 \$I404 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $107 r0 *1 9.25,1.2 slvtpfet
M$107 \$1 \$I448 \$I105 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $108 r0 *1 9.75,1.2 slvtpfet
M$108 \$I105 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $109 r0 *1 10.25,1.2 slvtpfet
M$109 \$1 \$I105 \$I22 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $110 r0 *1 10.75,1.2 slvtpfet
M$110 \$I22 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $111 r0 *1 11.25,1.2 slvtpfet
M$111 \$1 \$I22 \$I458 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $112 r0 *1 11.75,1.2 slvtpfet
M$112 \$I458 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $113 r0 *1 12.25,1.2 slvtpfet
M$113 \$1 \$I458 \$I460 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $114 r0 *1 12.75,1.2 slvtpfet
M$114 \$I460 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $115 r0 *1 13.25,1.2 slvtpfet
M$115 \$1 \$I458 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $116 r0 *1 13.75,1.2 slvtpfet
M$116 \$1 \$I460 \$I1221 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $117 r0 *1 14.25,1.2 slvtpfet
M$117 \$I1221 \$I22 \$I464 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $118 r0 *1 14.75,1.2 slvtpfet
M$118 \$I464 \$1 \$I464 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $119 r0 *1 15.25,1.2 slvtpfet
M$119 \$I464 \$I83 \$I1224 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $120 r0 *1 15.75,1.2 slvtpfet
M$120 \$I1224 \$I458 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $121 r0 *1 16.25,1.2 slvtpfet
M$121 \$1 \$I460 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $122 r0 *1 16.75,1.2 slvtpfet
M$122 \$1 \$I464 \$I83 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $123 r0 *1 17.25,1.2 slvtpfet
M$123 \$I83 \$I460 \$I83 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $124 r0 *1 17.75,1.2 slvtpfet
M$124 \$I83 \$I458 \$I433 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $125 r0 *1 18.25,1.2 slvtpfet
M$125 \$I433 \$1 \$I433 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $126 r0 *1 18.75,1.2 slvtpfet
M$126 \$I433 \$I90 \$I1231 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $127 r0 *1 19.25,1.2 slvtpfet
M$127 \$I1231 \$I460 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $129 r0 *1 20.25,1.2 slvtpfet
M$129 \$1 \$I433 \$I90 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $130 r0 *1 20.75,1.2 slvtpfet
M$130 \$I90 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $131 r0 *1 21.25,1.2 slvtpfet
M$131 \$1 \$I90 \$I8 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $132 r0 *1 21.75,1.2 slvtpfet
M$132 \$I8 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $133 r0 *1 22.25,1.2 slvtpfet
M$133 \$1 \$I8 \$I505 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $134 r0 *1 22.75,1.2 slvtpfet
M$134 \$I505 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $135 r0 *1 23.25,1.2 slvtpfet
M$135 \$1 \$I505 \$I526 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $136 r0 *1 23.75,1.2 slvtpfet
M$136 \$I526 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $137 r0 *1 24.25,1.2 slvtpfet
M$137 \$1 \$I505 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $138 r0 *1 24.75,1.2 slvtpfet
M$138 \$1 \$I526 \$I1146 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $139 r0 *1 25.25,1.2 slvtpfet
M$139 \$I1146 \$I8 \$I530 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $140 r0 *1 25.75,1.2 slvtpfet
M$140 \$I530 \$1 \$I530 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $141 r0 *1 26.25,1.2 slvtpfet
M$141 \$I530 \$I172 \$I1164 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $142 r0 *1 26.75,1.2 slvtpfet
M$142 \$I1164 \$I505 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $143 r0 *1 27.25,1.2 slvtpfet
M$143 \$1 \$I526 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $144 r0 *1 27.75,1.2 slvtpfet
M$144 \$1 \$I530 \$I172 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $145 r0 *1 28.25,1.2 slvtpfet
M$145 \$I172 \$I526 \$I172 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $146 r0 *1 28.75,1.2 slvtpfet
M$146 \$I172 \$I505 \$I536 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $147 r0 *1 29.25,1.2 slvtpfet
M$147 \$I536 \$1 \$I536 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $148 r0 *1 29.75,1.2 slvtpfet
M$148 \$I536 \$I193 \$I1171 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $149 r0 *1 30.25,1.2 slvtpfet
M$149 \$I1171 \$I526 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $151 r0 *1 31.25,1.2 slvtpfet
M$151 \$1 \$I536 \$I193 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $152 r0 *1 31.75,1.2 slvtpfet
M$152 \$I193 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $153 r0 *1 32.25,1.2 slvtpfet
M$153 \$1 \$I193 \$I9 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $154 r0 *1 32.75,1.2 slvtpfet
M$154 \$I9 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $155 r0 *1 33.25,1.2 slvtpfet
M$155 \$1 \$I9 \$I402 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $156 r0 *1 33.75,1.2 slvtpfet
M$156 \$I402 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $157 r0 *1 34.25,1.2 slvtpfet
M$157 \$1 \$I402 \$I399 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $158 r0 *1 34.75,1.2 slvtpfet
M$158 \$I399 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $159 r0 *1 35.25,1.2 slvtpfet
M$159 \$1 \$I402 \$1 \$I43 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $160 r0 *1 35.75,1.2 slvtpfet
M$160 \$1 \$I399 \$I1246 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $161 r0 *1 36.25,1.2 slvtpfet
M$161 \$I1246 \$I9 \$I415 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $162 r0 *1 36.75,1.2 slvtpfet
M$162 \$I415 \$1 \$I415 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $163 r0 *1 37.25,1.2 slvtpfet
M$163 \$I415 \$I71 \$I1249 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $164 r0 *1 37.75,1.2 slvtpfet
M$164 \$I1249 \$I402 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $165 r0 *1 38.25,1.2 slvtpfet
M$165 \$1 \$I399 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $166 r0 *1 38.75,1.2 slvtpfet
M$166 \$1 \$I415 \$I71 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $167 r0 *1 39.25,1.2 slvtpfet
M$167 \$I71 \$I399 \$I71 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $168 r0 *1 39.75,1.2 slvtpfet
M$168 \$I71 \$I402 \$I421 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $169 r0 *1 40.25,1.2 slvtpfet
M$169 \$I421 \$1 \$I421 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $170 r0 *1 40.75,1.2 slvtpfet
M$170 \$I421 \$I78 \$I1256 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $171 r0 *1 41.25,1.2 slvtpfet
M$171 \$I1256 \$I399 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $173 r0 *1 42.25,1.2 slvtpfet
M$173 \$1 \$I421 \$I78 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $174 r0 *1 42.75,1.2 slvtpfet
M$174 \$I78 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $175 r0 *1 43.25,1.2 slvtpfet
M$175 \$1 \$I78 \$I10 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $176 r0 *1 43.75,1.2 slvtpfet
M$176 \$I10 \$1 \$1 \$I43 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $177 r0 *1 44.25,-1.2 slvtnfet
M$177 \$3 \$I10 \$I445 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $178 r0 *1 44.75,-1.2 slvtnfet
M$178 \$I445 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $179 r0 *1 45.25,-1.2 slvtnfet
M$179 \$3 \$I445 \$I484 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $180 r0 *1 45.75,-1.2 slvtnfet
M$180 \$I484 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $181 r0 *1 46.25,-1.2 slvtnfet
M$181 \$3 \$I445 \$I486 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $182 r0 *1 46.75,-1.2 slvtnfet
M$182 \$I486 \$I484 \$I486 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $183 r0 *1 47.25,-1.2 slvtnfet
M$183 \$I486 \$I10 \$I475 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $184 r0 *1 47.75,-1.2 slvtnfet
M$184 \$I475 \$3 \$I475 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $185 r0 *1 48.25,-1.2 slvtnfet
M$185 \$I475 \$I127 \$I473 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $186 r0 *1 48.75,-1.2 slvtnfet
M$186 \$I473 \$I445 \$I473 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $187 r0 *1 49.25,-1.2 slvtnfet
M$187 \$I473 \$I484 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $188 r0 *1 49.75,-1.2 slvtnfet
M$188 \$3 \$I475 \$I127 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $189 r0 *1 50.25,-1.2 slvtnfet
M$189 \$I127 \$I484 \$I469 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $190 r0 *1 50.75,-1.2 slvtnfet
M$190 \$I469 \$I445 \$I469 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $191 r0 *1 51.25,-1.2 slvtnfet
M$191 \$I469 \$3 \$I469 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $192 r0 *1 51.75,-1.2 slvtnfet
M$192 \$I469 \$I120 \$I466 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $193 r0 *1 52.25,-1.2 slvtnfet
M$193 \$I466 \$I484 \$I466 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $194 r0 *1 52.75,-1.2 slvtnfet
M$194 \$I466 \$I445 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $195 r0 *1 53.25,-1.2 slvtnfet
M$195 \$3 \$I469 \$I120 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $196 r0 *1 53.75,-1.2 slvtnfet
M$196 \$I120 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $197 r0 *1 54.25,-1.2 slvtnfet
M$197 \$3 \$I120 \$I11 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $198 r0 *1 54.75,-1.2 slvtnfet
M$198 \$I11 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $199 r0 *1 55.25,-1.2 slvtnfet
M$199 \$3 \$I11 \$I512 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $200 r0 *1 55.75,-1.2 slvtnfet
M$200 \$I512 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $201 r0 *1 56.25,-1.2 slvtnfet
M$201 \$3 \$I512 \$I510 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $202 r0 *1 56.75,-1.2 slvtnfet
M$202 \$I510 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $203 r0 *1 57.25,-1.2 slvtnfet
M$203 \$3 \$I512 \$I508 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $204 r0 *1 57.75,-1.2 slvtnfet
M$204 \$I508 \$I510 \$I508 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $205 r0 *1 58.25,-1.2 slvtnfet
M$205 \$I508 \$I11 \$I506 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $206 r0 *1 58.75,-1.2 slvtnfet
M$206 \$I506 \$3 \$I506 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $207 r0 *1 59.25,-1.2 slvtnfet
M$207 \$I506 \$I158 \$I504 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $208 r0 *1 59.75,-1.2 slvtnfet
M$208 \$I504 \$I512 \$I504 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $209 r0 *1 60.25,-1.2 slvtnfet
M$209 \$I504 \$I510 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $210 r0 *1 60.75,-1.2 slvtnfet
M$210 \$3 \$I506 \$I158 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $211 r0 *1 61.25,-1.2 slvtnfet
M$211 \$I158 \$I510 \$I500 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $212 r0 *1 61.75,-1.2 slvtnfet
M$212 \$I500 \$I512 \$I500 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $213 r0 *1 62.25,-1.2 slvtnfet
M$213 \$I500 \$3 \$I500 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $214 r0 *1 62.75,-1.2 slvtnfet
M$214 \$I500 \$I151 \$I497 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $215 r0 *1 63.25,-1.2 slvtnfet
M$215 \$I497 \$I510 \$I497 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $216 r0 *1 63.75,-1.2 slvtnfet
M$216 \$I497 \$I512 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $217 r0 *1 64.25,-1.2 slvtnfet
M$217 \$3 \$I500 \$I151 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $218 r0 *1 64.75,-1.2 slvtnfet
M$218 \$I151 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $219 r0 *1 65.25,-1.2 slvtnfet
M$219 \$3 \$I151 \$I12 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $220 r0 *1 65.75,-1.2 slvtnfet
M$220 \$I12 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $221 r0 *1 66.25,-1.2 slvtnfet
M$221 \$3 \$I12 \$I442 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $222 r0 *1 66.75,-1.2 slvtnfet
M$222 \$I442 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $223 r0 *1 67.25,-1.2 slvtnfet
M$223 \$3 \$I442 \$I523 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $224 r0 *1 67.75,-1.2 slvtnfet
M$224 \$I523 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $225 r0 *1 68.25,-1.2 slvtnfet
M$225 \$3 \$I442 \$I521 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $226 r0 *1 68.75,-1.2 slvtnfet
M$226 \$I521 \$I523 \$I521 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $227 r0 *1 69.25,-1.2 slvtnfet
M$227 \$I521 \$I12 \$I519 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $228 r0 *1 69.75,-1.2 slvtnfet
M$228 \$I519 \$3 \$I519 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $229 r0 *1 70.25,-1.2 slvtnfet
M$229 \$I519 \$I224 \$I570 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $230 r0 *1 70.75,-1.2 slvtnfet
M$230 \$I570 \$I442 \$I570 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $231 r0 *1 71.25,-1.2 slvtnfet
M$231 \$I570 \$I523 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $232 r0 *1 71.75,-1.2 slvtnfet
M$232 \$3 \$I519 \$I224 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $233 r0 *1 72.25,-1.2 slvtnfet
M$233 \$I224 \$I523 \$I566 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $234 r0 *1 72.75,-1.2 slvtnfet
M$234 \$I566 \$I442 \$I566 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $235 r0 *1 73.25,-1.2 slvtnfet
M$235 \$I566 \$3 \$I566 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $236 r0 *1 73.75,-1.2 slvtnfet
M$236 \$I566 \$I217 \$I563 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $237 r0 *1 74.25,-1.2 slvtnfet
M$237 \$I563 \$I523 \$I563 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $238 r0 *1 74.75,-1.2 slvtnfet
M$238 \$I563 \$I442 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $239 r0 *1 75.25,-1.2 slvtnfet
M$239 \$3 \$I566 \$I217 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $240 r0 *1 75.75,-1.2 slvtnfet
M$240 \$I217 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $241 r0 *1 76.25,-1.2 slvtnfet
M$241 \$3 \$I217 \$I13 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $242 r0 *1 76.75,-1.2 slvtnfet
M$242 \$I13 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $243 r0 *1 77.25,-1.2 slvtnfet
M$243 \$3 \$I13 \$I556 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $244 r0 *1 77.75,-1.2 slvtnfet
M$244 \$I556 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $245 r0 *1 78.25,-1.2 slvtnfet
M$245 \$3 \$I556 \$I554 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $246 r0 *1 78.75,-1.2 slvtnfet
M$246 \$I554 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $247 r0 *1 79.25,-1.2 slvtnfet
M$247 \$3 \$I556 \$I552 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $248 r0 *1 79.75,-1.2 slvtnfet
M$248 \$I552 \$I554 \$I552 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $249 r0 *1 80.25,-1.2 slvtnfet
M$249 \$I552 \$I13 \$I550 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $250 r0 *1 80.75,-1.2 slvtnfet
M$250 \$I550 \$3 \$I550 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $251 r0 *1 81.25,-1.2 slvtnfet
M$251 \$I550 \$I202 \$I548 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $252 r0 *1 81.75,-1.2 slvtnfet
M$252 \$I548 \$I556 \$I548 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $253 r0 *1 82.25,-1.2 slvtnfet
M$253 \$I548 \$I554 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $254 r0 *1 82.75,-1.2 slvtnfet
M$254 \$3 \$I550 \$I202 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $255 r0 *1 83.25,-1.2 slvtnfet
M$255 \$I202 \$I554 \$I489 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $256 r0 *1 83.75,-1.2 slvtnfet
M$256 \$I489 \$I556 \$I489 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $257 r0 *1 84.25,-1.2 slvtnfet
M$257 \$I489 \$3 \$I489 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $258 r0 *1 84.75,-1.2 slvtnfet
M$258 \$I489 \$I136 \$I482 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $259 r0 *1 85.25,-1.2 slvtnfet
M$259 \$I482 \$I554 \$I482 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $260 r0 *1 85.75,-1.2 slvtnfet
M$260 \$I482 \$I556 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $261 r0 *1 86.25,-1.2 slvtnfet
M$261 \$3 \$I489 \$I136 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $262 r0 *1 86.75,-1.2 slvtnfet
M$262 \$I136 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $263 r0 *1 87.25,-1.2 slvtnfet
M$263 \$3 \$I136 \$I477 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $264 r0 *1 87.75,-1.2 slvtnfet
M$264 \$I477 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.4P PS=1.3U
+ PD=2.8U
* device instance $265 r0 *1 0.25,-1.2 slvtnfet
M$265 \$3 \$I36 \$I51 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U
+ PD=1.3U
* device instance $266 r0 *1 0.75,-1.2 slvtnfet
M$266 \$I51 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $267 r0 *1 1.25,-1.2 slvtnfet
M$267 \$3 \$I51 \$I404 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $268 r0 *1 1.75,-1.2 slvtnfet
M$268 \$I404 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $269 r0 *1 2.25,-1.2 slvtnfet
M$269 \$3 \$I51 \$I406 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $270 r0 *1 2.75,-1.2 slvtnfet
M$270 \$I406 \$I404 \$I406 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $271 r0 *1 3.25,-1.2 slvtnfet
M$271 \$I406 \$I62 \$I408 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $272 r0 *1 3.75,-1.2 slvtnfet
M$272 \$I408 \$3 \$I408 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $273 r0 *1 4.25,-1.2 slvtnfet
M$273 \$I408 \$I64 \$I410 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $274 r0 *1 4.75,-1.2 slvtnfet
M$274 \$I410 \$I51 \$I410 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $275 r0 *1 5.25,-1.2 slvtnfet
M$275 \$I410 \$I404 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $276 r0 *1 5.75,-1.2 slvtnfet
M$276 \$3 \$I408 \$I64 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $277 r0 *1 6.25,-1.2 slvtnfet
M$277 \$I64 \$I404 \$I448 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $278 r0 *1 6.75,-1.2 slvtnfet
M$278 \$I448 \$I51 \$I448 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $279 r0 *1 7.25,-1.2 slvtnfet
M$279 \$I448 \$3 \$I448 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $280 r0 *1 7.75,-1.2 slvtnfet
M$280 \$I448 \$I105 \$I451 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $281 r0 *1 8.25,-1.2 slvtnfet
M$281 \$I451 \$I404 \$I451 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $282 r0 *1 8.75,-1.2 slvtnfet
M$282 \$I451 \$I51 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $283 r0 *1 9.25,-1.2 slvtnfet
M$283 \$3 \$I448 \$I105 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $284 r0 *1 9.75,-1.2 slvtnfet
M$284 \$I105 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $285 r0 *1 10.25,-1.2 slvtnfet
M$285 \$3 \$I105 \$I22 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $286 r0 *1 10.75,-1.2 slvtnfet
M$286 \$I22 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $287 r0 *1 11.25,-1.2 slvtnfet
M$287 \$3 \$I22 \$I458 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $288 r0 *1 11.75,-1.2 slvtnfet
M$288 \$I458 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $289 r0 *1 12.25,-1.2 slvtnfet
M$289 \$3 \$I458 \$I460 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $290 r0 *1 12.75,-1.2 slvtnfet
M$290 \$I460 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $291 r0 *1 13.25,-1.2 slvtnfet
M$291 \$3 \$I458 \$I462 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $292 r0 *1 13.75,-1.2 slvtnfet
M$292 \$I462 \$I460 \$I462 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $293 r0 *1 14.25,-1.2 slvtnfet
M$293 \$I462 \$I22 \$I464 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $294 r0 *1 14.75,-1.2 slvtnfet
M$294 \$I464 \$3 \$I464 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $295 r0 *1 15.25,-1.2 slvtnfet
M$295 \$I464 \$I83 \$I429 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $296 r0 *1 15.75,-1.2 slvtnfet
M$296 \$I429 \$I458 \$I429 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $297 r0 *1 16.25,-1.2 slvtnfet
M$297 \$I429 \$I460 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $298 r0 *1 16.75,-1.2 slvtnfet
M$298 \$3 \$I464 \$I83 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $299 r0 *1 17.25,-1.2 slvtnfet
M$299 \$I83 \$I460 \$I433 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $300 r0 *1 17.75,-1.2 slvtnfet
M$300 \$I433 \$I458 \$I433 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $301 r0 *1 18.25,-1.2 slvtnfet
M$301 \$I433 \$3 \$I433 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $302 r0 *1 18.75,-1.2 slvtnfet
M$302 \$I433 \$I90 \$I436 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $303 r0 *1 19.25,-1.2 slvtnfet
M$303 \$I436 \$I460 \$I436 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $304 r0 *1 19.75,-1.2 slvtnfet
M$304 \$I436 \$I458 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $305 r0 *1 20.25,-1.2 slvtnfet
M$305 \$3 \$I433 \$I90 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $306 r0 *1 20.75,-1.2 slvtnfet
M$306 \$I90 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $307 r0 *1 21.25,-1.2 slvtnfet
M$307 \$3 \$I90 \$I8 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $308 r0 *1 21.75,-1.2 slvtnfet
M$308 \$I8 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $309 r0 *1 22.25,-1.2 slvtnfet
M$309 \$3 \$I8 \$I505 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $310 r0 *1 22.75,-1.2 slvtnfet
M$310 \$I505 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $311 r0 *1 23.25,-1.2 slvtnfet
M$311 \$3 \$I505 \$I526 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $312 r0 *1 23.75,-1.2 slvtnfet
M$312 \$I526 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $313 r0 *1 24.25,-1.2 slvtnfet
M$313 \$3 \$I505 \$I528 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $314 r0 *1 24.75,-1.2 slvtnfet
M$314 \$I528 \$I526 \$I528 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $315 r0 *1 25.25,-1.2 slvtnfet
M$315 \$I528 \$I8 \$I530 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $316 r0 *1 25.75,-1.2 slvtnfet
M$316 \$I530 \$3 \$I530 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $317 r0 *1 26.25,-1.2 slvtnfet
M$317 \$I530 \$I172 \$I518 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $318 r0 *1 26.75,-1.2 slvtnfet
M$318 \$I518 \$I505 \$I518 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $319 r0 *1 27.25,-1.2 slvtnfet
M$319 \$I518 \$I526 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $320 r0 *1 27.75,-1.2 slvtnfet
M$320 \$3 \$I530 \$I172 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $321 r0 *1 28.25,-1.2 slvtnfet
M$321 \$I172 \$I526 \$I536 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $322 r0 *1 28.75,-1.2 slvtnfet
M$322 \$I536 \$I505 \$I536 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $323 r0 *1 29.25,-1.2 slvtnfet
M$323 \$I536 \$3 \$I536 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $324 r0 *1 29.75,-1.2 slvtnfet
M$324 \$I536 \$I193 \$I539 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $325 r0 *1 30.25,-1.2 slvtnfet
M$325 \$I539 \$I526 \$I539 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $326 r0 *1 30.75,-1.2 slvtnfet
M$326 \$I539 \$I505 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $327 r0 *1 31.25,-1.2 slvtnfet
M$327 \$3 \$I536 \$I193 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $328 r0 *1 31.75,-1.2 slvtnfet
M$328 \$I193 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $329 r0 *1 32.25,-1.2 slvtnfet
M$329 \$3 \$I193 \$I9 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $330 r0 *1 32.75,-1.2 slvtnfet
M$330 \$I9 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $331 r0 *1 33.25,-1.2 slvtnfet
M$331 \$3 \$I9 \$I402 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $332 r0 *1 33.75,-1.2 slvtnfet
M$332 \$I402 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $333 r0 *1 34.25,-1.2 slvtnfet
M$333 \$3 \$I402 \$I399 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $334 r0 *1 34.75,-1.2 slvtnfet
M$334 \$I399 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $335 r0 *1 35.25,-1.2 slvtnfet
M$335 \$3 \$I402 \$I412 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $336 r0 *1 35.75,-1.2 slvtnfet
M$336 \$I412 \$I399 \$I412 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $337 r0 *1 36.25,-1.2 slvtnfet
M$337 \$I412 \$I9 \$I415 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $338 r0 *1 36.75,-1.2 slvtnfet
M$338 \$I415 \$3 \$I415 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $339 r0 *1 37.25,-1.2 slvtnfet
M$339 \$I415 \$I71 \$I417 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $340 r0 *1 37.75,-1.2 slvtnfet
M$340 \$I417 \$I402 \$I417 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $341 r0 *1 38.25,-1.2 slvtnfet
M$341 \$I417 \$I399 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $342 r0 *1 38.75,-1.2 slvtnfet
M$342 \$3 \$I415 \$I71 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $343 r0 *1 39.25,-1.2 slvtnfet
M$343 \$I71 \$I399 \$I421 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $344 r0 *1 39.75,-1.2 slvtnfet
M$344 \$I421 \$I402 \$I421 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $345 r0 *1 40.25,-1.2 slvtnfet
M$345 \$I421 \$3 \$I421 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $346 r0 *1 40.75,-1.2 slvtnfet
M$346 \$I421 \$I78 \$I424 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $347 r0 *1 41.25,-1.2 slvtnfet
M$347 \$I424 \$I399 \$I424 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $348 r0 *1 41.75,-1.2 slvtnfet
M$348 \$I424 \$I402 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P
+ PS=1.3U PD=1.3U
* device instance $349 r0 *1 42.25,-1.2 slvtnfet
M$349 \$3 \$I421 \$I78 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $350 r0 *1 42.75,-1.2 slvtnfet
M$350 \$I78 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $351 r0 *1 43.25,-1.2 slvtnfet
M$351 \$3 \$I78 \$I10 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
* device instance $352 r0 *1 43.75,-1.2 slvtnfet
M$352 \$I10 \$3 \$3 SUBSTRATE slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U
+ PD=1.3U
.ENDS shiftregister
