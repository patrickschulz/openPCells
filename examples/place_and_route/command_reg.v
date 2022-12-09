module command_register(clk, data, receive, empty, ready, command);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  (* src = "command_register.v:2.11-2.14" *)
  input clk;
  wire clk;
  (* src = "command_register.v:14.15-14.22" *)
  wire [4:0] cmd_reg;
  (* src = "command_register.v:15.15-15.26" *)
  wire [4:0] cmd_reg_pre;
  (* src = "command_register.v:7.18-7.25" *)
  output [1:0] command;
  wire [1:0] command;
  (* src = "command_register.v:3.11-3.15" *)
  input data;
  wire data;
  (* src = "command_register.v:5.12-5.17" *)
  output empty;
  wire empty;
  (* src = "command_register.v:6.12-6.17" *)
  output ready;
  wire ready;
  (* src = "command_register.v:4.11-4.18" *)
  input receive;
  wire receive;
  nor_gate _05_ (
    .A(command[1]),
    .B(command[0]),
    .O(_01_)
  );
  or_gate _06_ (
    .A(cmd_reg[3]),
    .B(cmd_reg[2]),
    .O(_02_)
  );
  nor_gate _07_ (
    .A(cmd_reg[4]),
    .B(_02_),
    .O(_03_)
  );
  and_gate _08_ (
    .A(_01_),
    .B(_03_),
    .O(empty)
  );
  nand_gate _09_ (
    .A(cmd_reg[2]),
    .B(cmd_reg[4]),
    .O(_04_)
  );
  nor_gate _10_ (
    .A(cmd_reg[3]),
    .B(_04_),
    .O(ready)
  );
  and_gate _11_ (
    .A(data),
    .B(receive),
    .O(_00_)
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _12_ (
    .CLK(clk),
    .D(_00_),
    .Q(cmd_reg_pre[0])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _13_ (
    .CLK(clk),
    .D(command[0]),
    .Q(cmd_reg_pre[1])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _14_ (
    .CLK(clk),
    .D(command[1]),
    .Q(cmd_reg_pre[2])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _15_ (
    .CLK(clk),
    .D(cmd_reg[2]),
    .Q(cmd_reg_pre[3])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _16_ (
    .CLK(clk),
    .D(cmd_reg[3]),
    .Q(cmd_reg_pre[4])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _17_ (
    .CLK(clk),
    .D(cmd_reg_pre[0]),
    .Q(command[0])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _18_ (
    .CLK(clk),
    .D(cmd_reg_pre[1]),
    .Q(command[1])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _19_ (
    .CLK(clk),
    .D(cmd_reg_pre[2]),
    .Q(cmd_reg[2])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _20_ (
    .CLK(clk),
    .D(cmd_reg_pre[3]),
    .Q(cmd_reg[3])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _21_ (
    .CLK(clk),
    .D(cmd_reg_pre[4]),
    .Q(cmd_reg[4])
  );
  assign cmd_reg[1:0] = command;
endmodule
