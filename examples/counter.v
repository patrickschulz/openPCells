/* 
 * Verilog example for digital placement and routing in opc
 * This module is a two-bit counter generated by yosys with the supplied opc library files
 * The RTL source is given below
 * The generated code was edited to remove all net aliases, since opc can not
 * currently handle these
 */

/*
module counter(clk, count);
    parameter WIDTH = 2;
    input clk;

    output reg [WIDTH - 1:0] count = 0;
    reg [WIDTH - 1:0] count_pre = 0;

    always @(posedge clk) begin
        count <= count_pre;
    end
    always @(negedge clk) begin
        count_pre <= count_pre + 1;
    end
endmodule
*/

module counter(clk, count);
  wire _00_;
  wire _01_;
  input clk;
  output [1:0] count;
  wire [1:0] count_pre;
  opcinv _06_ (
    .I(count_pre[0]),
    .O(_00_)
  );
  opcxor _07_ (
    .A(count_pre[1]),
    .B(count_pre[0]),
    .O(_01_)
  );
  opcdffnq _08_ (
    .CLK(clk),
    .D(_00_),
    .Q(count_pre[0])
  );
  opcdffnq _09_ (
    .CLK(clk),
    .D(_01_),
    .Q(count_pre[1])
  );
  opcdffq _10_ (
    .CLK(clk),
    .D(count_pre[0]),
    .Q(count[0])
  );
  opcdffq _11_ (
    .CLK(clk),
    .D(count_pre[1]),
    .Q(count[1])
  );
endmodule

