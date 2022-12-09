* Created by KLayout

* cell register_cell
* pin SUBSTRATE
.SUBCKT register_cell 2
* net 2 SUBSTRATE
* device instance $1 r0 *1 0,1.2 slvtpfet
M$1 1 1 1 29 slvtpfet L=0.2U W=48U AS=7.7P AD=7.45P PS=65.4U PD=63.9U
* device instance $15 r0 *1 7,1.2 slvtpfet
M$15 1 1 11 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $18 r0 *1 8.5,1.2 slvtpfet
M$18 1 1 3 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $25 r0 *1 12,1.2 slvtpfet
M$25 1 1 26 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $26 r0 *1 12.5,1.2 slvtpfet
M$26 26 1 26 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $27 r0 *1 13,1.2 slvtpfet
M$27 26 1 10 29 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $28 r0 *1 13.5,1.2 slvtpfet
M$28 10 1 1 29 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $31 r0 *1 15,1.2 slvtpfet
M$31 1 26 1 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $33 r0 *1 16,1.2 slvtpfet
M$33 1 1 19 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.55P PS=2.6U PD=4.1U
* device instance $52 r0 *1 8.5,2.8 slvtpfet
M$52 1 1 4 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $55 r0 *1 10,2.8 slvtpfet
M$55 1 1 8 29 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $62 r0 *1 13.5,2.8 slvtpfet
M$62 26 1 9 29 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $63 r0 *1 14,2.8 slvtpfet
M$63 9 1 1 29 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $69 r0 *1 0,9.2 slvtpfet
M$69 1 1 23 30 slvtpfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $71 r0 *1 1,9.2 slvtpfet
M$71 1 1 1 30 slvtpfet L=0.2U W=23U AS=3.45P AD=3.7P PS=29.9U PD=31.4U
* device instance $86 r0 *1 8.5,9.2 slvtpfet
M$86 1 1 5 30 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $89 r0 *1 10,9.2 slvtpfet
M$89 1 1 7 30 slvtpfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $94 r0 *1 12.5,9.2 slvtpfet
M$94 1 1 26 30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $95 r0 *1 13,9.2 slvtpfet
M$95 26 1 26 30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $96 r0 *1 13.5,9.2 slvtpfet
M$96 26 1 6 30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $97 r0 *1 14,9.2 slvtpfet
M$97 6 1 1 30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $99 r0 *1 15,9.2 slvtpfet
M$99 1 26 1 30 slvtpfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $103 r0 *1 0,-1.2 slvtnfet
M$103 1 1 1 2 slvtnfet L=0.2U W=51U AS=7.9P AD=8.15P PS=67.8U PD=69.3U
* device instance $107 r0 *1 2,-1.2 slvtnfet
M$107 1 1 16 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $116 r0 *1 6.5,-1.2 slvtnfet
M$116 1 1 13 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $117 r0 *1 7,-1.2 slvtnfet
M$117 13 1 13 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $120 r0 *1 8.5,-1.2 slvtnfet
M$120 1 1 22 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $121 r0 *1 9,-1.2 slvtnfet
M$121 22 1 22 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $123 r0 *1 10,-1.2 slvtnfet
M$123 1 1 27 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $126 r0 *1 11.5,-1.2 slvtnfet
M$126 1 1 26 2 slvtnfet L=0.2U W=3U AS=0.45P AD=0.45P PS=3.9U PD=3.9U
* device instance $127 r0 *1 12,-1.2 slvtnfet
M$127 26 1 26 2 slvtnfet L=0.2U W=6U AS=0.9P AD=0.9P PS=7.8U PD=7.8U
* device instance $129 r0 *1 13,-1.2 slvtnfet
M$129 26 1 17 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $130 r0 *1 13.5,-1.2 slvtnfet
M$130 17 1 17 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $131 r0 *1 14,-1.2 slvtnfet
M$131 17 1 1 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $132 r0 *1 14.5,-1.2 slvtnfet
M$132 1 1 18 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $133 r0 *1 15,-1.2 slvtnfet
M$133 18 26 1 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $135 r0 *1 16,-1.2 slvtnfet
M$135 1 1 19 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.55P PS=2.6U PD=4.1U
* device instance $137 r0 *1 0,5.2 slvtnfet
M$137 1 1 28 2 slvtnfet L=0.2U W=2U AS=0.55P AD=0.3P PS=4.1U PD=2.6U
* device instance $153 r0 *1 8,5.2 slvtnfet
M$153 1 1 21 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $154 r0 *1 8.5,5.2 slvtnfet
M$154 21 1 21 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $157 r0 *1 10,5.2 slvtnfet
M$157 1 1 25 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $158 r0 *1 10.5,5.2 slvtnfet
M$158 25 1 25 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $164 r0 *1 13.5,5.2 slvtnfet
M$164 26 1 24 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $165 r0 *1 14,5.2 slvtnfet
M$165 24 1 24 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $166 r0 *1 14.5,5.2 slvtnfet
M$166 24 1 1 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $167 r0 *1 15,5.2 slvtnfet
M$167 1 26 1 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $171 r0 *1 0,6.8 slvtnfet
M$171 1 1 12 2 slvtnfet L=0.2U W=1U AS=0.4P AD=0.15P PS=2.8U PD=1.3U
* device instance $172 r0 *1 0.5,6.8 slvtnfet
M$172 12 1 23 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $173 r0 *1 1,6.8 slvtnfet
M$173 23 1 1 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $187 r0 *1 8,6.8 slvtnfet
M$187 1 1 20 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $188 r0 *1 8.5,6.8 slvtnfet
M$188 20 1 20 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $191 r0 *1 10,6.8 slvtnfet
M$191 1 1 14 2 slvtnfet L=0.2U W=2U AS=0.3P AD=0.3P PS=2.6U PD=2.6U
* device instance $192 r0 *1 10.5,6.8 slvtnfet
M$192 14 1 14 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $198 r0 *1 13.5,6.8 slvtnfet
M$198 26 1 15 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $199 r0 *1 14,6.8 slvtnfet
M$199 15 1 15 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
* device instance $200 r0 *1 14.5,6.8 slvtnfet
M$200 15 1 1 2 slvtnfet L=0.2U W=1U AS=0.15P AD=0.15P PS=1.3U PD=1.3U
.ENDS register_cell
