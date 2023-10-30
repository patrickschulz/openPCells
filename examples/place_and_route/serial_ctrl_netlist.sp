.SUBCKT serial_ctrl data_inout clk reset_in count_reached_in data_out_shift_reg_in reset_count_out update_shift_reg_out reset_shift_reg_out enable_shift_register
    X_107_ not_gate $PINS I=ack_out_0 O=_063_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_108_ not_gate $PINS I=curr_state_3 O=_064_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_109_ not_gate $PINS I=curr_state_pre_2 O=_065_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_110_ not_gate $PINS I=cmd_reg_1 O=_066_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_111_ not_gate $PINS I=cmd_count_0 O=_067_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_112_ not_gate $PINS I=curr_state_0 O=_068_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_113_ not_gate $PINS I=curr_state_pre_0 O=_069_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_114_ not_gate $PINS I=cmd_count_1 O=_070_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_115_ not_gate $PINS I=count_reached_in O=_071_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_116_ nand_gate $PINS A=curr_state_pre_1 B=_069_ O=_072_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_117_ or_gate $PINS A=curr_state_pre_3 B=_072_ O=_073_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_118_ or_gate $PINS A=curr_state_pre_2 B=_073_ O=_074_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_119_ and_gate $PINS A=_067_ B=_074_ O=_005_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_120_ or_gate $PINS A=cmd_count_0 B=cmd_count_1 O=_075_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_121_ nand_gate $PINS A=cmd_count_0 B=cmd_count_1 O=_076_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_122_ and_gate $PINS A=_075_ B=_076_ O=_077_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_123_ and_gate $PINS A=_074_ B=_077_ O=_006_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_124_ or_gate $PINS A=cmd_count_2 B=_076_ O=_078_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_125_ nand_gate $PINS A=cmd_count_2 B=_076_ O=_079_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_126_ nand_gate $PINS A=_078_ B=_079_ O=_080_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_127_ and_gate $PINS A=_074_ B=_080_ O=_007_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_128_ nor_gate $PINS A=_065_ B=_073_ O=_081_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_129_ or_gate $PINS A=curr_state_pre_3 B=curr_state_post_3 O=_082_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_130_ nand_gate $PINS A=curr_state_pre_3 B=curr_state_post_3 O=_083_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_131_ nand_gate $PINS A=_082_ B=_083_ O=_084_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_132_ or_gate $PINS A=curr_state_pre_2 B=curr_state_post_2 O=_085_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_133_ nand_gate $PINS A=curr_state_pre_2 B=curr_state_post_2 O=_086_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_134_ nand_gate $PINS A=_085_ B=_086_ O=_087_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_135_ nand_gate $PINS A=curr_state_pre_0 B=curr_state_post_0 O=_088_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_136_ or_gate $PINS A=curr_state_pre_0 B=curr_state_post_0 O=_089_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_137_ nand_gate $PINS A=_088_ B=_089_ O=_090_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_138_ or_gate $PINS A=curr_state_pre_1 B=curr_state_post_1 O=_091_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_139_ nand_gate $PINS A=curr_state_pre_1 B=curr_state_post_1 O=_092_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_140_ nand_gate $PINS A=_091_ B=_092_ O=_093_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_141_ and_gate $PINS A=_087_ B=_093_ O=_094_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_142_ and_gate $PINS A=_084_ B=_090_ O=_095_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_143_ nand_gate $PINS A=_094_ B=_095_ O=_096_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_144_ and_gate $PINS A=_081_ B=_096_ O=_097_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_145_ or_gate $PINS A=ack_out_2 B=_097_ O=_008_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_146_ nor_gate $PINS A=_063_ B=_097_ O=_009_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_147_ or_gate $PINS A=ack_out_1 B=_097_ O=_010_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_148_ nor_gate $PINS A=curr_state_pre_1 B=curr_state_pre_0 O=_098_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_149_ nand_gate $PINS A=curr_state_pre_2 B=_098_ O=_099_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_150_ or_gate $PINS A=curr_state_pre_3 B=_099_ O=_003_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_151_ and_gate $PINS A=curr_state_0 B=curr_state_1 O=_100_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_152_ nor_gate $PINS A=curr_state_3 B=curr_state_2 O=_101_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_153_ and_gate $PINS A=_100_ B=_101_ O=_004_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_154_ and_gate $PINS A=_068_ B=curr_state_1 O=_102_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_155_ and_gate $PINS A=_064_ B=curr_state_2 O=_103_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_156_ and_gate $PINS A=_102_ B=_103_ O=_104_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_157_ not_gate $PINS I=_104_ O=reset_count_out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_158_ and_gate $PINS A=curr_state_pre_3 B=_098_ O=_105_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_159_ and_gate $PINS A=_065_ B=_105_ O=_002_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_160_ nand_gate $PINS A=_100_ B=_103_ O=_011_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_161_ or_gate $PINS A=curr_state_2 B=curr_state_0 O=_012_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_162_ nor_gate $PINS A=curr_state_0 B=curr_state_1 O=_013_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_163_ or_gate $PINS A=curr_state_0 B=curr_state_1 O=_014_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_164_ nor_gate $PINS A=_064_ B=curr_state_2 O=_015_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_165_ nand_gate $PINS A=_013_ B=_015_ O=_016_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_166_ nand_gate $PINS A=_011_ B=_016_ O=enable_shift_register VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_167_ nand_gate $PINS A=cmd_count_2 B=_070_ O=_017_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_168_ nand_gate $PINS A=_078_ B=_017_ O=_018_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_169_ and_gate $PINS A=_081_ B=_018_ O=_001_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_170_ nand_gate $PINS A=enable_write B=data_out_shift_reg_in O=_019_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_171_ nand_gate $PINS A=enable_ack B=ack_out_pre_0 O=_020_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_172_ or_gate $PINS A=enable_ack B=_019_ O=_021_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_173_ nand_gate $PINS A=_020_ B=_021_ O=data_inout VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_174_ nor_gate $PINS A=_068_ B=curr_state_1 O=_022_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_175_ and_gate $PINS A=_103_ B=_022_ O=_023_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_176_ nand_gate $PINS A=_103_ B=_022_ O=_024_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_177_ nand_gate $PINS A=cmd_reg_0 B=_024_ O=_025_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_178_ nand_gate $PINS A=data_inout B=_023_ O=_026_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_179_ nand_gate $PINS A=_025_ B=_026_ O=_000__0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_180_ nand_gate $PINS A=cmd_reg_0 B=_023_ O=_027_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_181_ nand_gate $PINS A=cmd_reg_1 B=_024_ O=_028_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_182_ nand_gate $PINS A=_027_ B=_028_ O=_000__1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_183_ or_gate $PINS A=count_reached_in B=_011_ O=_029_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_184_ and_gate $PINS A=_101_ B=_102_ O=_030_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_185_ nand_gate $PINS A=_101_ B=_102_ O=_031_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_186_ nand_gate $PINS A=data_inout B=_030_ O=_032_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_187_ and_gate $PINS A=_029_ B=_032_ O=_033_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_188_ and_gate $PINS A=cmd_count_pre_2 B=cmd_count_pre_0 O=_034_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_189_ and_gate $PINS A=cmd_count_pre_1 B=_034_ O=_035_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_190_ and_gate $PINS A=cmd_reg_1 B=_104_ O=_036_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_191_ nand_gate $PINS A=_035_ B=_036_ O=_037_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_192_ nor_gate $PINS A=cmd_count_pre_2 B=cmd_count_pre_0 O=_038_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_193_ and_gate $PINS A=cmd_count_pre_1 B=_038_ O=_039_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_194_ or_gate $PINS A=_024_ B=_039_ O=_040_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_195_ or_gate $PINS A=_071_ B=_016_ O=_041_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_196_ and_gate $PINS A=_040_ B=_041_ O=_042_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_197_ and_gate $PINS A=_037_ B=_042_ O=_043_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_198_ nand_gate $PINS A=_033_ B=_043_ O=_106__0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_199_ nand_gate $PINS A=curr_state_2 B=_014_ O=_044_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_200_ nand_gate $PINS A=_012_ B=_044_ O=_045_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_201_ nand_gate $PINS A=curr_state_3 B=_014_ O=_046_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_202_ and_gate $PINS A=_011_ B=_046_ O=_047_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_203_ and_gate $PINS A=_045_ B=_047_ O=_048_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_204_ nand_gate $PINS A=_023_ B=_039_ O=_049_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_205_ or_gate $PINS A=data_inout B=_031_ O=_050_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_206_ nand_gate $PINS A=_066_ B=_035_ O=_051_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_207_ nand_gate $PINS A=_104_ B=_051_ O=_052_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_208_ and_gate $PINS A=_049_ B=_052_ O=_053_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_209_ and_gate $PINS A=_050_ B=_053_ O=_054_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_210_ nand_gate $PINS A=_048_ B=_054_ O=_106__1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_211_ nand_gate $PINS A=cmd_reg_0 B=_035_ O=_055_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_212_ nand_gate $PINS A=_104_ B=_055_ O=_056_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_213_ nand_gate $PINS A=_101_ B=_013_ O=_057_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_214_ and_gate $PINS A=_024_ B=_057_ O=_058_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_215_ and_gate $PINS A=_056_ B=_058_ O=_059_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_216_ nand_gate $PINS A=_033_ B=_059_ O=_106__2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_217_ or_gate $PINS A=count_reached_in B=_016_ O=_060_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_218_ nand_gate $PINS A=_066_ B=_104_ O=_061_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_219_ or_gate $PINS A=_055_ B=_061_ O=_062_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_220_ nand_gate $PINS A=_060_ B=_062_ O=_106__3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_221_ dffnq $PINS CLK=clk D=_005_ Q=cmd_count_pre_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_222_ dffnq $PINS CLK=clk D=_006_ Q=cmd_count_pre_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_223_ dffnq $PINS CLK=clk D=_007_ Q=cmd_count_pre_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_224_ dffpq $PINS CLK=clk D=curr_state_0 Q=curr_state_post_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_225_ dffpq $PINS CLK=clk D=curr_state_1 Q=curr_state_post_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_226_ dffpq $PINS CLK=clk D=curr_state_2 Q=curr_state_post_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_227_ dffpq $PINS CLK=clk D=curr_state_3 Q=curr_state_post_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_228_ dffnq $PINS CLK=clk D=curr_state_pre_0 Q=curr_state_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_229_ dffnq $PINS CLK=clk D=curr_state_pre_1 Q=curr_state_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_230_ dffnq $PINS CLK=clk D=curr_state_pre_2 Q=curr_state_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_231_ dffnq $PINS CLK=clk D=curr_state_pre_3 Q=curr_state_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_232_ dffprq $PINS CLK=clk D=_106__0 Q=curr_state_pre_0 RST=syncreset2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_233_ dffprq $PINS CLK=clk D=_106__1 Q=curr_state_pre_1 RST=syncreset2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_234_ dffprq $PINS CLK=clk D=_106__2 Q=curr_state_pre_2 RST=syncreset2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_235_ dffprq $PINS CLK=clk D=_106__3 Q=curr_state_pre_3 RST=syncreset2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_236_ dffnrq $PINS CLK=clk D=syncreset1 Q=syncreset2 RST=reset_in VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_237_ dffprq $PINS CLK=clk D=_FIXEDLEVEL_ Q=syncreset1 RST=reset_in VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_238_ dffpq $PINS CLK=clk D=ack_out_pre_0 Q=ack_out_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_239_ dffpq $PINS CLK=clk D=ack_out_pre_1 Q=ack_out_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_240_ dffpq $PINS CLK=clk D=ack_out_pre_2 Q=ack_out_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_241_ dffnq $PINS CLK=clk D=_001_ Q=enable_ack VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_242_ dffpq $PINS CLK=clk D=cmd_count_pre_0 Q=cmd_count_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_243_ dffpq $PINS CLK=clk D=cmd_count_pre_1 Q=cmd_count_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_244_ dffpq $PINS CLK=clk D=cmd_count_pre_2 Q=cmd_count_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_245_ dffnq $PINS CLK=clk D=_008_ Q=ack_out_pre_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_246_ dffnq $PINS CLK=clk D=_009_ Q=ack_out_pre_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_247_ dffnq $PINS CLK=clk D=_010_ Q=ack_out_pre_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_248_ dffpq $PINS CLK=clk D=_000__0 Q=cmd_reg_pre_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_249_ dffpq $PINS CLK=clk D=_000__1 Q=cmd_reg_pre_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_250_ dffnq $PINS CLK=clk D=cmd_reg_pre_0 Q=cmd_reg_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_251_ dffnq $PINS CLK=clk D=cmd_reg_pre_1 Q=cmd_reg_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_252_ dffpq $PINS CLK=clk D=_004_ Q=update_shift_reg_out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_253_ dffnq $PINS CLK=clk D=_002_ Q=enable_write VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_254_ dffnq $PINS CLK=clk D=_003_ Q=reset_shift_reg_out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
.ENDS
