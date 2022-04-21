module register(clk, in, out);
  input clk;
  input in;
  output out;
  not_gate inv1 (
    .I(in),
    .O(net1)
  );
  not_gate inv2 (
    .I(net1),
    .O(net2)
  );
  not_gate inv3 (
    .I(net2),
    .O(inverted)
  );
  dffp dff (
    .CLK(clk),
    .D(inverted),
    .Q(net3)
  );
  not_gate outbuf (
    .I(net3),
    .O(out)
  );
endmodule
