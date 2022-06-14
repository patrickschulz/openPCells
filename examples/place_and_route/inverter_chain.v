module register_cell(in, out);
  input in;
  output out;
  wire net0;
  not_gate inv1 (
    .I(in),
    .O(net0)
  );
  not_gate inv2 (
    .I(net0),
    .O(out)
  );
endmodule
