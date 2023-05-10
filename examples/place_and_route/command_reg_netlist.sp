.SUBCKT command_register clk data receive empty ready command
    X_05_ nor_gate $PINS A=command_1 B=command_0 O=_01_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_06_ or_gate $PINS A=cmd_reg_3 B=cmd_reg_2 O=_02_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_07_ nor_gate $PINS A=cmd_reg_4 B=_02_ O=_03_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_08_ and_gate $PINS A=_01_ B=_03_ O=empty VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_09_ nand_gate $PINS A=cmd_reg_2 B=cmd_reg_4 O=_04_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_10_ nor_gate $PINS A=cmd_reg_3 B=_04_ O=ready VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_11_ and_gate $PINS A=data B=receive O=_00_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_12_ dffpq $PINS CLK=clk D=_00_ Q=cmd_reg_pre_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_13_ dffpq $PINS CLK=clk D=command_0 Q=cmd_reg_pre_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_14_ dffpq $PINS CLK=clk D=command_1 Q=cmd_reg_pre_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_15_ dffpq $PINS CLK=clk D=cmd_reg_2 Q=cmd_reg_pre_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_16_ dffpq $PINS CLK=clk D=cmd_reg_3 Q=cmd_reg_pre_4 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_17_ dffnq $PINS CLK=clk D=cmd_reg_pre_0 Q=command_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_18_ dffnq $PINS CLK=clk D=cmd_reg_pre_1 Q=command_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_19_ dffnq $PINS CLK=clk D=cmd_reg_pre_2 Q=cmd_reg_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_20_ dffnq $PINS CLK=clk D=cmd_reg_pre_3 Q=cmd_reg_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_21_ dffnq $PINS CLK=clk D=cmd_reg_pre_4 Q=cmd_reg_4 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
.ENDS
