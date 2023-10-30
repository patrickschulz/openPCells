.SUBCKT register_cell chain_in update clk reset enable chain_out bit_out
    Xinv not_gate $PINS I=enable O=_05_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xnand1 nand_gate $PINS A=chain_in B=enable O=_06_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xnand2 nand_gate $PINS A=chain_out B=_05_ O=_07_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xnand3 nand_gate $PINS A=_06_ B=_07_ O=_00_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xdff_out dffprq $PINS CLK=update D=ff_in Q=bit_out RST=reset VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xdff_buf dffnq $PINS CLK=clk D=ff_in Q=chain_out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xdff_in dffpq $PINS CLK=clk D=_01_ Q=ff_in VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
.ENDS
