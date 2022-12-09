module register_cell(sig, ref, up, down);
    wire net1;
    wire net2;
    wire net3;
    wire net4;
    wire net5;
    wire net6;
    wire resetb;
    wire reset;
    nor_gate nor1 (
        .A(ref),
        .B(up),
        .O(net1)
    );
    nor_gate nor2 (
        .A(net1),
        .B(net2),
        .O(up)
    );
    nor_gate nor3 (
        .A(net1),
        .B(net3),
        .O(net2)
    );
    nor_gate nor4 (
        .A(net2),
        .B(reset),
        .O(net3)
    );
    nor_gate nor5 (
        .A(sig),
        .B(down),
        .O(net4)
    );
    nor_gate nor6 (
        .A(net4),
        .B(net5),
        .O(down)
    );
    nor_gate nor7 (
        .A(net4),
        .B(net6),
        .O(net5)
    );
    nor_gate nor8 (
        .A(net5),
        .B(reset),
        .O(net6)
    );
    nand_gate nandr (
        .A(up),
        .B(down),
        .O(resetb)
    );
    not_gate notr (
        .I(resetb),
        .O(reset)
    );
endmodule
