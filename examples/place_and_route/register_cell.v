module register_cell(chain_in, update, clk, reset, enable, chain_out, bit_out);
  wire _00_;
  wire chain_in;
  wire chain_out;
  wire enable;
  wire _05_;
  wire _06_;
  wire _07_;
  output bit_out;
  input chain_in;
  output chain_out;
  input clk;
  input enable;
  wire ff_in;
  input reset;
  input update;
  not_gate inv (
    .I(enable),
    .O(_05_)
  );
  nand_gate nand1 (
    .A(chain_in),
    .B(enable),
    .O(_06_)
  );
  nand_gate nand2 (
    .A(chain_out),
    .B(_05_),
    .O(_07_)
  );
  nand_gate nand3 (
    .A(_06_),
    .B(_07_),
    .O(_00_)
  );
  dffprq dff_out (
    .CLK(update),
    .D(ff_in),
    .Q(bit_out),
    .RESET(reset)
  );
  dffnq dff_buf (
    .CLK(clk),
    .D(ff_in),
    .Q(chain_out)
  );
  dffpq dff_in (
    .CLK(clk),
    .D(_01_),
    .Q(ff_in)
  );
endmodule
