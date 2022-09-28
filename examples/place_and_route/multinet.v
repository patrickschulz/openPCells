module multinet(in, out);
  input in;
  output out;
  not_gate inv1 (
    .I(in),
    .O(out)
  );
  not_gate inv2 (
    .I(in),
    .O(out)
  );
  not_gate inv3 (
    .I(in),
    .O(out)
  );
  not_gate inv3 (
    .I(in),
    .O(out)
  );
  not_gate inv4 (
    .I(in),
    .O(out)
  );
  not_gate inv5 (
    .I(in),
    .O(out)
  );
  not_gate inv6 (
    .I(in),
    .O(out)
  );
endmodule
